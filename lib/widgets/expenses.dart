import 'package:analyze_track/local/local_database.dart';
import 'package:analyze_track/models/expense.dart';
import 'package:analyze_track/widgets/chart/chart.dart';
import 'package:analyze_track/widgets/expenses_list/expenses_list.dart';
import 'package:analyze_track/widgets/new_expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const Expenses({super.key, required this.dbHelper});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await widget.dbHelper.getExpenses();
    setState(() {
      _registeredExpenses = expenses;
    });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: _addExpense,
      ),
    );
  }

  Future<void> _addExpense(Expense expense) async {
    await widget.dbHelper.insertExpense(expense);
    _loadExpenses();
  }

  Future<void> _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
            widget.dbHelper.insertExpense(expense);
          },
        ),
      ),
    );
    await widget.dbHelper.deleteExpense(expense.id);
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
      child: Text('Nothing found. Start adding some!'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Track'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ChartScreen(
                    dbHelper: widget.dbHelper,
                  ),
                ),
              );
            },
            child: const Text('Get chart'),
          ),
          Expanded(child: mainContent)
        ],
      ),
    );
  }
}
