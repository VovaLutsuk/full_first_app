import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/expenses_screen.dart';
import 'screens/income_screen.dart';
import 'autorization/login_screen.dart';
import 'autorization/registration_screen.dart';
import 'autorization/password_recovery_screen.dart';
import 'database.dart';
import 'filter_button.dart'; // Імпортуємо новий файл

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  @override
  _ExpenseTrackerAppState createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  bool isLoggedIn = false;
  int? userId;

  // Функція для авторизації
  void _login(int id) {
    setState(() {
      isLoggedIn = true;
      userId = id;
    });
  }

  // Функція для виходу
  void _logout(BuildContext context) {
    setState(() {
      isLoggedIn = false;
      userId = null;
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Функція для додавання запису
  void _addRecord(Map<String, dynamic> record) {
    DatabaseHelper.addRecord(
      record['user_id'],
      record['type'],
      record['amount'],
      record['currency'],
      record['date'],
      record['description'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Контроль витрат',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(onLogin: _login),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => HomePage(userId: userId!, onLogout: _logout),
        '/expenses': (context) => ExpensesScreen(onAddRecord: _addRecord, userId: userId!),
        '/income': (context) => IncomeScreen(onAddRecord: _addRecord, userId: userId!),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('uk', 'UA'),
        Locale('en', 'US'),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  final int userId;
  final void Function(BuildContext) onLogout;

  HomePage({required this.userId, required this.onLogout});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _records = [];
  FilterState _filterState = FilterState.all;  // Стан фільтрації

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper.getUserRecords(widget.userId);
    setState(() {
      _records = records;
    });
  }

  Future<void> _deleteRecord(int id) async {
    await DatabaseHelper.deleteRecord(id);
    _loadRecords();
  }

  void _changeFilter(FilterState filterState) {
    setState(() {
      _filterState = filterState;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Фільтруємо записи в залежності від вибраного стану фільтру
    List<Map<String, dynamic>> filteredRecords = _records;

    // Для фільтрації використовуємо більш гнучке порівняння
    if (_filterState == FilterState.income) {
      filteredRecords = _records.where((record) =>
          ['прибуток', 'income'].contains(record['type'].toLowerCase())
      ).toList();
    } else if (_filterState == FilterState.expenses) {
      filteredRecords = _records.where((record) =>
          ['витрати', 'expenses'].contains(record['type'].toLowerCase())
      ).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ваші записи'),
        actions: [
          FilterButton(
            filterState: _filterState,
            onFilterChanged: _changeFilter,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              widget.onLogout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/expenses')
                      .then((_) => _loadRecords());
                },
                child: Text('Витрати'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/income')
                      .then((_) => _loadRecords());
                },
                child: Text('Прибутки'),
              ),
            ],
          ),
          Expanded(
            child: filteredRecords.isEmpty
                ? Center(child: Text('Записів немає'))
                : ListView.builder(
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                Icon icon = record['type'].toLowerCase() == 'витрати' ||
                    record['type'].toLowerCase() == 'expenses'
                    ? Icon(Icons.arrow_downward, color: Colors.red)
                    : Icon(Icons.arrow_upward, color: Colors.green);

                return Card(
                  child: ListTile(
                    leading: icon,
                    title: Text('${record['type']}: ${record['amount']} ${record['currency']}'),
                    subtitle: Text('${record['date']} — ${record['description']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.black),
                      onPressed: () {
                        _deleteRecord(record['id']);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
