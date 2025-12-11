import 'package:flutter/material.dart';

/// A reusable widget to display a standardized message and icon
/// when a list or section is empty.
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  

  const EmptyState({
    super.key, 
    required this.message, 
    required this.icon, 
    required this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 80, 
              color: iconColor, // Use the provided iconColor
            ),
            const SizedBox(height: 24),
            Text(
              message, 
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}