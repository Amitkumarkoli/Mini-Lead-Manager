// lib/screens/add_lead_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/lead.dart';
import '../providers/lead_provider.dart';

class AddLeadScreen extends ConsumerWidget {
  const AddLeadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final notesController = TextEditingController();

    Future<void> saveAndGoBack() async {
      if (formKey.currentState!.validate()) {
        final newLead = Lead(
          name: nameController.text.trim(),
          contact: contactController.text.trim(),
          notes: notesController.text.trim().isEmpty
              ? null
              : notesController.text.trim(),
        );

        await ref.read(leadProvider.notifier).addLead(newLead);
        ref.invalidate(leadProvider); // refresh list instantly

        if (!context.mounted) return;

        // This is the magic line – 100% safe pop
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/'); // fallback to home if nothing to pop
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lead added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Lead'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Lead Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone or Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Contact is required';
                  if (!v.contains('@') &&
                      !RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                    return 'Enter valid 10-digit phone or email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: saveAndGoBack,
                icon: const Icon(Icons.save),
                label: const Text('Save Lead', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
