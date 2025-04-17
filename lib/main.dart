import 'package:bill_generator/pages/menu_screen_page.dart';
import 'package:bill_generator/pages/reports_page.dart';
import 'package:bill_generator/pages/share_images_page.dart';
import 'package:flutter/material.dart';
import 'package:bill_generator/pages/home_page.dart';
import 'package:bill_generator/pages/create_bill_page.dart';
import 'package:bill_generator/pages/history_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bill_generator/widgets/bottom_nav_bar.dart'; // Import the new widget
import 'package:bill_generator/widgets/app_drawer.dart'; // Import the new widget

// Define the main color as a constant
const Color kMainColor = Color(0xFF1A66BE);

void main() async {
  await dotenv.load(fileName: ".env");
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
          backgroundColor: kMainColor,
          surfaceTintColor: kMainColor,
          elevation: 3,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
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

  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
    });
    // Navigator.pop(context);
  }

  void _onNavItemTapped(int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    switch (_currentPage) {
      case 'CreateBill':
        bodyWidget = CreateBillPage(onBack: () => _navigateToPage('Home'));
        break;
      case 'History':
        bodyWidget = HistoryPage();
        break;
      case 'Reports':
        bodyWidget = ReportsPage();
        break;
      case 'EditDetails':
        bodyWidget = MenuScreen();
        break;
      case 'Share-Media':
        bodyWidget = ShareImagesPage();
        break;
      default:
        bodyWidget = HomePage(onNavigate: _navigateToPage);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Generator'),
        centerTitle: true,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: AppDrawer(onNavigate: _navigateToPage),
      body: bodyWidget,
      bottomNavigationBar:
          (_currentPage != 'CreateBill')
              ? BottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onNavItemTapped,
              )
              : null,
    );
  }
}
