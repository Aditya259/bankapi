import 'package:bankapi/AccountDetails.dart';
import 'package:bankapi/AddBenifitiary.dart';
import 'package:bankapi/Donation.dart';
import 'package:bankapi/LoanOffer.dart';
import 'package:bankapi/LoginPage.dart';
import 'package:bankapi/MiniStatement.dart';
import 'package:bankapi/ScanAndPay.dart';
import 'package:bankapi/TransferMoney.dart';
import 'package:bankapi/ViewBalance.dart';
import 'package:bankapi/WithInBankTransfer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dashboard.dart';
import 'SessionManagement.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 20, // Specify the desired height
          ),

          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.table_view),
            title: Text('Loan Offer'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoanOffer()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.volunteer_activism),
            title: Text('Donation'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Donation()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('View Balance'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ViewBalance()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Transfer Money'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TransferMoney()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.supervised_user_circle),
            title: Text('Add Benifitiary'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddBenifitiary()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.qr_code_scanner),
            title: Text('Scan & Pay'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ScanAndPay()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('WithIn Bank Transfer'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WithInBankTransfer()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.article),
            title: Text('Mini Statement'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MiniStatement()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_ind),
            title: Text('Account Details'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AccountDetails()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              clearSessionData();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          // Add more ListTile widgets for additional menu items
        ],
      ),
    );
  }
}
