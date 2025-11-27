# Plan Implementacji: Faza 2 - Agenci, Czat i UI Przestrzeni

## Cel
Celem tej fazy jest implementacja kluczowych funkcjonalności "AI Code Box" związanych z obsługą agentów AI, interfejsem czatu oraz **główną nawigacją opartą o Przestrzenie (Spaces)**.
Zgodnie z wymaganiami, głównym widokiem aplikacji będzie lista przestrzeni, a widok szczegółów przestrzeni będzie agregował pliki, konwersacje i agentów.

## Wymagany Przegląd Użytkownika
> [!IMPORTANT]
> Proszę o potwierdzenie wyboru pakietów do integracji API (dart_openai).
> Potwierdzenie struktury UI: SpaceList -> SpaceDetail (3 widgety: Pliki, Czaty, Agenci).

## Proponowane Zmiany

### Warstwa Danych (Isar)
Rozszerzenie schematu bazy danych.

#### [MODIFY] `lib/core/database/isar_service.dart`
- Rejestracja nowych kolekcji: `Agent`, `Conversation`, `Message`, `Space` (jeśli brakuje), `Resource` (jeśli brakuje).

#### [NEW] `lib/features/spaces/models/space.dart`
- Definicja modelu `Space` z polami: `id`, `name`, `isDefault`, `parentId` (dla hierarchii).
- `isDefault`: Flaga oznaczająca domyślną przestrzeń tworzoną przy starcie.
- `parentId`: Opcjonalne ID przestrzeni nadrzędnej (umożliwia dostęp do pod-przestrzeni).

#### [NEW] `lib/features/spaces/models/resource.dart`
- Definicja modelu `Resource` (pliki w przestrzeni).

#### [NEW] `lib/features/agents/models/agent.dart`
- Definicja modelu `Agent`.

#### [NEW] `lib/features/chat/models/conversation.dart`
- Definicja modelu `Conversation`.

#### [NEW] `lib/features/chat/models/message.dart`
- Definicja modelu `Message`.

### Warstwa Logiki (Services & Repositories)

#### [NEW] `lib/features/ai/services/ai_service.dart` & `openai_service.dart`
- Integracja z AI.

#### [NEW] `lib/features/spaces/repositories/space_repository.dart`
- CRUD dla przestrzeni i zasobów.
- **Logika startowa**: Sprawdzenie czy istnieje przestrzeń z `isDefault: true`. Jeśli nie, utworzenie domyślnej przestrzeni "Główna".

#### [NEW] `lib/features/agents/repositories/agent_repository.dart`
- CRUD dla agentów.

#### [NEW] `lib/features/chat/repositories/chat_repository.dart`
- Zarządzanie czatami.

### Warstwa Prezentacji (UI)
Implementacja nowej struktury nawigacji.

#### [MODIFY] `lib/main.dart`
- Zmiana `home` na `SpacesListScreen`.

#### [NEW] `lib/features/spaces/screens/spaces_list_screen.dart`
- **Główny ekran**: Lista dostępnych przestrzeni roboczych.
- FAB (Floating Action Button) do tworzenia nowej przestrzeni.

#### [NEW] `lib/features/spaces/screens/space_detail_screen.dart`
- **SpaceView**: Ekran szczegółów przestrzeni.
- Zawiera 3 główne sekcje (np. w TabBar lub Column):
    1. **Lista Plików** (`SpaceFilesList` widget)
    2. **Lista Konwersacji** (`SpaceConversationsList` widget)
    3. **Lista Agentów** (`SpaceAgentsList` widget)

#### [NEW] `lib/features/spaces/widgets/space_files_list.dart`
- Wyświetla zasoby przestrzeni.
- Opcja dodawania/importowania plików.

#### [NEW] `lib/features/spaces/widgets/space_conversations_list.dart`
- Wyświetla aktywne czaty w przestrzeni.
- Przycisk do rozpoczęcia nowego czatu.

#### [NEW] `lib/features/spaces/widgets/space_agents_list.dart`
- Wyświetla agentów przypisanych do przestrzeni.
- Opcja konfiguracji/dodawania agentów.

#### [NEW] `lib/features/chat/screens/chat_screen.dart`
- Ekran samej konwersacji (otwierany z `SpaceConversationsList`).

## Plan Weryfikacji

### Testy Automatyczne
- **Unit Tests**:
    - Modele: `Space`, `Agent`, `Conversation`.
    - Repozytoria: CRUD operacje.
- **Widget Tests**:
    - `SpaceDetailScreen`: Sprawdzenie czy wyświetlają się 3 listy.
    - `SpacesListScreen`: Sprawdzenie nawigacji do szczegółów.

### Weryfikacja Manualna
1. **Nawigacja**:
    - Uruchom aplikację -> Powinna pojawić się lista przestrzeni (pusta lub z przykładowymi).
    - Utwórz przestrzeń "Demo".
    - Kliknij w "Demo" -> Powinien otworzyć się widok z 3 sekcjami.
2. **Sekcje SpaceView**:
    - **Agenci**: Dodaj agenta, sprawdź czy pojawił się na liście.
    - **Czaty**: Rozpocznij czat, wyślij wiadomość, wróć -> Czat powinien być na liście konwersacji.
    - **Pliki**: (Mock) Dodaj plik, sprawdź czy jest na liście.
