import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'commitment_model.dart';
import 'user_selection_page.dart'; // Import for User class

class CommitmentHomePage extends StatefulWidget {
  final User selectedUser;

  CommitmentHomePage({required this.selectedUser});

  @override
  _CommitmentHomePageState createState() => _CommitmentHomePageState();
}

class _CommitmentHomePageState extends State<CommitmentHomePage> {
  Map<String, List<Commitment>> commitmentsByMonth = {};
  Map<String, double> incomeByMonth = {}; // Store income for each month

  DateTime selectedMonth = DateTime.now();
  String get currentMonthKey =>
      "${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}";

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();

  List<Commitment> get currentMonthCommitments =>
      commitmentsByMonth[currentMonthKey] ?? [];

  double get currentMonthIncome => incomeByMonth[currentMonthKey] ?? 0.0;

  // User-specific storage keys
  String get commitmentsStorageKey => 'commitments_${widget.selectedUser.id}';
  String get incomeStorageKey => 'income_${widget.selectedUser.id}';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    try {
      final storage = html.window.localStorage;
      final dataString = storage[commitmentsStorageKey];
      final incomeString = storage[incomeStorageKey];

      if (dataString != null && dataString.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(dataString);

        setState(() {
          commitmentsByMonth.clear();
          data.forEach((monthKey, commitmentsList) {
            commitmentsByMonth[monthKey] = (commitmentsList as List)
                .map((json) => Commitment.fromJson(json))
                .toList();
          });
        });
      }

      if (incomeString != null && incomeString.isNotEmpty) {
        final Map<String, dynamic> incomeData = jsonDecode(incomeString);
        setState(() {
          incomeByMonth.clear();
          incomeData.forEach((monthKey, income) {
            incomeByMonth[monthKey] = income.toDouble();
          });
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  void _saveData() {
    try {
      final storage = html.window.localStorage;
      final Map<String, dynamic> data = {};

      commitmentsByMonth.forEach((monthKey, commitments) {
        data[monthKey] = commitments.map((c) => c.toJson()).toList();
      });

      storage[commitmentsStorageKey] = jsonEncode(data);
      storage[incomeStorageKey] = jsonEncode(incomeByMonth);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  void addCommitment() {
    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
      final newCommitment = Commitment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        amount: double.tryParse(amountController.text) ?? 0.0,
        createdAt: DateTime.now(),
      );

      setState(() {
        if (commitmentsByMonth[currentMonthKey] == null) {
          commitmentsByMonth[currentMonthKey] = [];
        }
        commitmentsByMonth[currentMonthKey]!.add(newCommitment);
      });

      _saveData();
      titleController.clear();
      amountController.clear();
      Navigator.pop(context);
    }
  }

  void setIncome() {
    if (incomeController.text.isNotEmpty) {
      final income = double.tryParse(incomeController.text) ?? 0.0;

      setState(() {
        incomeByMonth[currentMonthKey] = income;
      });

      _saveData();
      incomeController.clear();
      Navigator.pop(context);
    }
  }

  void toggleCommitmentStatus(String id) {
    setState(() {
      final commitment = currentMonthCommitments.firstWhere((c) => c.id == id);
      commitment.isPaid = !commitment.isPaid;
    });
    _saveData();
  }

  void deleteCommitment(String id) {
    setState(() {
      commitmentsByMonth[currentMonthKey]?.removeWhere((c) => c.id == id);
    });
    _saveData();
  }

  void changeMonth(bool isNext) {
    setState(() {
      if (isNext) {
        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
      } else {
        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
      }
    });
  }

  String getMonthYearString() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return "${months[selectedMonth.month - 1]} ${selectedMonth.year}";
  }

  double getTotalAmount() {
    return currentMonthCommitments.fold(0.0, (sum, c) => sum + c.amount);
  }

  double getPaidAmount() {
    return currentMonthCommitments
        .where((c) => c.isPaid)
        .fold(0.0, (sum, c) => sum + c.amount);
  }

  double getBalance() {
    return currentMonthIncome - getTotalAmount();
  }

  void _switchUser() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: widget.selectedUser.color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                widget.selectedUser.id == 'user1' ? Icons.pets : Icons.favorite,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 8),
            Text('${widget.selectedUser.name} Commeowment'),
          ],
        ),
        backgroundColor: widget.selectedUser.color,
        foregroundColor: Colors.white,
        actions: [
          // Switch User Button
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: _switchUser,
            tooltip: 'Switch User',
          ),
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: () {
              incomeController.text = currentMonthIncome > 0
                  ? currentMonthIncome.toStringAsFixed(2)
                  : '';
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Set Monthly Income'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Set your income for ${getMonthYearString()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: incomeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Monthly Income',
                            border: OutlineInputBorder(),
                            prefixText: 'RM',
                            hintText: '0.00',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: setIncome,
                        child: Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Data Storage Info'),
                  content: Text(
                      'Your commitments and income data are saved separately for each user in browser storage and will persist between sessions. Data is stored locally on this device only.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => changeMonth(false),
                  icon: Icon(Icons.arrow_back_ios),
                ),
                Text(
                  getMonthYearString(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => changeMonth(true),
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Income Card
            Card(
              color: widget.selectedUser.color.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly Income',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text('RM${currentMonthIncome.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: widget.selectedUser.color)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: widget.selectedUser.color),
                      onPressed: () {
                        incomeController.text = currentMonthIncome > 0
                            ? currentMonthIncome.toStringAsFixed(2)
                            : '';
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Set Monthly Income'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Set your income for ${getMonthYearString()}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: incomeController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Monthly Income',
                                      border: OutlineInputBorder(),
                                      prefixText: 'RM',
                                      hintText: '0.00',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: setIncome,
                                  child: Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Total Commitments',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          Text('RM${getTotalAmount().toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Paid',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          Text('RM${getPaidAmount().toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Balance Card
            Card(
              color: getBalance() >= 0
                  ? Colors.orange.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text('Balance After Commitments',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text('RM${getBalance().toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: getBalance() >= 0
                                    ? Colors.orange.shade700
                                    : Colors.red.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Commitments List
            currentMonthCommitments.isEmpty
                ? Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No commitments for this month',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                          SizedBox(height: 8),
                          Text(
                              'Click the + button to add your first commitment',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int index = 0;
                          index < currentMonthCommitments.length;
                          index++)
                        Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Checkbox(
                              value: currentMonthCommitments[index].isPaid,
                              onChanged: (_) => toggleCommitmentStatus(
                                  currentMonthCommitments[index].id),
                            ),
                            title: Text(
                              currentMonthCommitments[index].title,
                              style: TextStyle(
                                decoration:
                                    currentMonthCommitments[index].isPaid
                                        ? TextDecoration.lineThrough
                                        : null,
                                color: currentMonthCommitments[index].isPaid
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                                'RM${currentMonthCommitments[index].amount.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteCommitment(
                                  currentMonthCommitments[index].id),
                            ),
                          ),
                        ),
                    ],
                  ),

            // Add some bottom padding for the floating action button
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.selectedUser.color,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add New Commitment'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Commitment Title',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Rent, Phone Bill, etc.',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixText: 'RM',
                        hintText: '0.00',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: addCommitment,
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
