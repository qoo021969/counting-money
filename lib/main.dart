import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登入'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Firebase',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: '電子郵件',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: '密碼',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                child: Text('登入'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Expense {
  double amount;
  String category;
  String note;
  bool isIncome;
  DateTime date;

  Expense({
    required this.amount,
    required this.category,
    required this.note,
    required this.isIncome,
    required this.date,
  });
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? selectedDate;
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  List<Expense> expenses = [];
  String selectedCategory = '飲食';
  String selectedIncomeType = '工費';
  bool isIncome = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _addExpense() {
    String amountText = amountController.text;
    String noteText = noteController.text;
    if (amountText.isNotEmpty && selectedDate != null) {
      double expenseAmount = double.parse(amountText) * (isIncome ? 1 : -1);
      setState(() {
        expenses.add(
          Expense(
            amount: expenseAmount,
            category: selectedCategory,
            note: noteText,
            isIncome: isIncome,
            date: selectedDate!,
          ),
        );
      });
      amountController.clear();
      noteController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('記帳本'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '選擇日期:',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            selectedDate != null
                ? '${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日'
                : '請選擇日期',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text('選擇日期'),
          ),
          SizedBox(height: 20),
          ExpenseInputSection(
            amountController: amountController,
            noteController: noteController,
            selectedCategory: selectedCategory,
            isIncome: isIncome,
            onCategoryChanged: (String newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
            onIncomeChanged: (bool newValue) {
              setState(() {
                isIncome = newValue;
              });
            },
            onAddExpense: _addExpense,
            selectedIncomeType: selectedIncomeType,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsPage(expenses: expenses),
                ),
              );
            },
            child: Text('查看統計報告'),
          ),
        ],
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  final List<Expense> expenses;

  StatisticsPage({required this.expenses});

  @override
  Widget build(BuildContext context) {
    double totalExpense = expenses.isNotEmpty
        ? expenses.where((e) => !e.isIncome).map((e) => e.amount.abs()).fold(0, (a, b) => a + b)
        : 0;

    double totalIncome = expenses.isNotEmpty
        ? expenses.where((e) => e.isIncome).map((e) => e.amount).fold(0, (a, b) => a + b)
        : 0;

    double totalBalance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text('統計報告'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '總支出金額: \$${totalExpense.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '總收入金額: \$${totalIncome.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '合計: \$${totalBalance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
              '支出詳情:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('金額: \$${expenses[index].amount.toStringAsFixed(2)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('日期: ${DateFormat('yyyy-MM-dd').format(expenses[index].date)}'),
                        Text('分類: ${expenses[index].category}'),
                      ],
                    ),
                    onTap: () {
                      _showExpenseDetails(context, expenses[index]);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              '月度:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: _generateExpensePieChartSections(),
                        borderData: FlBorderData(show: false),
                        centerSpaceRadius: 40,
                        sectionsSpace: 0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: _generateIncomePieChartSections(),
                        borderData: FlBorderData(show: false),
                        centerSpaceRadius: 40,
                        sectionsSpace: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateExpensePieChartSections() {
    List<PieChartSectionData> sections = [];

    Map<String, double> categoryMap = {};
    for (Expense expense in expenses) {
      if (!expense.isIncome) {
        categoryMap[expense.category] ??= 0;
        categoryMap[expense.category] = categoryMap[expense.category]! + expense.amount.abs();
      }
    }

    int index = 0;
    categoryMap.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          value: amount,
          color: _getRandomColor(index),
          title: '$category\n\$${amount.toStringAsFixed(2)}',
          titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
      index++;
    });

    return sections;
  }

  List<PieChartSectionData> _generateIncomePieChartSections() {
    List<PieChartSectionData> sections = [];

    Map<String, double> categoryMap = {};
    for (Expense expense in expenses) {
      if (expense.isIncome) {
        categoryMap[expense.category] ??= 0;
        categoryMap[expense.category] = categoryMap[expense.category]! + expense.amount.abs();
      }
    }

    int index = 0;
    categoryMap.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          value: amount,
          color: _getRandomColor(index),
          title: '$category\n\$${amount.toStringAsFixed(2)}',
          titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
      index++;
    });

    return sections;
  }

  Color _getRandomColor(int index) {
    const List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('支出詳情'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('金額: \$${expense.amount.toStringAsFixed(2)}'),
              Text('日期: ${DateFormat('yyyy-MM-dd').format(expense.date)}'),
              Text('分類: ${expense.category}'),
              Text('備註: ${expense.note}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('關閉'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ExpenseInputSection extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController noteController;
  final String selectedCategory;
  final bool isIncome;
  final Function(String) onCategoryChanged;
  final Function(bool) onIncomeChanged;
  final VoidCallback onAddExpense;
  final String selectedIncomeType;

  ExpenseInputSection({
    required this.amountController,
    required this.noteController,
    required this.selectedCategory,
    required this.isIncome,
    required this.onCategoryChanged,
    required this.onIncomeChanged,
    required this.onAddExpense,
    required this.selectedIncomeType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: '金額',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: '備註',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: DropdownButtonFormField<String>(
                value: isIncome ? selectedIncomeType : selectedCategory,
                decoration: InputDecoration(
                  labelText: isIncome ? '收入分類' : '支出分類',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onCategoryChanged(newValue);
                  }
                },
                items: isIncome
                    ? <String>['工費', '兼職', '獎金', '其他收入'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()
                    : <String>['飲食', '交通', '娛樂', '醫療', '其他支出'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 20),
            Text('收入'),
            Switch(
              value: isIncome,
              onChanged: (bool newValue) {
                onIncomeChanged(newValue);
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onAddExpense,
          child: Text('添加'),
        ),
      ],
    );
  }
}
