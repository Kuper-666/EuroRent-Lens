import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const TELEGRAM_TOKEN = functions.config().telegram.token;
const TELEGRAM_API = `https://api.telegram.org/bot${TELEGRAM_TOKEN}`;

/**
 * Cloud Function: botProxy
 *
 * Принимает запрос от мобильного приложения,
 *转发 текст объявления в Telegram-бота @expat_rent_bot,
 * ждёт ответа и возвращает его пользователю.
 *
 * НИКОГДА не хранит TELEGRAM_TOKEN в коде приложения.
 * Токен живёт только в Firebase Environment Config.
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

  try {
    // 1. Отправляем текст боту от имени пользователя
    const sendResult = await fetch(`${TELEGRAM_API}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        chat_id: user_id,
        text: text,
      }),
    });

    if (!sendResult.ok) {
      const err = await sendResult.text();
      console.error("Telegram sendMessage failed:", err);
      res.status(502).json({ error: "Failed to send to bot", details: err });
      return;
    }

    // 2. Ждём ответа от бота (polling)
    const analysis = await waitForBotResponse(user_id, text);

    if (!analysis) {
      res.status(504).json({ error: "Bot did not respond within timeout" });
      return;
    }

    // 3. Возвращаем результат
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
 * Ожидает ответа от бота через getUpdates.
 * Ищет сообщение, отправленное ботом после我们的 текста.
 */
async function waitForBotResponse(
  userId: string,
  sentText: string,
  timeoutMs: number = 120000
): Promise<string | null> {
  const startTime = Date.now();
  let lastUpdateId = 0;

  // Сначала получаем текущий offset (чтобы не ловить старые апдейты)
  try {
    const initRes = await fetch(
      `${TELEGRAM_API}/getUpdates?limit=1&offset=-1`
    );
    const initData = await initRes.json();
    if (initData.ok && initData.result.length > 0) {
      lastUpdateId = initData.result[initData.result.length - 1].update_id;
    }
  } catch (e) {
    console.warn("Failed to get initial offset:", e);
  }

  // Polling loop
  while (Date.now() - startTime < timeoutMs) {
    await new Promise((r) => setTimeout(r, 3000));

    try {
      const res = await fetch(
        `${TELEGRAM_API}/getUpdates?offset=${lastUpdateId + 1}&timeout=2`
      );
      const data = await res.json();

      if (!data.ok || !data.result) continue;

      for (const update of data.result) {
        lastUpdateId = update.update_id;

        const msg = update.message;
        if (!msg) continue;

        // Ищем ответ бота тому же пользователю
        if (
          msg.chat?.id?.toString() === userId &&
          msg.from?.is_bot &&
          msg.text
        ) {
          return msg.text;
        }
      }
    } catch (e) {
      console.warn("Polling error:", e);
    }
  }

  return null;
}

/** Извлекает город из ответа бота */
function extractCity(text: string): string | null {
  const match = text.match(/🏙.*?([A-ZА-Яа-яёЁ][a-zа-яёЁ]+)/);
  return match ? match[1] : null;
}

/** Извлекает цену из ответа бота */
function extractPrice(text: string): number | null {
  const match = text.match(/(\d[\d\s]*)\s*EUR/i);
  if (!match) return null;
  return parseInt(match[1].replace(/\s/g, ""), 10);
}

/** Извлекает оценку (score) из ответа бота */
function extractScore(text: string): number | null {
  const match = text.match(/(?:Риск|Score|Оценка)[^\d]*(\d+)/i);
  return match ? parseInt(match[1], 10) : null;
}

/**
 * Привязка Google Account к Telegram user ID.
 * Вызывается при первом входе через Google.
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

  // Сохраняем в Firestore для связи Google ↔ Telegram
  await admin.firestore().collection("user_links").doc(google_user_id).set({
    email,
    google_user_id,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.json({ ok: true });
});
