// widgets/lead_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/lead.dart';
import 'status_badge.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  const LeadCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => context.go('/detail/${lead.id}'),
        title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lead.contact),
            if (lead.notes != null && lead.notes!.isNotEmpty)
              Text(lead.notes!, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: StatusBadge(lead.status),
      ),
    );
  }
}