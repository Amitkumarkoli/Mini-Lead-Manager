import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/lead.dart';
import '../providers/lead_provider.dart';
import '../widgets/status_badge.dart';

class LeadDetailScreen extends ConsumerWidget {
  final int leadId;
  const LeadDetailScreen({super.key, required this.leadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: leadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading lead')),
        data: (leads) {
          final lead = leads.firstWhere(
            (l) => l.id == leadId,
            orElse: () => Lead(name: 'Lead not found', contact: '—'),
          );

          // Auto navigate back if lead was deleted
          if (lead.id == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted && context.canPop()) context.pop();
            });
            return const Center(child: Text('This lead was deleted'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          lead.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _infoRow('Name', lead.name, isBold: true, fontSize: 24),
                    const Divider(height: 32),
                    _infoRow('Contact', lead.contact, fontSize: 18),
                    if (lead.notes != null && lead.notes!.isNotEmpty) ...[
                      const Divider(height: 32),
                      _infoRow('Notes', lead.notes!, fontSize: 16),
                    ],
                    const Divider(height: 40),
                    const Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: LeadStatus.values.map((status) {
                        final isSelected = lead.status == status;
                        return FilterChip(
                          label: Text(_statusLabel(status)),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) async {
                            await ref.read(leadProvider.notifier).updateLead(lead.copyWith(status: status));
                            ref.invalidate(leadProvider);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        StatusBadge(lead.status),
                        const Spacer(),
                        Text(
                          'Created: ${lead.createdAt.toLocal().toString().substring(0, 16)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, double fontSize = 18}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
        ),
      ],
    );
  }

  String _statusLabel(LeadStatus status) =>
      status.name.replaceAll('newLead', 'New').toUpperCase();

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lead?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(leadProvider.notifier).deleteLead(leadId);
              ref.invalidate(leadProvider);
              if (context.mounted) {
                Navigator.pop(ctx);
                if (context.canPop()) context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lead deleted'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}