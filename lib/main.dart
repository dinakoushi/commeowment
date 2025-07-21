import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Commeowment',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200), //loading timing
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CommitmentHomePage()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage('assets/images/kitty.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'My Commeowment 🐾',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 220, 36, 174),
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20),
              // CircularProgressIndicator(
              //   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              //   strokeWidth: 3,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class Commitment {
  String id;
  String title;
  double amount;
  bool isPaid;
  DateTime createdAt;

  Commitment({
    required this.id,
    required this.title,
    required this.amount,
    this.isPaid = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Commitment fromJson(Map<String, dynamic> json) {
    return Commitment(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      isPaid: json['isPaid'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class CommitmentHomePage extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    try {
      final storage = html.window.localStorage;
      final dataString = storage['commitments'];
      final incomeString = storage['income'];

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

      storage['commitments'] = jsonEncode(data);
      storage['income'] = jsonEncode(incomeByMonth);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Commeowment  🐾'),
        backgroundColor: const Color.fromARGB(255, 212, 120, 201),
        foregroundColor: Colors.white,
        actions: [
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
                      'Your commitments and income data are saved in browser storage and will persist between sessions. Data is stored locally on this device only.'),
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
      body: Padding(
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
              color: Colors.purple.shade50,
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
                                color: Colors.purple.shade700)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.purple.shade700),
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
            Expanded(
              child: currentMonthCommitments.isEmpty
                  ? Center(
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
                    )
                  : ListView.builder(
                      itemCount: currentMonthCommitments.length,
                      itemBuilder: (context, index) {
                        final commitment = currentMonthCommitments[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Checkbox(
                              value: commitment.isPaid,
                              onChanged: (_) =>
                                  toggleCommitmentStatus(commitment.id),
                            ),
                            title: Text(
                              commitment.title,
                              style: TextStyle(
                                decoration: commitment.isPaid
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: commitment.isPaid ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Text(
                                'RM${commitment.amount.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteCommitment(commitment.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
        child: Icon(Icons.add),
      ),
    );
  }
}
