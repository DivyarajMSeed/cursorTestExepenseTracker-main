import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'expense' or 'income'

  const Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  static List<Category> expenseCategories = [
    Category(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Colors.orange,
      type: 'expense',
    ),
    Category(
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
      type: 'expense',
    ),
    Category(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.pink,
      type: 'expense',
    ),
    Category(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.purple,
      type: 'expense',
    ),
    Category(
      name: 'Healthcare',
      icon: Icons.medical_services,
      color: Colors.red,
      type: 'expense',
    ),
    Category(
      name: 'Bills & Utilities',
      icon: Icons.receipt,
      color: Colors.green,
      type: 'expense',
    ),
    Category(
      name: 'Education',
      icon: Icons.school,
      color: Colors.indigo,
      type: 'expense',
    ),
    Category(
      name: 'Travel',
      icon: Icons.flight,
      color: Colors.teal,
      type: 'expense',
    ),
    Category(
      name: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
      type: 'expense',
    ),
  ];

  static List<Category> incomeCategories = [
    Category(
      name: 'Salary',
      icon: Icons.work,
      color: Colors.green,
      type: 'income',
    ),
    Category(
      name: 'Freelance',
      icon: Icons.computer,
      color: Colors.blue,
      type: 'income',
    ),
    Category(
      name: 'Investment',
      icon: Icons.trending_up,
      color: Colors.orange,
      type: 'income',
    ),
    Category(
      name: 'Gift',
      icon: Icons.card_giftcard,
      color: Colors.pink,
      type: 'income',
    ),
    Category(
      name: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
      type: 'income',
    ),
  ];

  static List<Category> getAllCategories() {
    return [...expenseCategories, ...incomeCategories];
  }

  static Category? getCategoryByName(String name) {
    return getAllCategories().firstWhere(
      (category) => category.name == name,
      orElse: () => expenseCategories.last,
    );
  }
}