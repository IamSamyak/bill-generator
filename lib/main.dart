import 'package:flutter/material.dart';
import 'package:bill_generator/pages/home_page.dart';
import 'package:bill_generator/pages/create_bill_page.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  void _goToCreateBill() {
    setState(() {
      _isCreateBillPage = true;
    });
  }

  void _goBackToHome() {
    setState(() {
      _isCreateBillPage = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isCreateBillPage = false; // Ensure we return to the main pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isCreateBillPage
          ? null
          : AppBar(
              title: const Text('Waghmare Stores'),
            ),
      body: _isCreateBillPage
          ? CreateBillPage(onBack: _goBackToHome)
          : _selectedIndex == 0
              ? HomePage(onCreateBill: _goToCreateBill)
              : const Center(child: Text("Other Pages Content")),
      bottomNavigationBar: _isCreateBillPage
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
              selectedItemColor: Colors.blue,
              onTap: _onItemTapped,
            ),
    );
  }
}
