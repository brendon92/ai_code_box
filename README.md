# AI Code Box

**AI Code Box** to zaawansowana platforma mobilna (Flutter) umożliwiająca tworzenie i zarządzanie inteligentnymi przestrzeniami roboczymi (Spaces). Projekt ten ewoluował z prostej aplikacji czatu w kompleksowe narzędzie do współpracy z wieloma agentami AI nad złożonymi projektami.

## 🚀 Wizja Projektu

Celem AI Code Box jest dostarczenie deweloperom i twórcom potężnego, lokalnego środowiska, w którym mogą:
- Organizować pracę w dedykowanych **Przestrzeniach (Spaces)**
- Współpracować z wyspecjalizowanymi **Agentami AI** wyposażonymi w tryby zaawansowanego rozumowania
- Zarządzać różnorodnymi zasobami w jednym miejscu, z uwzględnieniem flag prywatności i kontroli dostępu
- Edytować kod z podświetlaniem składni i wsparciem AI
- Utrzymywać pełną prywatność danych dzięki podejściu local-first

## ✨ Kluczowe Funkcjonalności

### 1. Przestrzenie Robocze (Spaces)
Każda przestrzeń to izolowane środowisko dla konkretnego projektu lub tematu.
- **Zasoby:** Możliwość dodawania i zarządzania plikami:
    - Dokumenty tekstowe (`.txt`, `.md`)
    - Dokumenty PDF (`.pdf`)
    - Pliki HTML (`.html`)
    - Pliki kodu źródłowego (`.dart`, `.js`, `.py`, `.java`, itp.)
    - Zewnętrzne linki URL
    - Zdjęcia i grafiki
- **Kontekst:** Wszystkie dodane pliki stanowią kontekst dla agentów pracujących w danej przestrzeni
- **Organizacja:** Hierarchiczna struktura folderów i tagowanie zasobów
- **Prywatność zasobów:** Każdy zasób może mieć flagę `PRIVATE`, co zapobiega wysyłaniu treści poza urządzenie lokalne (np. do API AI w sieci). Filtracja kontekstu przed wysłaniem do zdalnych modeli AI.
- **Kontrolowany dostęp:** Role-based access control (RBAC) do przestrzeni, zasobów i narzędzi AI, zintegrowane z Isar dla wydajnego sprawdzania uprawnień.

### 2. Multi-Agent Chat
- Możliwość prowadzenia wielu równoległych konwersacji w ramach jednej przestrzeni
- Dostęp do predefiniowanych agentów (np. Coder, Writer, Researcher) oraz możliwość tworzenia własnych
- Agenci mają dostęp do kontekstu zgromadzonego w przestrzeni (z wykluczeniem zasobów PRIVATE)
- Każdy agent może mieć własną konfigurację modelu AI i system prompt
- Historia konwersacji z możliwością wyszukiwania i eksportu
- **Tryby rozumowania agentów:** Aktywowane ON/OFF w oknie konwersacji:
  - **DeepThinking (Reasoning):** Używa technik jak Chain-of-Thought (CoT) lub Tree-of-Thoughts (ToT) dla krok-po-kroku analizy i samooceny logicznej spójności.
  - **DeepResearch (Search Web):** Integracja z wyszukiwaniem sieciowym, wybór i ocena wyników, samoocena pracy oraz generowanie odpowiedzi na podstawie zebranych danych (z poszanowaniem prywatności).
  - **CodeMaster (Writes and Tests Code):** Generowanie, testowanie i iteracyjna poprawa kodu w izolowanym sandboxie.

### 2.5. Self-Improving Retrieval-Augmented Generation (RAG)
- **Core Mechanism**: Agents retrieve relevant resources (e.g., code files, PDFs, URLs) from the Space's knowledge base using embeddings and vector search, augmenting LLM prompts for grounded responses. Self-improvement via feedback loops: Agents self-evaluate output accuracy, refine retrieval queries, and update internal SOPs (Standard Operating Procedures) for better future performance.
- **Integration with Modes**:
  - **DeepThinking**: Chain-of-Thought with RAG-retrieved context for logical self-assessment.
  - **DeepResearch**: Hybrid search (semantic + keyword) on web/local resources; self-improves by ranking/iterating on retrieved snippets.
  - **CodeMaster**: Retrieves code snippets for generation/testing; self-improves via unit test feedback loops.
