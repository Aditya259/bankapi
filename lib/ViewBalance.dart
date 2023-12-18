import 'dart:convert';

import 'package:bankapi/Dashboard.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'SessionManagement.dart';

class ViewBalance extends StatefulWidget {
  @override
  _ViewBalanceState createState() => _ViewBalanceState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _ViewBalanceState extends State<ViewBalance> {
  String phone = '';
  String accountNo = '';
  String balance = '';
  String userId = '';
  List<dynamic> transactionHistory = [];
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
        title: Text('Balance'),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                //style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: 'Account Number : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: accountNo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                //style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: 'Available Balance: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '₹' + balance,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Transaction History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Last 10 Transactions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Display loading indicator while isLoading is true
                  : ListView.builder(
                      itemCount: transactionHistory.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> transaction =
                            transactionHistory[index];
                        String status = transaction['transactionStatus'];
                        return ListTile(
                          leading: getTransactionStatusIcon(status),
                          title: Text('${transaction['transactionDate']}'),
                          subtitle:
                              Text('${transaction['transactionDetails']}'),
                          trailing:
                              Text('₹ ${transaction['transactionAmount']}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
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
