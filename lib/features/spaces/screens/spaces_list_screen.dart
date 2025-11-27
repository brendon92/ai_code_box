import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/space.dart';
import '../providers/space_provider.dart';
import '../repositories/space_repository.dart';
import 'space_detail_screen.dart';

class SpacesListScreen extends ConsumerStatefulWidget {
  const SpacesListScreen({super.key});

  @override
  ConsumerState<SpacesListScreen> createState() => _SpacesListScreenState();
}

class _SpacesListScreenState extends ConsumerState<SpacesListScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure default space is created on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(defaultSpaceProvider.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultSpaceAsync = ref.watch(defaultSpaceProvider);
    final spacesAsync = ref.watch(spacesProvider);

    return defaultSpaceAsync.when(
      data: (defaultSpace) {
        // Jeśli istnieje domyślna przestrzeń, pokaż jej zawartość jako główny widok
        return SpaceDetailScreen(
          spaceId: defaultSpace.id,
          showAllSpacesButton: true,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Przestrzenie Robocze'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Przestrzenie Robocze'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
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

  Widget _buildSpacesList(List<Space> spaces) {
    // Filtruj przestrzenie - pomiń domyślną
    final nonDefaultSpaces = spaces.where((space) => !space.isDefault).toList();

    if (nonDefaultSpaces.isEmpty) {
      return const Center(
        child: Text(
          'Brak dodatkowych przestrzeni. Utwórz nową przestrzeń roboczą.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: nonDefaultSpaces.length,
      itemBuilder: (context, index) {
        final space = nonDefaultSpaces[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: space.iconEmoji != null
                ? Text(
                    space.iconEmoji!,
                    style: const TextStyle(fontSize: 32),
                  )
                : const Icon(Icons.folder),
            title: Text(space.name),
            subtitle: space.description != null
                ? Text(space.description!)
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpaceDetailScreen(spaceId: space.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCreateSpaceDialog(BuildContext context) async {
    // Pobierz domyślną przestrzeń, aby ustawić parentId
    final defaultSpace = await ref.read(defaultSpaceProvider.future);
    
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final iconController = TextEditingController();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nowa przestrzeń robocza'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nazwa',
                hintText: 'Nazwa przestrzeni',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis (opcjonalnie)',
                hintText: 'Krótki opis przestrzeni',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Emoji (opcjonalnie)',
                hintText: '📁',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final repository = ref.read(spaceRepositoryProvider);
                await repository.createSpace(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  iconEmoji: iconController.text.trim().isEmpty
                      ? null
                      : iconController.text.trim(),
                  parentId: defaultSpace.id, // Ustaw jako pod-przestrzeń domyślnej
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(spacesProvider);
                  ref.invalidate(childSpacesProvider(defaultSpace.id));
                }
              }
            },
            child: const Text('Utwórz'),
          ),
        ],
      ),
    );
  }
}

