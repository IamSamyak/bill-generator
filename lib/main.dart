import 'package:bill_generator/pages/edit_details_page.dart';
import 'package:bill_generator/pages/reports_page.dart';
import 'package:flutter/material.dart';
import 'package:bill_generator/pages/home_page.dart';
import 'package:bill_generator/pages/create_bill_page.dart';
import 'package:bill_generator/pages/history_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define the main color as a constant
const Color kMainColor = Color(0xFF3498DB);

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
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
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 5,
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kMainColor),
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
    {'customer_name': 'Ravi Kumar', 'date': '2024-07-25', 'amount': 1500, 'status': 'Paid', 'contact_number': '9876543210'},
    {'customer_name': 'Sneha Verma', 'date': '2024-07-22', 'amount': 2300, 'status': 'Unpaid', 'contact_number': '8765432109'},
    {'customer_name': 'Amit Sharma', 'date': '2024-06-15', 'amount': 1800, 'status': 'Paid', 'contact_number': '7654321098'},
    {'customer_name': 'Neha Joshi', 'date': '2024-06-10', 'amount': 2700, 'status': 'Unpaid', 'contact_number': '6543210987'},
    {'customer_name': 'Rajesh Kumar', 'date': '2024-05-20', 'amount': 3200, 'status': 'Paid', 'contact_number': '5432109876'},
    {'customer_name': 'Priya Mehta', 'date': '2024-04-18', 'amount': 2900, 'status': 'Unpaid', 'contact_number': '4321098765'},
    {'customer_name': 'Riya Mehta', 'date': '2024-03-18', 'amount': 2900, 'status': 'Unpaid', 'contact_number': '4321098765'},
    {'customer_name': 'Giya Mehta', 'date': '2024-02-18', 'amount': 2900, 'status': 'Unpaid', 'contact_number': '4321098765'},
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
        bodyWidget = HistoryPage(initialBills: initialBills);
        break;
      case 'Reports':
        bodyWidget = ReportsPage(initialBills: initialBills);
        break;
      case 'EditDetails':
        bodyWidget = EditDetailsPage(onBack: () => _navigateToPage('Home'));
        break;
      default:
        bodyWidget = HomePage(onNavigate: _navigateToPage);
    }

    return Scaffold(
      appBar: (_currentPage != 'CreateBill')
          ? AppBar(
              title: const Text('Waghmare Stores'),
              centerTitle: true,
            )
          : null,
      body: bodyWidget,
      bottomNavigationBar: (_currentPage != 'CreateBill')
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded, size: _selectedIndex == 0 ? 30 : 24),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history, size: _selectedIndex == 1 ? 30 : 24),
                      label: 'History',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart_rounded, size: _selectedIndex == 2 ? 30 : 24),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu, size: _selectedIndex == 3 ? 30 : 24),
                      label: 'Menu',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: kMainColor,
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                      switch (index) {
                        case 0:
                          _navigateToPage('Home');
                          break;
                        case 1:
                          _navigateToPage('History');
                          break;
                        case 2:
                          _navigateToPage('Reports');
                          break;
                        case 3:
                          _navigateToPage('EditDetails');
                          break;
                      }
                    });
                  },
                ),
              ],
            )
          : null,
    );
  }
}  