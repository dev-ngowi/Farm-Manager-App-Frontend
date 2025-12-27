import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Assuming AppColors is defined in app_theme.dart, e.g.,
// class AppColors {
//   static const Color primary = Color(0xFF00A04C);
//   static const Color secondary = Color(0xFFFF9800);
//   static const Color success = Color(0xFF4CAF50);
//   static const Color warning = Color(0xFFFFC107);
//   static const Color error = Color(0xFFF44336);
//   static const Color textPrimary = Color(0xFF212121);
//   static const Color surface = Colors.white;
// }


// --- 1. FINANCE-SPECIFIC COLORS ---
class FinanceColors {
  static const Color income = Color(0xFF43A047); // Green for Income
  static const Color expense = Color(0xFFD81B60); // Red/Pink for Expense
  static const Color profit = Color(0xFF1E88E5); // Blue for Profit/P&L
  static const Color reports = Color(0xFF00BFA5); // Teal for Reports
  static const Color budget = Color(0xFFFF9800); // Orange for Budget/Goals
  static const Color cash = Color(0xFF7E57C2); // Purple for Cash/Balance
}

// --- 2. DATA STRUCTURES ---

// Data structure based on metrics from ProfitLossController::summary() and others.
class _FinanceDashboardData {
  // Monthly KPIs (from ProfitLossController.php summary)
  final double totalIncomeThisMonth = 8500000.0;
  final double totalExpenseThisMonth = 5200000.0;
  final double monthlyProfit = 3300000.0; // Income - Expense
  // Calculated: (Profit / Income) * 100
  final double profitMargin = (3300000.0 / 8500000.0) * 100; // ≈ 38.82%
  final String profitTrend = 'up'; // from ProfitLossController
  final int breakEvenLiters = 350; // from ProfitLossController

  // Alerts/Key Figures
  final int unpaidInvoices = 5;
  final int overdueExpenses = 3;
  final int pendingBudgetRequests = 2;
  final double cashBalance = 1500000.0;
  final String mostExpensiveCategory = 'Feed & Supplements';
}

final _mockData = _FinanceDashboardData();

class ModuleItem {
  final String titleKey;
  final IconData icon;
  final Color color;
  final int count; // Used for notifications/records count
  final String route;

  const ModuleItem({
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.count,
    required this.route,
  });
}

final List<ModuleItem> _moduleItems = [
  ModuleItem(
    titleKey: 'incomeRecords',
    icon: Icons.attach_money,
    color: FinanceColors.income,
    count: 12, // Mock count of new/unapproved incomes
    route: '/farmer/finance/income',
  ),
  ModuleItem(
    titleKey: 'expenseRecords',
    icon: Icons.money_off,
    color: FinanceColors.expense,
    count: 28, // Mock count of new/unapproved expenses
    route: '/farmer/finance/expenses',
  ),
  ModuleItem(
    titleKey: 'profitAndLoss',
    icon: Icons.show_chart,
    color: FinanceColors.profit,
    count: 0,
    route: '/farmer/finance/pnl',
  ),
  ModuleItem(
    titleKey: 'budgeting',
    icon: Icons.account_balance_wallet,
    color: FinanceColors.budget,
    count: 0,
    route: '/farmer/finance/budget',
  ),
  ModuleItem(
    titleKey: 'invoices',
    icon: Icons.receipt_long,
    color: FinanceColors.reports,
    count: _mockData.unpaidInvoices,
    route: '/farmer/finance/invoices',
  ),
  ModuleItem(
    titleKey: 'milkSales',
    icon: Icons.local_drink,
    color: FinanceColors.income,
    count: 120, // Mock count of milk sales records
    route: '/farmer/production/milk', // Relates to MilkYieldController
  ),
  ModuleItem(
    titleKey: 'financialReports',
    icon: Icons.analytics,
    color: FinanceColors.reports,
    count: 0,
    route: '/farmer/finance/reports',
  ),
  ModuleItem(
    titleKey: 'productionFactors',
    icon: Icons.factory,
    color: FinanceColors.budget,
    count: 0,
    route: '/farmer/production/factors', // Relates to ProductionFactorController
  ),
];

// --- 3. FINANCE DASHBOARD WIDGET ---
class FinancialDashboardPage extends StatelessWidget {
  static const String routeName = '/farmer/finance';

  const FinancialDashboardPage({super.key});

