# EuroRent Lens

Мобильное приложение для AI-анализа объявлений об аренде.

## Архитектура

```
EuroRent-Lens/
├── lib/                          # Flutter (Dart) — клиент
│   ├── core/                     # Theme, constants, network
│   ├── features/
│   │   ├── auth/                 # Google Sign-In
│   │   ├── camera/               # Камера + ML Kit OCR
│   │   ├── analysis/             # Отправка текста, отображение результата
│   │   ├── history/              # Локальная история (SQLite)
│   │   └── dashboard/            # Главный экран
│   └── main.dart
├── functions/                    # Firebase Cloud Functions (TypeScript)
│   └── src/index.ts              # botProxy — связь с @expat_rent_bot
├── firebase.json                 # Firebase конфигурация
└── pubspec.yaml                  # Flutter зависимости
```

## Стек

| Компонент | Технология |
|-----------|-----------|
| Фреймворк | Flutter 3.x (Dart) |
| Состояние | Riverpod |
| Авторизация | Firebase Auth + Google Sign-In |
| OCR | Google ML Kit Text Recognition |
| Сеть | Dio → Firebase Cloud Function → Telegram Bot API |
| Локальное хранилище | SQLite (sqflite) |
| Backend | Firebase Cloud Functions (TypeScript) |
| БД | Firestore (связки Google ↔ Telegram) |

## Безопасность

- **TELEGRAM_TOKEN НЕ в коде приложения** — хранится в Firebase Environment Config
- Приложение общается через Firebase Cloud Function (botProxy)
- Google Sign-In через официальный Firebase SDK
- Разрешение камеры запрашивается только по нажатию

## Установка

### 1. Flutter (клиент)
```bash
cd EuroRent-Lens
flutter pub get
flutter run
```

### 2. Firebase Cloud Function (backend)
```bash
cd EuroRent-Lens/functions
npm install

# Установить TELEGRAM_TOKEN в Firebase
firebase functions:config:set telegram.token="ВАШ_ТОКЕН"

# Деплой
firebase deploy --only functions
```

### 3. Firebase проект
1. Создай проект в [Firebase Console](https://console.firebase.google.com)
2. Включи Authentication → Google
3. Создай Cloud Function (см. выше)
4. Замени `europe-west1-eurorent-lens.cloudfunctions.net/botProxy` в `app_constants.dart` на твой URL

## Flow

1. Пользователь авторизуется через Google
2. Нажимает «Сфотографировать» → камера / галерея
3. ML Kit распознаёт текст (OCR)
4. Пользователь редактирует текст
5. Нажимает «Отправить боту»
6. Приложение → Firebase Cloud Function → Telegram Bot API
7. Cloud Function ждёт ответа бота (polling 3с)
8. Ответ отображается в красивом формате (Markdown)
9. Результат сохраняется в SQLite (история)
