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
  bool _isCreateBillPage = false;
  bool _isHistoryPage = false;

  void _goToCreateBill() {
    setState(() {
      _isCreateBillPage = true;
      _isHistoryPage = false;
    });
  }

  void _goToHistory() {
    setState(() {
      _isHistoryPage = true;
      _isCreateBillPage = false;
    });
  }

  void _goBackToHome() {
    setState(() {
      _isCreateBillPage = false;
      _isHistoryPage = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isCreateBillPage = false;
      _isHistoryPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (_isCreateBillPage || _isHistoryPage)
          ? null
          : AppBar(
              title: const Text('Waghmare Stores'),
              centerTitle: true,
            ),
      body: _isCreateBillPage
          ? CreateBillPage(onBack: _goBackToHome)
          : _isHistoryPage
              ? HistoryPage(onBack: _goBackToHome)
              : _selectedIndex == 0
                  ? HomePage(onCreateBill: _goToCreateBill, onHistory: _goToHistory)
                  : const Center(child: Text("Other Pages Content")),
      bottomNavigationBar: (_isCreateBillPage || _isHistoryPage)
          ? null
          : BottomNavigationBar(
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
              onTap: _onItemTapped,
            ),
    );
  }
}