- **Privacy Handling**: Exclude PRIVATE-flagged resources from retrieval; use local embeddings for sensitive data to avoid API sends.
- **Optimizations**: Chunk resources (e.g., 500-word overlaps) to fit token limits; use isolates for embedding generation to prevent UI freezes. Predict: Token overflow—integrate token estimators (e.g., tiktoken_dart fork).

### 3. Lokalna Baza Danych (Local-First)
- **Prywatność:** Wszystkie dane (historia czatów, definicje agentów, struktura przestrzeni) są przechowywane lokalnie na urządzeniu użytkownika
- **Inicjalizacja:** Przy pierwszym uruchomieniu aplikacja automatycznie:
    - Tworzy strukturę bazy danych
    - Generuje zestaw startowych agentów przez LLM z promptów idealnych cech
    - Umożliwia zatwierdzenie, edycję lub ponowne wygenerowanie agentów
- **Synchronizacja:** Opcjonalna synchronizacja między urządzeniami (przyszła funkcjonalność)
- **Kontrolowany dostęp:** Integracja RBAC z Isar dla sprawdzania uprawnień przed operacjami (np. read/write/execute).

### 4. Edycja i Tworzenie Treści
- **Edytor kodu** z podświetlaniem składni dla 100+ języków programowania
- **Edytor Markdown** z podglądem na żywo
- **Edytor tekstu** z formatowaniem rich text
- Możliwość generowania nowych plików przez agentów AI bezpośrednio w przestrzeni projektu (z kontrolą dostępu)
- Autouzupełnianie kodu z pomocą AI
- Folding bloków kodu i numeracja linii

### 5. Zarządzanie Modelami i Kluczami API
- **Wsparcie dla wielu dostawców:**
    - OpenAI (GPT-4, GPT-3.5)
    - xAI (Grok)
    - Anthropic (Claude)
    - Google (Gemini)
- **Konfiguracja:** Użytkownik może dodawać i zarządzać kluczami API oraz wybierać aktywne modele bezpośrednio w ustawieniach aplikacji
- **Bezpieczeństwo:** Klucze API szyfrowane lokalnie; dodatkowe kontrole dostępu do narzędzi AI (np. web search tylko dla autoryzowanych agentów)

### 6. Sandbox do Wykonywania Kodu (Planowane)
- Bezpieczne środowisko do uruchamiania kodu źródłowego
- Wsparcie dla popularnych języków programowania
- Izolacja procesów dla bezpieczeństwa; integracja z trybem CodeMaster dla automatycznego testowania

## 🏗️ Architektura i Modele Obiektów

### Proponowane Modele Danych

