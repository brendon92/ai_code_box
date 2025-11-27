import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resource.dart';
import '../repositories/space_repository.dart';
import '../providers/space_provider.dart';

class SpaceFilesList extends ConsumerStatefulWidget {
  final int spaceId;

  const SpaceFilesList({super.key, required this.spaceId});

  @override
  ConsumerState<SpaceFilesList> createState() => _SpaceFilesListState();
}

class _SpaceFilesListState extends ConsumerState<SpaceFilesList> {
  Future<List<Resource>> _loadResources() async {
    final repository = ref.read(spaceRepositoryProvider);
    return await repository.getSpaceResources(widget.spaceId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Resource>>(
      future: _loadResources(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Błąd: ${snapshot.error}'),
              ],
            ),
          );
        }

        final resources = snapshot.data ?? [];

        if (resources.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Brak plików w tej przestrzeni',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddResourceDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj plik'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: _getResourceIcon(resource.type),
                title: Text(resource.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Typ: ${_getResourceTypeName(resource.type)}'),
                    if (resource.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: resource.tags
                            .map((tag) => Chip(
                                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                                  padding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                  ],
                ),
                trailing: resource.isPrivate
                    ? const Icon(Icons.lock, color: Colors.orange)
                    : null,
                onTap: () {
                  // TODO: Open resource viewer/editor
                },
              ),
            );
          },
        );
      },
    );
  }

  Icon _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.textFile:
        return const Icon(Icons.description);
      case ResourceType.markdown:
        return const Icon(Icons.text_snippet);
      case ResourceType.pdf:
        return const Icon(Icons.picture_as_pdf);
      case ResourceType.html:
        return const Icon(Icons.html);
      case ResourceType.code:
        return const Icon(Icons.code);
      case ResourceType.image:
        return const Icon(Icons.image);
      case ResourceType.url:
        return const Icon(Icons.link);
    }
  }

  String _getResourceTypeName(ResourceType type) {
    switch (type) {
      case ResourceType.textFile:
        return 'Plik tekstowy';
      case ResourceType.markdown:
        return 'Markdown';
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.html:
        return 'HTML';
      case ResourceType.code:
        return 'Kod źródłowy';
      case ResourceType.image:
        return 'Obraz';
      case ResourceType.url:
        return 'Link';
    }
  }

  void _showAddResourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj zasób'),
        content: const Text(
          'Funkcjonalność dodawania plików będzie dostępna w następnej fazie.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

