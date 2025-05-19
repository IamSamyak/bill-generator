import 'package:flutter/material.dart';
import 'package:bill_generator/pages/create_bill_page.dart';
import 'package:bill_generator/pages/history_page.dart';
import 'package:bill_generator/pages/reports_page.dart';
import 'package:bill_generator/pages/shop_info_page.dart';
import 'package:bill_generator/pages/search_bill_page.dart';
import 'package:bill_generator/pages/range_dashboard_page.dart';
import 'package:bill_generator/pages/add_categories_page.dart';
import 'package:bill_generator/pages/home_page.dart';
import 'package:bill_generator/models/ShopDetail.dart';

class PageNavigationService {
  // Returns the AppBar title based on the page key
  static String getAppBarTitle(String page) {
    switch (page) {
      case 'CreateBill':
        return 'Create Bill';
      case 'History-Paid':
        return 'Payment History';
      case 'History-Unpaid':
        return 'Unpaid Bills';
      case 'Reports':
        return 'Reports';
      case 'CompanyProfile':
        return 'Edit Company Details';
      case 'Share-Media':
        return 'Share Media';
      case 'UpdateBills':
        return 'Update Bills';
      case 'UpdateCategories':
        return 'Manage Categories';
      default:
        return 'Bill Generator';
    }
  }
  
  // Converts bottom nav index to page name
  static String getPageFromNavIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'History-Paid';
      case 2:
        return 'Reports';
      case 3:
        return 'CompanyProfile';
      default:
        return 'Home';
    }
  }

  // Converts page name to bottom nav index
  static int getNavIndexFromPage(String page) {
    switch (page) {
      case 'Home':
        return 0;
      case 'History-Paid':
        return 1;
      case 'Reports':
        return 2;
      case 'CompanyProfile':
        return 3;
      default:
        return 0;
    }
  }
}