```dart
// Przestrzeń robocza
class Space {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? iconEmoji;
  final List<String> tags;
  final SpaceSettings settings;
}

// Zasób w przestrzeni (plik, link, obraz)
class Resource {
  final String id;
  final String spaceId;
  final ResourceType type; // file, url, image, code
  final String name;
  final String? path; // dla plików lokalnych
  final String? url; // dla linków
  final String? content; // dla małych plików tekstowych
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isPrivate; // Flaga PRIVATE: true uniemożliwia wysyłanie poza urządzenie
  final List<double>? embeddingVector; // Stored embedding for fast retrieval (use Isar vector index)
  final DateTime? lastIndexedAt; // For incremental updates
}

enum ResourceType {
  textFile,
  markdown,
  pdf,
  html,
  code,
  image,
  url,
}

// Agent AI
class Agent {
  final String id;
  final String name;
  final String? description;
  final String systemPrompt;
  final AIProvider provider;
  final String modelId;
  final AgentCapabilities capabilities;
  final String? avatarEmoji;
  final DateTime createdAt;
  final bool isPredefined; // czy to predefiniowany agent
  final List<ReasoningMode> supportedModes; // Wspierane tryby rozumowania
  final bool supportsRAG; // Flag for RAG-enabled agents
  final List<RAGImprovement> improvementHistory; // Log self-improvements for auditing
}

enum AIProvider {
  openai,
  anthropic,
  google,
  xai,
}

enum ReasoningMode {
  deepThinking,
  deepResearch,
  codeMaster,
}

enum RAGImprovement {
  queryRefinement,
  retrievalReranking,
  responseEvaluation,
}

class AgentCapabilities {
  final bool canGenerateCode;
  final bool canEditFiles;
  final bool canSearchWeb;
  final bool canAnalyzeImages;
  final List<String> supportedLanguages;
  final List<PermissionAction> requiredPermissions; // Wymagane uprawnienia dla narzędzi
}

// Konwersacja z agentem
class Conversation {
  final String id;
  final String spaceId;
  final String agentId;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<Message> messages;
  final bool isPinned;
  final Map<ReasoningMode, bool> activeModes; // Aktywne tryby (ON/OFF)
}

// Wiadomość w konwersacji
class Message {
  final String id;
  final String conversationId;
  final MessageRole role; // user, assistant, system
  final String content;
  final DateTime timestamp;
  final List<Attachment> attachments;
  final MessageMetadata? metadata;
}

enum MessageRole {
  user,
  assistant,
  system,
}

class Attachment {
  final String id;
  final AttachmentType type;
  final String? resourceId; // odniesienie do Resource
  final String? url;
  final String? fileName;
}

enum AttachmentType {
  file,
  image,
  code,
  link,
}

// Konfiguracja API
class APIConfiguration {
  final String id;
  final AIProvider provider;
  final String apiKey; // zaszyfrowany
  final String? organizationId;
  final Map<String, dynamic> settings;
  final bool isActive;
}

// Ustawienia przestrzeni
class SpaceSettings {
  final String defaultAgentId;
  final bool autoSaveEnabled;
  final int maxContextSize;
  final List<String> allowedFileTypes;
}

// Kontrola dostępu (RBAC)
class AccessPermission {
  final String id;
  final String entityId; // SpaceId, ResourceId, AgentId
  final EntityType entityType;
  final String userRole; // 'owner', 'editor', 'viewer'
  final List<PermissionAction> allowedActions; // read, write, execute, share
}

enum EntityType { space, resource, tool }

enum PermissionAction { read, write, execute, share }
```

## 🛠️ Stack Technologiczny

### Core
- **Framework:** Flutter 3.x
- **Język:** Dart 3.x
- **State Management:** Riverpod 2.x

### Baza Danych - Rekomendacja: **Isar**
**Dlaczego Isar?**
- ⚡ Najwyższa wydajność dla dużych, indeksowanych zbiorów danych
- 🔍 Wbudowane full-text search (przydatne dla wyszukiwania w konwersacjach)
- 🔐 Wbudowane szyfrowanie
- 📱 Optymalizacja pod urządzenia mobilne
- 🔄 Automatyczna migracja schematów
- 💾 Wsparcie dla multi-isolate concurrency
- 🎯 NoSQL - elastyczność dla ewoluujących struktur danych AI, w tym RBAC

**Alternatywy:**
- **Drift** - dla bardziej relacyjnych danych i złożonych zapytań SQL
- **Hive** - dla prostszego cachowania i preferencji użytkownika

