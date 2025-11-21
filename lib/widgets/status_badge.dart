import 'package:flutter/material.dart';
import '../models/lead.dart';

class StatusBadge extends StatelessWidget {
  final LeadStatus status;
  const StatusBadge(this.status, {super.key});

  Color _color() {
    switch (status) {
      case LeadStatus.newLead: return Colors.blue;
      case LeadStatus.contacted: return Colors.orange;
      case LeadStatus.converted: return Colors.green;
      case LeadStatus.lost: return Colors.red;
    }
  }

  String _text() => status.name.replaceAll('newLead', 'New').toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_text(), style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: _color(),
    );
  }
}