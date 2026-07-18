import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const GROQ_API_KEY = functions.config().groq.api_key;
const GROQ_API = "https://api.groq.com/openai/v1/chat/completions";
const GROQ_MODEL = "llama-3.3-70b-versatile";

/**
 * Cloud Function: botProxy
 *
 * Принимает текст объявления от мобильного приложения,
 * отправляет на анализ в Groq API (LLM), возвращает результат.
 *
 * НЕ использует Telegram Bot API — прямой вызов Groq, без getUpdates,
 * без конфликтов с webhook бота.
 */
export const botProxy = functions.https.onRequest(async (req, res) => {
  // CORS
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const { text, user_id, lang } = req.body;

  if (!text || !user_id) {
    res.status(400).json({ error: "text and user_id are required" });
    return;
  }

  if (!GROQ_API_KEY) {
    res.status(500).json({ error: "GROQ_API_KEY not configured" });
    return;
  }

  try {
    const systemPrompt = getSystemPrompt(lang || "ru");
    const fullPrompt = `${systemPrompt}\n\nListing text:\n${text}`;

    const groqRes = await fetch(GROQ_API, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${GROQ_API_KEY}`,
      },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages: [{ role: "user", content: fullPrompt }],
      }),
    });

    if (!groqRes.ok) {
      const err = await groqRes.text();
      console.error("Groq API failed:", err);
      res.status(502).json({ error: "Analysis service unavailable", details: err });
      return;
    }

    const groqData = await groqRes.json();
    const analysis = groqData.choices?.[0]?.message?.content || "No analysis generated.";

    res.json({
      id: `analysis_${Date.now()}`,
      text: text,
      analysis: analysis,
      city: extractCity(analysis),
      price: extractPrice(analysis),
      score: extractScore(analysis),
      created_at: new Date().toISOString(),
    });
  } catch (error) {
    console.error("botProxy error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * Cloud Function: analyzePhoto
 *
 * Принимает Base64 изображение, отправляет в Groq с vision-моделью.
 */
export const analyzePhoto = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const { image, user_id, lang } = req.body;

  if (!image || !user_id) {
    res.status(400).json({ error: "image and user_id are required" });
    return;
  }

  if (!GROQ_API_KEY) {
    res.status(500).json({ error: "GROQ_API_KEY not configured" });
    return;
  }

  try {
    const systemPrompt = getSystemPrompt(lang || "ru");

    const groqRes = await fetch(GROQ_API, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${GROQ_API_KEY}`,
      },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages: [
          { role: "system", content: systemPrompt },
          {
            role: "user",
            content: [
              { type: "text", text: "Analyze this rental listing photo:" },
              { type: "image_url", image_url: { url: `data:image/jpeg;base64,${image}` } },
            ],
          },
        ],
      }),
    });

    if (!groqRes.ok) {
      const err = await groqRes.text();
      console.error("Groq vision API failed:", err);
      res.status(502).json({ error: "Analysis service unavailable" });
      return;
    }

    const groqData = await groqRes.json();
    const analysis = groqData.choices?.[0]?.message?.content || "No analysis generated.";

    res.json({
      id: `photo_${Date.now()}`,
      text: "(photo)",
      analysis: analysis,
      city: extractCity(analysis),
      price: extractPrice(analysis),
      score: extractScore(analysis),
      created_at: new Date().toISOString(),
    });
  } catch (error) {
    console.error("analyzePhoto error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * Привязка Google Account к Telegram user ID.
 */
export const linkAccount = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  const { google_user_id, email } = req.body;
  if (!google_user_id || !email) {
    res.status(400).json({ error: "google_user_id and email required" });
    return;
  }

  await admin.firestore().collection("user_links").doc(google_user_id).set({
    email,
    google_user_id,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.json({ ok: true });
});

/** System prompt for rental listing analysis */
function getSystemPrompt(lang: string): string {
  const prompts: Record<string, string> = {
    ru: `Ты — эксперт по аренде жилья в Европе. Проанализируй объявление об аренде и дай:
1. Оценка риска (1-10, где 10 — идеально)
2. Реальную цену со всеми комиссиями
3. Скрытые платежи и риски
4. Рекомендации по документам
5. Краткий итог (3-5 предложений)
Отвечай на русском языке. Будь конкретным и практичен.`,
    en: `You are a European rental housing expert. Analyze this rental listing and provide:
1. Risk score (1-10, where 10 is perfect)
2. Real price with all fees
3. Hidden payments and risks
4. Document recommendations
5. Brief summary (3-5 sentences)
Answer in English. Be specific and practical.`,
    de: `Du bist ein Experte für Mietwohnungen in Europa. Analysiere diese Anzeige und gib:
1. Risikobewertung (1-10, wobei 10 perfekt ist)
2. Realen Preis mit allen Gebühren
3. Versteckte Zahlungen und Risiken
4. Dokumentenempfehlungen
5. Kurze Zusammenfassung (3-5 Sätze)
Antworte auf Deutsch. Sei konkret und praktisch.`,
  };
  return prompts[lang] || prompts["ru"];
}

/** Extract city from analysis text */
function extractCity(text: string): string | null {
  const match = text.match(/🏙.*?([A-ZА-Яа-яёЁ][a-zа-яёЁ]+)/);
  return match ? match[1] : null;
}

/** Extract price from analysis text */
function extractPrice(text: string): number | null {
  const match = text.match(/(\d[\d\s]*)\s*EUR/i);
  if (!match) return null;
  return parseInt(match[1].replace(/\s/g, ""), 10);
}

/** Extract score from analysis text */
function extractScore(text: string): number | null {
  const match = text.match(/(?:Риск|Score|Оценка|Risk)[^\d]*(\d+)/i);
  return match ? parseInt(match[1], 10) : null;
}
