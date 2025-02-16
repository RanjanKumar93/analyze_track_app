import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

class Category {
  final String value;
  const Category._(this.value);

  static List<Category> values = [];

  // Method to add new values
  static void addValue(String newValue) {
    values.add(Category._(newValue));
  }

  // Method to remove values
  static void removeValue(String valueToRemove) {
    values.removeWhere((item) => item.value == valueToRemove);
  }
}

class Track {
  Track({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    String? id, // Optional id parameter
  }) : id = id ?? uuid.v4(); // Use the provided id or generate a new one

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  String get formattedDate {
    return formatter.format(date);
  }

  // Convert the Track object to a Map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), // Store date as ISO string
      'category': category, // Store category as an integer
    };
  }

  @override
  String toString() {
    return 'Track{id: $id, title: $title, amount: $amount, date: $date, category: $category}';
  }
}
