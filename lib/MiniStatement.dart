import 'dart:convert';

import 'package:bankapi/Dashboard.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'SessionManagement.dart';

class MiniStatement extends StatefulWidget {
  @override
  _MiniStatementState createState() => _MiniStatementState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _MiniStatementState extends State<MiniStatement> {
  String phone = '';
  String accountNo = '';
  String balance = '';
  String userId = '';
  List<dynamic> transactionHistory = [];
  List<dynamic> transactionHistory1Month = [];
  List<dynamic> transactionHistory6Month = [];
  bool isLoading = true; // Added isLoading flag

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
        phone = userData['mobile'];
      });
      setState(() {
        userId = userData['id'].toString();
      });
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
        getAccountStatement();
      } else {}
    } else {
      // Login failed, handle the error here
      print('Login failed!');
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> getAccountStatement() async {
    String phoneNo = phone;
    String urlBuilder = URL + 'fetchTransactionHistory';
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
        dynamic data2 = responseBody['data'];
        //print("Account Data ==" + data2.toString());
        setState(() {
          transactionHistory = List.from(data2); // Convert to List<dynamic>
        });
        getAccountStatement1Month();
      } else {}
    } else {
      // Login failed, handle the error here
      print('Login failed!');
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> getAccountStatement1Month() async {
    String phoneNo = phone;
    String urlBuilder = URL + 'fetchTransactionHistoryLastMonth';
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
        dynamic data2 = responseBody['data'];
        //print("Account Data ==" + data2.toString());
        setState(() {
          transactionHistory1Month =
              List.from(data2); // Convert to List<dynamic>
        });
        getAccountStatement6Month();
      } else {}
    } else {
      // Login failed, handle the error here
      print('Login failed!');
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> getAccountStatement6Month() async {
    String phoneNo = phone;
    String urlBuilder = URL + 'fetchTransactionHistorySixMonth';
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
        dynamic data2 = responseBody['data'];
        //print("Account Data ==" + data2.toString());
        setState(() {
          transactionHistory6Month =
              List.from(data2); // Convert to List<dynamic>
        });
        setState(() {
          isLoading =
              false; // Set isLoading to false when the response is received
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
        title: Text('Mini Statement'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          },
        ),
      ),
      drawer: Menu(),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Display loading indicator while isLoading is true
          : DefaultTabController(
              length: 3, // Number of tabs
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        child: Text(
                          'Last 10',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Last Months',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Last 6 Months',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildTransactionList10Tranx(
                            transactionHistory), // Last 10 Transactions
                        buildTransactionList1MonthTranx(
                            transactionHistory1Month), // Last 6 Months Transactions
                        buildTransactionList6MonthsTranx(
                            transactionHistory6Month), // Last 1 Year Transactions
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTransactionList10Tranx(List<dynamic> transactions) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> transaction = transactions[index];
          String status = transaction['transactionStatus'];
          return Card(
            child: ListTile(
              leading: getTransactionStatusIcon(status),
              title: Text('${transaction['transactionDate']}'),
              subtitle: Text('${transaction['transactionDetails']}'),
              trailing: Text('₹ ${transaction['transactionAmount']}'),
            ),
          );
        },
      ),
    );
  }

  Widget buildTransactionList1MonthTranx(List<dynamic> transactions) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> transaction = transactions[index];
          String status = transaction['transactionStatus'];
          return Card(
              child: ListTile(
            leading: getTransactionStatusIcon(status),
            title: Text('${transaction['transactionDate']}'),
            subtitle: Text('${transaction['transactionDetails']}'),
            trailing: Text('₹ ${transaction['transactionAmount']}'),
          ));
        },
      ),
    );
  }

  Widget buildTransactionList6MonthsTranx(List<dynamic> transactions) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> transaction = transactions[index];
          String status = transaction['transactionStatus'];
          return Card(
            child: ListTile(
              leading: getTransactionStatusIcon(status),
              title: Text('${transaction['transactionDate']}'),
              subtitle: Text('${transaction['transactionDetails']}'),
              trailing: Text('₹ ${transaction['transactionAmount']}'),
            ),
          );
        },
      ),
    );
  }

  Widget getTransactionStatusIcon(String status) {
    if (status == 'Success') {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else if (status == 'Fail') {
      return Icon(
        Icons.cancel,
        color: Colors.red,
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
