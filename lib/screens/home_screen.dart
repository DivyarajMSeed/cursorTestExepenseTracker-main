import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';
import '../utils/theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/recent_transaction_item.dart';
import '../widgets/category_chart.dart';
import 'add_transaction_screen.dart';
import 'transaction_history_screen.dart';
import 'category_insights_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Balance Cards
                    Consumer<ExpenseProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            BalanceCard(
                              title: 'Total Balance',
                              amount: provider.balance,
                              icon: Icons.account_balance_wallet,
                              color: AppTheme.primaryColor,
                              currency: provider.selectedCurrency,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: BalanceCard(
                                    title: 'Income',
                                    amount: provider.totalIncome,
                                    icon: Icons.trending_up,
                                    color: AppTheme.successColor,
                                    currency: provider.selectedCurrency,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: BalanceCard(
                                    title: 'Expenses',
                                    amount: provider.totalExpenses,
                                    icon: Icons.trending_down,
                                    color: AppTheme.errorColor,
                                    currency: provider.selectedCurrency,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Category Chart
                    Consumer<ExpenseProvider>(
                      builder: (context, provider, child) {
                        final categoryTotals = provider.getCategoryTotals();
                        if (categoryTotals.isEmpty) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pie_chart_outline,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No expenses yet',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return CategoryChart(categoryTotals: categoryTotals);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Recent Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TransactionHistoryScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Recent Transactions List
                    Consumer<ExpenseProvider>(
                      builder: (context, provider, child) {
                        final recentTransactions = provider.getRecentTransactions(limit: 5);
                        if (recentTransactions.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first expense or income',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: recentTransactions.map((transaction) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: RecentTransactionItem(transaction: transaction),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 100), // Bottom padding for FAB
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}