// lib/features/researcher/presentation/pages/researcher_awaiting_approval_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_bloc.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_event.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';

class ResearcherAwaitingApprovalPage extends StatefulWidget {
  const ResearcherAwaitingApprovalPage({super.key});

  @override
  State<ResearcherAwaitingApprovalPage> createState() => 
      _ResearcherAwaitingApprovalPageState();
}

class _ResearcherAwaitingApprovalPageState 
    extends State<ResearcherAwaitingApprovalPage> {
  
  Timer? _pollingTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Check status immediately
    _checkApprovalStatus();
    
    // Poll every 10 seconds for status updates
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkApprovalStatus(),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _checkApprovalStatus() {
    if (mounted && !_isNavigating) {
      context.read<ResearcherBloc>().add(CheckApprovalStatusEvent());
    }
  }

  void _handleLogout() {
    // Add your logout logic here
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<ResearcherBloc, ResearcherState>(
        listener: (context, state) {
          if (state is ResearcherApprovalStatus && !_isNavigating) {
            if (state.approvalStatus == 'approved') {
              _isNavigating = true;
              _pollingTimer?.cancel();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.approvalGranted ?? 
                      'Your researcher profile has been approved!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );

              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  context.go('/researcher/dashboard');
                }
              });
            } 
            else if (state.approvalStatus == 'declined') {
              _isNavigating = true;
              _pollingTimer?.cancel();

              _showDeclineDialog(context, state.declineReason);
            }
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated waiting icon
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.8 + (value * 0.2),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.hourglass_empty,
                            size: 80,
                            color: Colors.blue[700],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    l10n.awaitingApproval ?? 'Awaiting Approval',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    l10n.approvalPendingMessage ?? 
                        'Your researcher profile has been submitted successfully. '
                        'Please wait while an administrator reviews your application.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Info card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.check_circle_outline,
                            l10n.profileSubmitted ?? 'Profile Submitted',
                            Colors.green,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.pending_outlined,
                            l10n.waitingForReview ?? 'Waiting for Review',
                            Colors.orange,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.notifications_active_outlined,
                            l10n.youWillBeNotified ?? 
                                'You will be notified once approved',
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading indicator
                  BlocBuilder<ResearcherBloc, ResearcherState>(
                    builder: (context, state) {
                      if (state is ResearcherLoading) {
                        return Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              l10n.checkingStatus ?? 'Checking status...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _checkApprovalStatus,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.checkStatus ?? 'Check Status'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout),
                        label: Text(l10n.logout ?? 'Logout'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeclineDialog(BuildContext context, String? reason) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red[700], size: 32),
            const SizedBox(width: 12),
            Text(
              l10n.applicationDeclined ?? 'Application Declined',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.declineMessage ?? 
                  'We regret to inform you that your researcher application '
                  'has been declined.',
              style: const TextStyle(fontSize: 16),
            ),
            if (reason != null && reason.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.reason ?? 'Reason:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  reason,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[900],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout();
            },
            child: Text(l10n.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }
}