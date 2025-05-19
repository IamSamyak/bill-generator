import 'package:bill_generator/models/ShopDetail.dart';
import 'package:bill_generator/pages/add_categories_page.dart';
import 'package:bill_generator/pages/search_bill_page.dart';
import 'package:bill_generator/pages/shop_info_page.dart';
import 'package:bill_generator/pages/range_dashboard_page.dart';
import 'package:bill_generator/pages/reports_page.dart';
import 'package:bill_generator/pages/splash_screen.dart';
import 'package:bill_generator/services/company_profile_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bill_generator/pages/home_page.dart';
import 'package:bill_generator/pages/create_bill_page.dart';
import 'package:bill_generator/pages/history_page.dart';
import 'package:bill_generator/widgets/bottom_nav_bar.dart';
import 'package:bill_generator/widgets/app_drawer.dart';
import 'package:bill_generator/constants.dart';
import 'package:bill_generator/services/page_navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          surfaceTintColor: primaryColor,
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
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      home: const SplashScreen(),
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
  ShopDetail? _shopDetail;
  final CompanyProfileService _companyProfileService = CompanyProfileService();

  @override
  void initState() {
    super.initState();
    _loadShopDetails();
  }

  Future<void> _loadShopDetails() async {
    final details = await _companyProfileService.fetchShopDetails();
    if (details != null) {
      setState(() {
        _shopDetail = details;
      });
    }
  }

  void _onNavItemTapped(int index) {
    final page = PageNavigationService.getPageFromNavIndex(index);
    _navigateToPage(page);
  }

  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
      _selectedIndex = PageNavigationService.getNavIndexFromPage(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = PageNavigationService.getAppBarTitle(_currentPage);
    Widget bodyWidget;

    switch (_currentPage) {
      case 'CreateBill':
        bodyWidget = CreateBillPage(onBack: () => _navigateToPage('Home'));
        break;
      case 'History-Paid':
        bodyWidget = HistoryPage(payStatusParam: "Paid");
        break;
      case 'History-Unpaid':
        bodyWidget = HistoryPage(payStatusParam: "Unpaid");
        break;
      case 'Reports':
        bodyWidget = ReportsPage();
        break;
      case 'CompanyProfile':
        bodyWidget = CompanyProfilePage();
        break;
      case 'UpdateBills':
        bodyWidget = SearchBillPage(onNavigate: _navigateToPage);
        break;
      case 'RangeSelector':
        bodyWidget = DateRangeSelectionWidget();
        break;
      case 'UpdateCategories':
        bodyWidget = OperateCategories();
        break;
      default:
        bodyWidget = HomePage(
          onNavigate: _navigateToPage,
          shopName: _shopDetail?.shopName ?? "Akash Men's Wear",
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
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
        width: 250,
        child: AppDrawer(onNavigate: _navigateToPage),
      ),
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
