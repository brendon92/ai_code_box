# AI Chat Flutter - Specyfikacja

## Opis
Prosta aplikacja czatu wykorzystująca API OpenAI (lub Gemini) do prowadzenia konwersacji. Kluczowym elementem jest zachowanie kontekstu rozmowy (wysyłanie historii wiadomości do API).

## Funkcjonalności
1. **Ekran Czatu:** Lista wiadomości (Użytkownik / AI).
2. **Input:** Pole tekstowe + przycisk wysyłania.
3. **State Management:** Riverpod do zarządzania listą wiadomości i stanem ładowania.
4. **API Integration:**
   - Model: `gpt-3.5-turbo` lub `gemini-pro`.
   - Przesyłanie tablicy `messages` (role: user, assistant).

## Struktura Katalogów (Clean Architecture)
```
lib/
├── core/
│   ├── api_client.dart
│   └── constants.dart
├── features/
│   └── chat/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   └── usecases/
│       └── presentation/
│           ├── providers/
│           └── widgets/
└── main.dart
```

## Kroki do wykonania
1. `flutter create ai_chat_flutter`
2. Dodanie zależności: `flutter_riverpod`, `dio`, `flutter_dotenv`.
3. Implementacja warstwy Data (API call).
4. Implementacja warstwy Presentation (UI).
