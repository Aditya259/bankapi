import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:bankapi/AccountDetails.dart';
import 'package:bankapi/AddBenifitiary.dart';
import 'package:bankapi/Donation.dart';
import 'package:bankapi/MiniStatement.dart';
import 'package:bankapi/ScanAndPay.dart';
import 'package:bankapi/TransferMoney.dart';
import 'package:bankapi/ViewBalance.dart';
import 'package:bankapi/WithInBankTransfer.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'LoanOffer.dart';
import 'Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SessionManagement.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _DashboardState extends State<Dashboard> {
  String fullName = '';
  String phone = '';
  String accountNo = '';
  String balance = '';
  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    getUserDataFromJson();
  }

  Future<void> getUserDataFromJson() async {
    String? userDataJson = await getDataFromSession('userData');
    if (userDataJson != null) {
      Map<String, dynamic> userData = json.decode(userDataJson);
      setState(() {
        fullName = userData['fullName'];
      });
      setState(() {
        phone = userData['mobile'];
      });

      print(userData); // Output: Aditya Malviya
      getMappedAccountNumberToLoginUser();
    }
  }

  Future<void> getMappedAccountNumberToLoginUser() async {
    String phoneNo = phone;
    String urlBuilder = URL + 'getMappedAccountNumberToLoginUser';
    Uri url = Uri.parse(urlBuilder);
    Map<String, String> data = {'phone': phoneNo};
    String jsonData = json.encode(data);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    http.Response response =
        await http.post(url, headers: headers, body: jsonData);
    if (response.statusCode == 200) {
      print('Login successful!');
      Map<String, dynamic> responseBody = json.decode(response.body);
      String status = responseBody['status'];
      String message = responseBody['message'];
      if (status == 'SUCCESS') {
        Map<String, dynamic> data2 = responseBody['data'];
        print("Account Data ==" + data2.toString());
        String accountNoData = data2['accountNo'];
        String balanceData = data2['openingBalance'];
        setState(() {
          accountNo = accountNoData;
        });
        setState(() {
          balance = balanceData;
        });
      } else {}
    } else {
      // Login failed, handle the error here
      print('Login failed!');
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: Menu(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, ' + fullName!, // Replace with the user's name
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 180,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details', // Replace with the account number
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    if (accountNo
                        .isEmpty) // Show loader if account number is empty
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    else
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Account No.: ',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    accountNo, // Replace with the account number
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 8),
                    if (balance.isEmpty) // Show loader if balance is empty
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    else
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Balance: ',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              TextSpan(
                                text: '\₹ ',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    balance, // Replace with the account balance
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side:
                      BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
                elevation: 4,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child: _buildGridItem('Loan Offer', Icons.table_view, () {
                        // Handle Loan Offer item click
                        print('Loan Offer clicked');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoanOffer()),
                        );
                      }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child: _buildGridItem(
                          'Donation', Icons.volunteer_activism, () {
                        // Handle Loan Offer item click
                        print('Donation');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Donation()),
                        );
                      }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child: _buildGridItem(
                          'View Balance', Icons.account_balance_wallet, () {
                        // Handle Loan Offer item click
                        print('View Balance');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewBalance()),
                        );
                      }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child:
                          _buildGridItem('Transfer Money', Icons.payment, () {
                        // Handle Loan Offer item click
                        print('Transfer Money');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TransferMoney()),
                        );
                      }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child: _buildGridItem(
                          'Add Benifitiary', Icons.supervised_user_circle, () {
                        // Handle Loan Offer item click
                        print('Add Benifitiary');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddBenifitiary()),
                        );
                      }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child: _buildGridItem('Scan & Pay', Icons.qr_code_scanner,
                          () {
                        // Handle Loan Offer item click
                        print('Scan & Pay');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ScanAndPay()),
                        );
                      }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child: _buildGridItem(
                          'WithIn Bank Transfer', Icons.account_balance, () {
                        // Handle Loan Offer item click
                        print('WithIn Bank Transfer');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WithInBankTransfer()),
                        );
                      }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child: _buildGridItem('Mini Statment', Icons.article, () {
                        // Handle Loan Offer item click
                        print('Mini Statement');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MiniStatement()),
                        );
                      }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                          right: BorderSide(
                              width: 2,
                              color: const Color.fromARGB(255, 231, 212, 212)),
                        ),
                      ),
                      child: _buildGridItem(
                          'Account Details', Icons.assignment_ind, () {
                        // Handle Loan Offer item click
                        print('Account Details');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountDetails()),
                        );
                      }),
                    ),
                  ],
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _buildGridItem(
      String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Color.fromARGB(120, 29, 99, 230),
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 0, 0),
                // Use the desired shade of pink
              ),
            ),
          ],
        ),
      ),
    );
  }
}
