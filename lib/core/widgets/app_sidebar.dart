// lib/core/widgets/app_sidebar.dart
import 'package:farm_manager_app/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;

  const AppSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: Column(
        children: [
          // Redesigned Compact Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8.0),
              children: [
                _SidebarItem(
                  currentRoute: currentRoute,
                  icon: Icons.home_filled,
                  title: "Home",
                  route: AppRoutes.farmerDashboard,
                ),
                _SidebarItem(
                  currentRoute: currentRoute,
                  icon: Icons.pets,
                  title: "Livestock",
                  route: AppRoutes.livestock,
                ),
                _SidebarItem(
                  currentRoute: currentRoute,
                  icon: Icons.category,
                  title: "Breeds",
                  route: AppRoutes.breeding,
                ),
               
                _SidebarItem(
                  currentRoute: currentRoute,
                  icon: Icons.health_and_safety,
                  title: "Health",
                  route: AppRoutes.health,
                ),
                _SidebarItem(
                  currentRoute: currentRoute,
                  icon: Icons.account_balance_wallet,
                  title: "Finance",
                  route: AppRoutes.finance,
                ),
                _SidebarItem(
                  currentRoute: currentRoute,
                  icon: Icons.bar_chart,
                  title: "Reports",
                  route: AppRoutes.reports,
                ),

                // Separator and Logout Item
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Divider(height: 1),
                ),
                _SidebarItem(
                  currentRoute: currentRoute,
                  icon: Icons.logout,
                  title: "Logout",
                  route: AppRoutes.login,
                  isDestructive: true,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              "Farm Manager v1.0.0",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pop();
                context.go(AppRoutes.login);
              },
              child: Text(
                "Logout",
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- Dedicated Sidebar Item Widget for Reusability and Clarity ---

class _SidebarItem extends StatelessWidget {
  final String currentRoute;
  final IconData icon;
  final String title;
  final String route;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.currentRoute,
    required this.icon,
    required this.title,
    required this.route,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;
    final colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Color activeColor = isDestructive ? colorScheme.error : colorScheme.primary;
    final Color inactiveColor = isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        leading: Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
          size: 24,
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: isActive ? activeColor : colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        selected: isActive,
        selectedTileColor: colorScheme.primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap ??
            () {
              context.go(route);
              Navigator.of(context).pop();
            },
      ),
    );
  }
}