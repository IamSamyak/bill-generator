import 'package:bill_generator/pages/reports_page.dart';
import 'package:flutter/material.dart';
import 'package:bill_generator/pages/home_page.dart';
import 'package:bill_generator/pages/create_bill_page.dart';
import 'package:bill_generator/pages/history_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Generator',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 3,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 5,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _currentPage = 'Home';

  final List<Map<String, dynamic>> initialBills = [
    {'name': 'Ravi Kumar', 'date': '2024-07-25', 'amount': 1500, 'status': 'Paid'},
    {'name': 'Sneha Verma', 'date': '2024-07-22', 'amount': 2300, 'status': 'Unpaid'},
    {'name': 'Amit Sharma', 'date': '2024-06-15', 'amount': 1800, 'status': 'Paid'},
    {'name': 'Neha Joshi', 'date': '2024-06-10', 'amount': 2700, 'status': 'Unpaid'},
    {'name': 'Rajesh Kumar', 'date': '2024-05-20', 'amount': 3200, 'status': 'Paid'},
    {'name': 'Priya Mehta', 'date': '2024-04-18', 'amount': 2900, 'status': 'Unpaid'},
  ];

  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    switch (_currentPage) {
      case 'CreateBill':
        bodyWidget = CreateBillPage(onBack: () => _navigateToPage('Home'));
        break;
      case 'History':
        bodyWidget = HistoryPage(onBack: () => _navigateToPage('Home'), initialBills: initialBills);
        break;
      case 'Reports':
        bodyWidget = ReportsPage(initialBills: initialBills, onBack: () => _navigateToPage('Home'));
        break;
      default:
        bodyWidget = HomePage(onNavigate: _navigateToPage);
    }

    return Scaffold(
      appBar: (_currentPage == 'Home')
          ? AppBar(
              title: const Text('Waghmare Stores'),
              centerTitle: true,
            )
          : null,
      body: bodyWidget,
      bottomNavigationBar: (_currentPage == 'Home')
          ? BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payment),
                  label: "Today's Collection",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  label: 'Edit Details',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )
          : null,
    );
  }
}