### Edytory i UI
- **Edytor kodu:** [flutter_code_editor](https://pub.dev/packages/flutter_code_editor) - 100+ języków, folding, autocompletion
- **Markdown:** [markdown_editor_plus](https://pub.dev/packages/markdown_editor_plus) + [flutter_markdown](https://pub.dev/packages/flutter_markdown)
- **Rich Text:** [flutter_quill](https://pub.dev/packages/flutter_quill)
- **Syntax Highlighting:** [syntax_highlight](https://pub.dev/packages/syntax_highlight) (TextMate rules)

### AI Integration
- **OpenAI:** [dart_openai](https://pub.dev/packages/dart_openai)
- **Google Gemini:** [google_generative_ai](https://pub.dev/packages/google_generative_ai)
- **Flutter AI Toolkit:** [flutter_ai_toolkit](https://pub.dev/packages/flutter_ai_toolkit)
- **HTTP Client:** [dio](https://pub.dev/packages/dio) dla custom API calls
- **Reasoning Pipelines:** Integracja z [langchain_dart](https://pub.dev/packages/langchain_dart) dla CoT/ToT/ReAct (optymalizacja promptów i iteracji)
- **Reasoning Pipelines & RAG**: [langchain_dart](https://pub.dev/packages/langchain_dart) for modular CoT/ToT/ReAct chains and RAG pipelines (vector stores, retrievers). Best practice: Custom chains for self-improvement (e.g., feedback agent critiques main output).
- **Embeddings**: Integrate [sentence_transformers_dart](https://github.com/search?q=sentence_transformers_dart) or on-device ML (TensorFlow Lite) for local generation; fallback to API for complex models.
- **Vector Search**: Use Isar with vector indexes for local retrieval; hybrid with FAISS via FFI for advanced similarity (predict: FFI overhead—benchmark isolates).
- **Self-Improvement Tools**: Custom Dart implementations from RAG_Techniques repo (e.g., query decomposition, reranking).

### Dodatkowe Pakiety
- **File Picker:** [file_picker](https://pub.dev/packages/file_picker)
- **PDF Viewer:** [syncfusion_flutter_pdfviewer](https://pub.dev/packages/syncfusion_flutter_pdfviewer)
- **Encryption:** [encrypt](https://pub.dev/packages/encrypt)
- **Path Management:** [path_provider](https://pub.dev/packages/path_provider)
- **Secure Storage:** [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) dla RBAC i kluczy
- **Web Search:** [serpapi](https://pub.dev/packages/serpapi) lub custom dio dla DeepResearch (z proxy dla prywatności)

## 📚 Przydatne Zasoby

### Dokumentacja i Tutoriale
- [Flutter AI Toolkit Documentation](https://flutter.dev/ai-toolkit)
- [Isar Database Documentation](https://isar.dev)
- [Riverpod State Management](https://riverpod.dev)
- [Flutter Code Editor Examples](https://github.com/akvelon/flutter-code-editor)
- [LangChain Dart dla Reasoning](https://pub.dev/packages/langchain_dart) - Framework do budowania łańcuchów rozumowania w Dart
- [ReAct Framework w LLM](https://arxiv.org/abs/2210.03629) - Artykuł o ReAct dla agentów (użyty w DeepResearch)
- [LangChain.dart Documentation](https://github.com/davidmigloz/langchain_dart) - For RAG and reasoning in Dart/Flutter.
- [Building a Self-Improving Agentic RAG System](https://levelup.gitconnected.com/building-a-self-improving-agentic-rag-system-f55003af44c4) - Agentic feedback loops.
- [LLM + RAG: File Reader Assistant](https://towardsdatascience.com/llm-rag-creating-an-ai-powered-file-reader-assistant/) - Practical RAG for documents, adaptable to Flutter.

### Repozytoria i Przykłady
- [flutter-code-editor](https://github.com/akvelon/flutter-code-editor) - Kompletny edytor kodu
- [flutter_quill](https://github.com/singerdmx/flutter-quill) - Rich text editor
- [isar](https://github.com/isar/isar) - Szybka baza danych NoSQL
- [langchain-dart](https://github.com/davidmigloz/langchain_dart) - Open-source repo dla implementacji CoT/ToT w Flutter (optymalizacje dla mobile)
- [flutter-rbac-example](https://github.com/search?q=flutter+isar+rbac) - Przykłady RBAC w Isar (sprawdź GitHub dla fork'ów z 2025)
- [dart-llm-reasoning](https://github.com/topics/dart-llm-reasoning) - Repozytoria z implementacjami reasoning w Dart (np. self-evaluation pipelines)
- [langchain_dart](https://github.com/davidmigloz/langchain_dart) - Core for RAG/reasoning; extend for self-improving agents.
- [NirDiamant/RAG_Techniques](https://github.com/NirDiamant/RAG_Techniques) - Advanced RAG methods (e.g., hybrid search); port to Dart.
- [Awesome-RAG](https://github.com/Danielskry/Awesome-RAG) - Curated RAG resources; check for Dart forks.

### Artykuły i Blogi
- [Flutter AI Best Practices 2024](https://medium.com/flutter-community)
- [Building AI-Powered Apps with Flutter](https://flutter.dev/ai)
- [Local-First Software Principles](https://www.inkandswitch.com/local-first/)
- [Understanding the Current State of Reasoning with LLMs](https://isamu-website.medium.com/understanding-the-current-state-of-reasoning-with-llms-dbd9fa3fc1a0) - Analiza technik reasoning (CoT, ToT, ReAct)
- [Implementing RBAC in Flutter with Isar](https://medium.com/search?q=flutter+isar+rbac+best+practices) - Best practices dla kontroli dostępu (przewidywane problemy: skalowalność na mobile)
- [Optimizing LLM Reasoning in Mobile Apps](https://towardsdatascience.com/optimizing-llm-reasoning-mobile-2025) - Optymalizacje tokenów i isolates
- [Building Reliable RAG Applications in 2025](https://medium.com/@kuldeep.paul08/building-reliable-rag-applications-in-2025-3891d1b1da1f) - Best practices like observability and fine-tuning.
- [10 Techniques to Improve RAG Accuracy](https://redis.io/blog/10-techniques-to-improve-rag-accuracy/) - Optimizations (e.g., chunking); adapt for Isar.
- [RAG 2.0: The 2025 Guide](https://vatsalshah.in/blog/the-best-2025-guide-to-rag) - Advanced deployments, focus on mobile constraints.

### AI Providers Documentation
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Anthropic Claude API](https://docs.anthropic.com)
- [Google Gemini API](https://ai.google.dev/docs)
- [xAI Grok API](https://docs.x.ai)

## 🗺️ Roadmap

### Faza 1: Fundament (Q1 2025)
- [x] Implementacja lokalnej bazy danych (Isar)
- [x] Podstawowe modele danych i migracje
- [x] System zarządzania przestrzeniami roboczymi
- [x] Podstawowy UI dla list przestrzeni

### Faza 2: Agenci i Chat (Q2 2025)
- [ ] Integracja z API dostawców AI
- [ ] System zarządzania agentami
- [ ] Multi-agent chat interface
- [ ] Historia konwersacji i wyszukiwanie
- [ ] Generowanie startowych agentów przez LLM
- [ ] Implementacja trybów rozumowania (DeepThinking, DeepResearch, CodeMaster)
- [ ] Implementacja trybów rozumowania (DeepThinking, DeepResearch, CodeMaster) with initial RAG retrieval from Space resources.

### Faza 3: Edytory (Q2-Q3 2025)
- [ ] Integracja edytora kodu z syntax highlighting
- [ ] Edytor Markdown z live preview
- [ ] System zarządzania zasobami (pliki, linki, obrazy) z flagą PRIVATE
- [ ] Podgląd PDF i obrazów

### Faza 4: Zaawansowane Funkcje (Q3-Q4 2025)
- [ ] Autouzupełnianie kodu z AI
- [ ] Generowanie plików przez agentów
- [ ] Sandbox do wykonywania kodu
- [ ] Eksport i import przestrzeni
- [ ] Synchronizacja między urządzeniami (opcjonalna)
- [ ] Kontrola dostępu RBAC z optymalizacjami (np. caching w Riverpod)
- [ ] Self-Improving RAG: Feedback loops, evaluation agents, and SOP optimization.
- [ ] RAG Privacy Filters: Integrate with RBAC and PRIVATE flags.

### Faza 5: Optymalizacja (Q4 2025)
- [ ] Optymalizacja wydajności (izolates dla reasoning)
- [ ] Testy jednostkowe i integracyjne
- [ ] Dokumentacja API
- [ ] Przygotowanie do publikacji

## 🎯 Najlepsze Praktyki

### Architektura
- **Clean Architecture** - separacja warstw (data, domain, presentation)
- **Feature-First** - organizacja kodu według funkcjonalności
- **Dependency Injection** - używanie Riverpod dla DI
- **Reasoning Optymalizacje:** Użyj isolates dla pipeline'ów jak ReAct; cache intermediate steps w Isar, aby unikać przekraczania limitów tokenów

### Performance
- **Lazy Loading** - ładowanie danych na żądanie
- **Pagination** - dla długich list konwersacji i zasobów
- **Isolates** - dla ciężkich operacji (parsing, encryption, reasoning)
- **Const Constructors** - optymalizacja rebuilds
- **Przewidywane problemy:** Przekroczenie tokenów w DeepResearch – dodaj estimator tokenów (np. z tiktoken_dart); halucynacje – iteracyjna self-evaluation
- **RAG Optimizations**: Hybrid search in DeepResearch; use token estimators to predict limits. Predict: Hallucinations—implement multi-agent voting.

### Bezpieczeństwo
- **Encryption at Rest** - szyfrowanie kluczy API
- **Secure Storage** - używanie flutter_secure_storage
- **Input Validation** - walidacja wszystkich danych wejściowych
- **Sandbox Isolation** - izolacja wykonywania kodu
- **RBAC Best Practices:** Indeksuj permissions w Isar; cache w Riverpod dla szybkich sprawdzeń; przewidywane problemy: konflikty offline – resolvuj via timestamps
- **RAG Privacy**: Filter PRIVATE resources pre-retrieval; encrypt embeddings.

### Testing
- **Unit Tests** - dla logiki biznesowej (w tym reasoning pipelines)
- **Widget Tests** - dla komponentów UI (np. toggle trybów)
- **Integration Tests** - dla pełnych flow (np. filtracja PRIVATE)
- **Golden Tests** - dla consistency UI

---

## 📝 Notatki Deweloperskie

### Decyzje Architektoniczne
1. **Isar vs Drift**: Wybrano Isar ze względu na wydajność i elastyczność NoSQL, co jest kluczowe dla ewoluujących struktur danych AI i RBAC
2. **Local-First**: Priorytet dla prywatności i offline capabilities; flaga PRIVATE filtruje kontekst przed API calls
3. **Multi-Provider**: Wsparcie dla wielu dostawców AI zwiększa elastyczność i odporność na zmiany
4. **Reasoning Modes**: Integracja z langchain_dart dla modularnych pipeline'ów; optymalizacje: debounce na toggle'ach UI, aby unikać częstych zapisów do Isar
5. **RAG with langchain_dart**: Enables self-improving agents; modular for future expansions (e.g., graph RAG).

### Potencjalne Wyzwania
- **Context Size Management**: Zarządzanie rozmiarem kontekstu dla API AI (wyklucz PRIVATE)
- **Token Limits**: Optymalizacja użycia tokenów w trybach reasoning
- **Offline Sync**: Synchronizacja danych między urządzeniami (z RBAC)
- **Code Execution Security**: Bezpieczne wykonywanie kodu użytkownika; przewidywane: memory leaks w isolates – monitoruj z package:leak_tracker
- **RBAC Scalability**: Na mobile, unikaj over-fetching; użyj lazy queries w Isar
- **RAG Scalability**: Large embeddings—use compressed vectors; predict offline conflicts—sync via Isar timestamps.
- **Self-Improvement Loops**: Infinite iterations—add max-depth guards.

---

*Projekt w fazie aktywnego rozwoju. Wersja: 0.2.0-alpha*

**Ostatnia aktualizacja:** 2025-11-27