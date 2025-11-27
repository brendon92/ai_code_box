import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/space_provider.dart';
import '../repositories/space_repository.dart';
import '../widgets/space_files_list.dart';
import '../widgets/space_conversations_list.dart';
import '../widgets/space_agents_list.dart';
import '../widgets/space_child_spaces_list.dart';
import '../../../core/widgets/floating_navbar.dart';

class SpaceDetailScreen extends ConsumerStatefulWidget {
  final int spaceId;
  final bool showAllSpacesButton;

  const SpaceDetailScreen({
    super.key,
    required this.spaceId,
    this.showAllSpacesButton = false,
  });

  @override
  ConsumerState<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends ConsumerState<SpaceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final spaceAsync = ref.watch(spaceProvider(widget.spaceId));

    return spaceAsync.when(
      data: (space) {
        if (space == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Błąd')),
            body: const Center(child: Text('Przestrzeń nie została znaleziona')),
          );
        }

        final isDefaultSpace = space.isDefault;

        if (isDefaultSpace) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  if (space.iconEmoji != null) ...[
                    Text(space.iconEmoji!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: Text(space.name)),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: widget.showAllSpacesButton
                  ? [
                      IconButton(
                        icon: const Icon(Icons.folder_copy),
                        tooltip: 'Wszystkie przestrzenie',
                        onPressed: () => _showAllSpacesDialog(context),
                      ),
                    ]
                  : null,
            ),
            body: _buildDefaultSpaceLayout(),
            floatingActionButton: const FloatingNavbar(),
          );
        }

        // Dla przestrzeni nie-domyślnych użyj TabBar
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  if (space.iconEmoji != null) ...[
                    Text(space.iconEmoji!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: Text(space.name)),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.folder), text: 'Pliki'),
                    Tab(icon: Icon(Icons.chat), text: 'Czaty'),
                    Tab(icon: Icon(Icons.smart_toy), text: 'Agenci'),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                SpaceFilesList(spaceId: widget.spaceId),
                SpaceConversationsList(spaceId: widget.spaceId),
                SpaceAgentsList(spaceId: widget.spaceId),
              ],
            ),
            floatingActionButton: const FloatingNavbar(),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Ładowanie...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Błąd')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Błąd: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultSpaceLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        // Lewa kolumna: Lista konwersacji (50%)
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Konwersacje',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SpaceConversationsList(spaceId: widget.spaceId),
                ),
              ],
            ),
          ),
        ),
        // Prawa kolumna: Pliki (góra) i Przestrzenie (dół) (50%)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Górna połowa: Lista plików
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.folder, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Pliki',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SpaceFilesList(spaceId: widget.spaceId),
                      ),
                    ],
                  ),
                ),
              ),
              // Dolna połowa: Lista pod-przestrzeni
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_special, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Przestrzenie',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SpaceChildSpacesList(spaceId: widget.spaceId),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
        );
      },
    );
  }

  void _showAllSpacesDialog(BuildContext context) {
    final spacesAsync = ref.read(spacesProvider.future);

    showDialog(
      context: context,
      builder: (context) => FutureBuilder(
        future: spacesAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Błąd'),
              content: Text('Błąd: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          final spaces = snapshot.data ?? [];
          // Filtruj - pokazuj tylko przestrzenie, które nie są domyślne
          final nonDefaultSpaces = spaces.where((space) => !space.isDefault).toList();

          if (nonDefaultSpaces.isEmpty) {
            return AlertDialog(
              title: const Text('Wszystkie przestrzenie'),
              content: const Text('Brak dodatkowych przestrzeni.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text('Wszystkie przestrzenie'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: nonDefaultSpaces.length,
                itemBuilder: (context, index) {
                  final space = nonDefaultSpaces[index];
                  return ListTile(
                    leading: space.iconEmoji != null
                        ? Text(
                            space.iconEmoji!,
                            style: const TextStyle(fontSize: 24),
                          )
                        : const Icon(Icons.folder),
                    title: Text(space.name),
                    subtitle: space.description != null
                        ? Text(space.description!)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpaceDetailScreen(spaceId: space.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zamknij'),
              ),
            ],
          );
        },
      ),
    );
  }
}

