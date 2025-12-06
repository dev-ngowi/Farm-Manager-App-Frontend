import 'package:flutter/material.dart';

/// A reusable widget to display a standardized message and icon
/// when a list or section is empty.
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      // Padding to ensure content isn't too close to the edges
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // Set min height of the column to take up space in the center
          children: [
            // Icon styled with secondary color for visual balance
            Icon(
              icon, 
              size: 80, 
              // Use theme's primary color or a secondary gray/accent color
              color: theme.colorScheme.primary.withOpacity(0.5), 
            ),
            const SizedBox(height: 24),
            // Message using the bodyMedium style for secondary text, centered
            Text(
              message, 
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color, // Use theme's secondary text color
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}