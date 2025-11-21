// screens/lead_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/lead.dart';
import '../providers/lead_provider.dart';
import '../widgets/lead_card.dart';
import '../widgets/status_badge.dart';

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});
  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(filteredLeadsProvider);
    final filter = ref.watch(statusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Lead Manager'),
        actions: [
          PopupMenuButton<LeadStatus?>(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All')),
              ...LeadStatus.values.map((s) => PopupMenuItem(value: s, child: Text(s.name.toUpperCase()))),
            ],
            onSelected: (value) => ref.read(statusFilterProvider.notifier).state = value,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search leads...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => ref.invalidate(filteredLeadsProvider),
            ),
          ),
          if (filter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Filter: '),
                  StatusBadge(filter),
                  TextButton(
                    onPressed: () => ref.read(statusFilterProvider.notifier).state = null,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: leadsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (leads) {
                final query = searchController.text.toLowerCase();
                final filtered = leads.where((l) => l.name.toLowerCase().contains(query)).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No leads found'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    return Hero(
                      tag: 'lead_${filtered[i].id}',
                      child: LeadCard(lead: filtered[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}