  // Helper to format currency (assuming TZS for the example)
  String _formatCurrency(double amount) {
    // This is a simple formatter for demonstration.
    // In a real app, use the intl package (NumberFormat).
    final formatted = (amount / 1000).toStringAsFixed(1);
    return 'TZS $formatted K';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _DesignL10n(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // Assuming AppColors.surface and AppColors.primary are defined
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/farmer/dashboard'),
        ),
        title: const Text(
          'Financial Management',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: AppColors.primary),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with overview
              _buildHeader(l10n),

              const SizedBox(height: 16),

              // Key metrics cards (Income, Expense, Profit)
              _buildKeyMetrics(l10n, _mockData),

              const SizedBox(height: 16),

              // Profit Margin Card
              _buildProfitMarginCard(l10n, _mockData),

              const SizedBox(height: 16),

              // Critical financial alerts
              _buildCriticalAlerts(l10n, _mockData),

              const SizedBox(height: 16),

              // Finance modules
              _buildFinanceModules(l10n),

              const SizedBox(height: 16),

              // Additional stats
              _buildAdditionalStats(l10n, _mockData),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_DesignL10n l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor cash flow, profitability, and financial alerts for ${DateTime.now().month}/${DateTime.now().year}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(_DesignL10n l10n, _FinanceDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Total Income',
              value: _formatCurrency(data.totalIncomeThisMonth),
              subtitle: 'This Month',
              icon: Icons.arrow_upward,
              color: FinanceColors.income,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Total Expenses',
              value: _formatCurrency(data.totalExpenseThisMonth),
              subtitle: 'This Month',
              icon: Icons.arrow_downward,
              color: FinanceColors.expense,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Net Profit',
              value: _formatCurrency(data.monthlyProfit),
              subtitle: 'This Month',
              icon: data.profitTrend == 'up'
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: data.monthlyProfit >= 0 ? FinanceColors.profit : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16, // Reduced font size for currency
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitMarginCard(_DesignL10n l10n, _FinanceDashboardData data) {
    double score = data.profitMargin;
    bool isGood = score >= 30; // Assuming a 30% profit margin is 'good'

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGood ? FinanceColors.income : AppColors.warning,
                      ),
                    ),
                  ),
                  Text(
                    '${score.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profit Margin (This Month)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGood
                          ? 'Excellent performance and financial health.'
                          : 'Review expenses to boost profitability.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGood ? FinanceColors.income : AppColors.warning,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalAlerts(_DesignL10n l10n, _FinanceDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 18),
              SizedBox(width: 6),
              Text(
                'Financial Alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAlertCard(
                  title: 'Unpaid Invoices',
                  count: data.unpaidInvoices,
                  icon: Icons.credit_card_off,
                  color: AppColors.error,
                  route: '/farmer/finance/invoices/unpaid',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertCard(
                  title: 'Overdue Expenses',
                  count: data.overdueExpenses,
                  icon: Icons.calendar_today,
                  color: AppColors.warning,
                  route: '/farmer/finance/expenses/overdue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAlertCard(
                  title: 'Pending Budget Req.',
                  count: data.pendingBudgetRequests,
                  icon: Icons.request_page,
                  color: FinanceColors.budget,
                  route: '/farmer/finance/budget/pending',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertCard(
                  title: 'Cash Balance',
                  // Use 0 or -1 to signal low/critical state based on value
                  count: data.cashBalance < 500000 ? -1 : 0,
                  icon: Icons.account_balance,
                  color: data.cashBalance < 500000 ? AppColors.secondary : FinanceColors.cash,
                  route: '/farmer/finance/cash',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Builder(
      builder: (context) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    if (count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (count < 0)
                      const Text(
                        'LOW',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tap to view',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceModules(_DesignL10n l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.apps, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text(
                'Finance Modules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _moduleItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final item = _moduleItems[index];
              return _buildModuleButton(item, l10n);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleButton(ModuleItem item, _DesignL10n l10n) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 28,
                    ),
                  ),
                  if (item.count > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          item.count > 99 ? '99+' : item.count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.getString(item.titleKey),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStats(_DesignL10n l10n, _FinanceDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Cash Balance',
                  value: _formatCurrency(data.cashBalance),
                  icon: Icons.account_balance,
                  color: FinanceColors.cash,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Break-Even Liters',
                  value: '${data.breakEvenLiters} L',
                  icon: Icons.pie_chart,
                  color: FinanceColors.reports,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FinanceColors.expense.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.category,
                        size: 20, color: FinanceColors.expense),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Expensive Category',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.mostExpensiveCategory,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16, // Adjusted to fit currency
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MOCK LOCALIZATION (ADAPTED FOR FINANCE) ---
class _DesignL10n {
  final BuildContext context;
  _DesignL10n(this.context);

  String get financialManagement => 'Financial Management';
  String get financialOverview => 'Financial Overview';
  String get alerts => 'Financial Alerts';
  String get modules => 'Finance Modules';

  String get totalIncome => 'Total Income';
  String get totalExpenses => 'Total Expenses';
  String get netProfit => 'Net Profit';
  String get profitMargin => 'Profit Margin';

  String get unpaidInvoices => 'Unpaid Invoices';
  String get overdueExpenses => 'Overdue Expenses';
  String get pendingBudgetRequests => 'Pending Budget Requests';
  String get cashBalance => 'Cash Balance';

  String getString(String key) {
    switch (key) {
      case 'incomeRecords':
        return 'Income\nRecords';
      case 'expenseRecords':
        return 'Expense\nRecords';
      case 'profitAndLoss':
        return 'Profit &\nLoss';
      case 'budgeting':
        return 'Budgeting';
      case 'invoices':
        return 'Invoices';
      case 'milkSales':
        return 'Milk\nSales';
      case 'financialReports':
        return 'Financial\nReports';
      case 'productionFactors':
        return 'Production\nFactors';
      default:
        return key;
    }
  }
}