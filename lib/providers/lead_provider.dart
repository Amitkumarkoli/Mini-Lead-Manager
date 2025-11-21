import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead.dart';
import '../database/database_helper.dart';

final databaseProvider = Provider((ref) => DatabaseHelper.instance);

final leadProvider = StateNotifierProvider<LeadNotifier, AsyncValue<List<Lead>>>((ref) {
  return LeadNotifier(ref);
});

class LeadNotifier extends StateNotifier<AsyncValue<List<Lead>>> {
  final Ref ref;
  LeadNotifier(this.ref) : super(const AsyncLoading()) {
    loadLeads();
  }

  Future<void> loadLeads() async {
    state = const AsyncLoading();
    try {
      final db = ref.read(databaseProvider);
      final leads = await db.readAll();
      state = AsyncData(leads);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addLead(Lead lead) async {
    final db = ref.read(databaseProvider);
    await db.create(lead);
    await loadLeads();
  }

  Future<void> updateLead(Lead lead) async {
    final db = ref.read(databaseProvider);
    await db.updateLead(lead);
    await loadLeads();
  }

  Future<void> deleteLead(int id) async {
    final db = ref.read(databaseProvider);
    await db.delete(id);
    await loadLeads();
  }
}

// Filter provider
final statusFilterProvider = StateProvider<LeadStatus?>((ref) => null);

final filteredLeadsProvider = Provider<AsyncValue<List<Lead>>>((ref) {
  final leadsAsync = ref.watch(leadProvider);
  final filter = ref.watch(statusFilterProvider);

  return leadsAsync.whenData((leads) {
    if (filter == null) return leads;
    return leads.where((lead) => lead.status == filter).toList();
  });
});