import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category.dart';
import '../utils/theme.dart';

class CategoryChart extends StatefulWidget {
  final Map<String, double> categoryTotals;

  const CategoryChart({
    super.key,
    required this.categoryTotals,
  });

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryTotals.isEmpty) {
      return Container();
    }

    final total = widget.categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final sections = widget.categoryTotals.entries.map((entry) {
      final category = Category.getCategoryByName(entry.key);
      final percentage = (entry.value / total) * 100;
      
      return PieChartSectionData(
        color: category?.color ?? Colors.grey,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: touchedIndex == widget.categoryTotals.keys.toList().indexOf(entry.key) ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Expense Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (pieTouchResponse?.touchedSection != null) {
                              touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                            } else {
                              touchedIndex = -1;
                            }
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.categoryTotals.entries.map((entry) {
                      final category = Category.getCategoryByName(entry.key);
                      final percentage = (entry.value / total) * 100;
                      final isSelected = touchedIndex == widget.categoryTotals.keys.toList().indexOf(entry.key);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category?.color ?? Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected 
                                          ? (category?.color ?? Colors.grey)
                                          : Theme.of(context).colorScheme.onBackground,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}