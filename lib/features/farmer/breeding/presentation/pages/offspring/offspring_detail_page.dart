import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Offspring Detail Model (Simplified for UI display) ---
class OffspringDetail {
  final int id;
  final String temporaryTag;
  final String gender;
  final double birthWeightKg;
  final String birthCondition;
  final String colostrumIntake;
  final bool navelTreated;
  final String notes;
  final int? livestockId;

  // Delivery/Parental Data
  final String deliveryDate;
  final String deliveryType;
  final int calvingEaseScore;
  final String damTag;
  final String damSpecies;
  final String? sireTag;
  final String? registeredTag; // Tag if registered as Livestock

  OffspringDetail.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        temporaryTag = json['temporary_tag'] as String? ?? 'N/A',
        gender = json['gender'] as String,
        birthWeightKg = (json['birth_weight_kg'] as num).toDouble(),
        birthCondition = json['birth_condition'] as String,
        colostrumIntake = json['colostrum_intake'] as String,
        navelTreated = json['navel_treated'] as bool,
        notes = json['notes'] as String? ?? '',
        livestockId = json['livestock_id'] as int?,
        
        // Nested Delivery/Parental Info
        deliveryDate = json['delivery']['actual_delivery_date'] as String,
        deliveryType = json['delivery']['delivery_type'] as String,
        calvingEaseScore = json['delivery']['calving_ease_score'] as int,
        damTag = json['delivery']['insemination']['dam']['tag_number'] as String,
        damSpecies = json['delivery']['insemination']['dam']['species']['name'] as String,
        sireTag = json['delivery']['insemination']['sire']['tag_number'] as String?,
        
        // Livestock Registration Info (if available)
        registeredTag = json['livestock']?['tag_number'] as String?;
}


class OffspringDetailPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/offspring/:id';
  final int offspringId;

  const OffspringDetailPage({super.key, required this.offspringId});

  @override
  State<OffspringDetailPage> createState() => _OffspringDetailPageState();
}

class _OffspringDetailPageState extends State<OffspringDetailPage> {
  OffspringDetail? _offspring;
  bool _isLoading = true;
  final Color primaryColor = BreedingColors.offspring;

  @override
  void initState() {
    super.initState();
    _loadOffspringDetails();
  }

  // --- Mock Data Fetching (Simulates API call to OffspringController@show) ---
  Future<void> _loadOffspringDetails() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final data = _fetchOffspringDetails(widget.offspringId);
      setState(() {
        _offspring = OffspringDetail.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar or error state)
      print("Error fetching offspring details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mock data generator for specific ID
  Map<String, dynamic> _fetchOffspringDetails(int id) {
    // Example data for ID 1 (Unregistered)
    if (id == 1) {
      return {
        'id': 1,
        'temporary_tag': 'CALF-001',
        'gender': 'Female',
        'birth_weight_kg': 32.5,
        'birth_condition': 'Vigorous',
        'colostrum_intake': 'Adequate',
        'navel_treated': true,
        'notes': 'No complications. Healthy and active.',
        'livestock_id': null,
        'delivery': {
          'id': 50,
          'actual_delivery_date': '2025-09-10',
          'delivery_type': 'Normal',
          'calving_ease_score': 1,
          'insemination': {
            'id': 101,
            'dam': {
              'id': 10,
              'tag_number': 'COW-101',
              'name': 'Bessie',
              'species': {'name': 'Cattle'}
            },
            'sire': {
              'id': 20,
              'tag_number': 'BULL-05',
              'name': 'Apollo'
            }
          }
        },
        'livestock': null
      };
    } 
    // Example data for ID 2 (Registered)
    else if (id == 2) {
      return {
        'id': 2,
        'temporary_tag': 'LAMB-005',
        'gender': 'Male',
        'birth_weight_kg': 4.1,
        'birth_condition': 'Weak',
        'colostrum_intake': 'Partial',
        'navel_treated': true,
        'notes': 'Required bottle feeding for first 12 hours.',
        'livestock_id': 55,
        'delivery': {
          'id': 51,
          'actual_delivery_date': '2025-12-05',
          'delivery_type': 'Assisted',
          'calving_ease_score': 3,
          'insemination': {
            'id': 102,
            'dam': {
              'id': 11,
              'tag_number': 'EWE-203',
              'name': 'Dolly',
              'species': {'name': 'Sheep'}
            },
            'sire': null // Sire might be unknown/null
          }
        },
        'livestock': {
          'id': 55,
          'tag_number': 'SHEEP-55',
          'name': 'BaaBaa',
          'species_id': 2,
          // ... more livestock details
        }
      };
    } 
    // Default or error case
    else {
      throw Exception("Offspring ID not found");
    }
  }

  // Helper to format the date from YYYY-MM-DD
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // --- Widget Builders ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: valueColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.loading),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_offspring == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.error),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text(l10n.offspringNotFound)),
      );
    }
    
    final offspring = _offspring!;
    final isRegistered = offspring.livestockId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.offspring} #${offspring.id}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () {
              // Navigate to the edit page for this offspring ID
              context.push('/farmer/breeding/offspring/${offspring.id}/edit');
            },
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Registration Status Card ---
            Card(
              elevation: 4,
              color: isRegistered ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRegistered ? l10n.registrationStatusRegistered : l10n.registrationStatusPending,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isRegistered ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    if (isRegistered) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(l10n.registeredAs, offspring.registeredTag ?? l10n.unknownTag, valueColor: AppColors.success),
                      _buildInfoRow(l10n.livestockId, offspring.livestockId.toString()),
                      // Optionally, add a button to view the full livestock profile
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(l10n.registerOffspringMessage, style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to the Offspring Registration form
                          context.push('/farmer/breeding/offspring/${offspring.id}/register');
                        },
                        icon: const Icon(Icons.badge),
                        label: Text(l10n.registerOffspring),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),

            // --- 1. Core Offspring Details ---
            _buildSectionHeader(l10n.offspringDetails, Icons.child_care),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(l10n.temporaryTag, offspring.temporaryTag),
                    _buildInfoRow(l10n.gender, offspring.gender),
                    _buildInfoRow(l10n.birthWeight, '${offspring.birthWeightKg.toStringAsFixed(1)} kg'),
                    _buildInfoRow(l10n.birthCondition, offspring.birthCondition, 
                      valueColor: offspring.birthCondition != 'Vigorous' ? AppColors.warning : AppColors.success),
                    _buildInfoRow(l10n.colostrumIntake, offspring.colostrumIntake),
                    _buildInfoRow(l10n.navelTreated, offspring.navelTreated ? l10n.yes : l10n.no),
                  ],
                ),
              ),
            ),
            
            // --- 2. Delivery & Birth Event Details ---
            _buildSectionHeader(l10n.birthEvent, Icons.event),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(l10n.deliveryDate, _formatDate(offspring.deliveryDate)),
                    _buildInfoRow(l10n.deliveryType, offspring.deliveryType),
                    _buildInfoRow(l10n.calvingEaseScore, offspring.calvingEaseScore.toString()),
                  ],
                ),
              ),
            ),

            // --- 3. Genetic Lineage ---
            _buildSectionHeader(l10n.lineage, Icons.pets),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(l10n.damTag, offspring.damTag),
                    _buildInfoRow(l10n.species, offspring.damSpecies),
                    _buildInfoRow(l10n.sireTag, offspring.sireTag ?? l10n.unknown),
                  ],
                ),
              ),
            ),

            // --- 4. Notes ---
            if (offspring.notes.isNotEmpty) ...[
              _buildSectionHeader(l10n.notes, Icons.description),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(offspring.notes, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

