import 'package:bill_generator/pages/add_categories_page.dart';
import 'package:bill_generator/pages/search_bill_page.dart';
import 'package:bill_generator/pages/menu_screen_page.dart';
import 'package:bill_generator/pages/range_dashboard_page.dart';
import 'package:bill_generator/pages/reports_page.dart';
import 'package:bill_generator/pages/share_images_page.dart';
import 'package:firebase_core/firebase_core.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
          _navigateToPage('History-Paid');
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

  // New method to get AppBar title based on current page
  String _getAppBarTitle() {
    switch (_currentPage) {
      case 'CreateBill':
        return 'Create Bill';
      case 'History-Paid':
        return 'Payment History';
      case 'History-Unpaid':
        return 'Unpaid Bills';
      case 'Reports':
        return 'Reports';
      case 'EditDetails':
        return 'Edit Company Details';
      case 'Share-Media':
        return 'Share Media';
      case 'UpdateBills':
        return 'Update Bills';
      case 'UpdateCategories':
        return 'Manage Categories';
      default:
        return 'Bill Generator'; // Default title
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    switch (_currentPage) {
      case 'CreateBill':
        bodyWidget = CreateBillPage(onBack: () => _navigateToPage('Home'));
        break;
      case 'History-Paid':
        bodyWidget = HistoryPage(payStatusParam: "Paid");
        break;
      case 'History-Unpaid':
        Navigator.pop(context);
        bodyWidget = HistoryPage(payStatusParam: "Unpaid");
        break;
      case 'Reports':
        bodyWidget = ReportsPage();
        break;
      case 'EditDetails':
        bodyWidget = CompanyProfilePage();
        break;
      case 'Share-Media':
        bodyWidget = ShareImagesPage();
        break;
      case 'UpdateBills':
        Navigator.pop(context);
        bodyWidget = SearchBillPage(onNavigate: _navigateToPage);
        break;
      case 'RangeSelector':
        Navigator.pop(context);
        bodyWidget = DateRangeSelectionWidget();
        break;
      case 'UpdateCategories':
        Navigator.pop(context);
        bodyWidget = OperateCategories();
        break;
      default:
        bodyWidget = HomePage(onNavigate: _navigateToPage);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            if (_currentPage == 'CreateBill') {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _navigateToPage('Home'),
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }
          },
        ),
      ),
       drawer: SizedBox(
        width: 250, // Adjust the width here as per your preference
        child: AppDrawer(onNavigate: _navigateToPage),
      ),
      body: bodyWidget,
      bottomNavigationBar: (_currentPage != 'CreateBill')
          ? BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onNavItemTapped,
            )
          : null,
    );
  }
}
