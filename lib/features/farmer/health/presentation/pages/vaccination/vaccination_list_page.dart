// Vaccination List Page (index view) for the Farmer module.

import 'package:farm_manager_app/features/farmer/health/presentation/pages/vaccination/vaccination_core.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/vaccination/vaccination_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VaccinationListPage extends StatefulWidget {
  const VaccinationListPage({super.key});

  @override
  State<VaccinationListPage> createState() => _VaccinationListPageState();
}

class _VaccinationListPageState extends State<VaccinationListPage> {
  final VaccinationService _service = VaccinationService();
  late Future<List<VaccinationSchedule>> _schedulesFuture;
  bool _showOverdue = false;
  String _searchQuery = '';
  List<VaccinationSchedule> _allSchedules = [];
  List<VaccinationSchedule> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  // Fetches data based on the current filter settings
  void _fetchSchedules() {
    setState(() {
      _schedulesFuture = _service.fetchSchedules(overdue: _showOverdue).then((data) {
        _allSchedules = data;
        _filterSchedules(_searchQuery); // Re-apply current search query
        return data;
      });
    });
  }

  // Filters local data based on the search query
  void _filterSchedules(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSchedules = _allSchedules;
      } else {
        _filteredSchedules = _allSchedules.where((item) {
          return item.searchableText.toLowerCase().contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const l10n = MockL10n();
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.insemination;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.vaccinations),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSchedules,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar Widget ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              onChanged: _filterSchedules,
              decoration: InputDecoration(
                hintText: l10n.searchSchedules,
                prefixIcon: Icon(Icons.search, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          // --- Overdue Switch ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.overdueSchedules, style: theme.textTheme.bodyLarge),
                Switch.adaptive(
                  value: _showOverdue,
                  onChanged: (value) {
                    setState(() {
                      _showOverdue = value;
                      _fetchSchedules();
                    });
                  },
                  activeColor: AppColors.error,
                ),
              ],
            ),
          ),
          
          // --- List View ---
          Expanded(
            child: FutureBuilder<List<VaccinationSchedule>>(
              future: _schedulesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (_filteredSchedules.isEmpty) {
                   return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        _searchQuery.isEmpty ? l10n.noSchedulesFound : l10n.noResultsFound,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filteredSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _filteredSchedules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.2),
                          child: Icon(Icons.vaccines, color: primaryColor),
                        ),
                        title: Text(
                          schedule.vaccineName,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${l10n.animal}: ${schedule.animalName} #${schedule.animalTag}",
                                style: theme.textTheme.bodyMedium),
                            Text("${l10n.scheduledDate}: ${DateFormat('dd MMM yyyy').format(schedule.scheduledDate)}",
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        trailing: StatusBadge(
                          text: schedule.statusSwahili,
                          color: schedule.flutterStatusColor,
                        ),
                        onTap: () async {
                          // Navigate to detail page
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VaccinationDetailPage(scheduleId: schedule.scheduleId),
                            ),
                          );
                          // Refresh list if marked as completed
                          if (result == true) {
                            _fetchSchedules();
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}