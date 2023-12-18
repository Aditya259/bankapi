import 'dart:convert';

import 'package:bankapi/Dashboard.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'SessionManagement.dart';

class WithInBankTransfer extends StatefulWidget {
  @override
  _WithInBankTransferState createState() => _WithInBankTransferState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _WithInBankTransferState extends State<WithInBankTransfer> {
  String phone = '';
  String userId = '';
  String accountNo = '';
  String balance = '';
  List<dynamic> listOfWithinBankTreansfer = [];
  String? selectedBankAccount;
  String? selectedTransferType = 'Within Bank Transfer';
  TextEditingController _transAmount = TextEditingController();
  TextEditingController _transDetails = TextEditingController();
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
        getAllBankAccountWithinMaster();
      } else {}
    } else {
      // Login failed, handle the error here
      print('Login failed!');
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> getAllBankAccountWithinMaster() async {
    String urlBuilder = URL + 'getAllWithInBankAccount';
    Uri url = Uri.parse(urlBuilder);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    http.Response response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      String status = responseBody['status'];
      if (status == 'SUCCESS') {
        List<dynamic> data2 = responseBody['data'];
        setState(() {
          listOfWithinBankTreansfer = data2;
        });
      } else {
        // Handle error
      }
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
    print('Bank  Data: $listOfWithinBankTreansfer');
  }

  Future<void> _submit() async {
    if (selectedBankAccount == null) {
      selectedBankAccount = '';
    }
    String transactionAmount = _transAmount.text.trim();
    String transactionDetails = _transDetails.text.trim();
    String transactionTo = selectedBankAccount!;
    String transactionType = selectedTransferType!;
    String userIdTemp = userId;
    if (transactionAmount.isEmpty ||
        transactionDetails.isEmpty ||
        transactionTo.isEmpty ||
        transactionType.isEmpty ||
        userIdTemp.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Required Fields Missing'),
            content: Text(
                'Please enter the Transaction Account, Transaction Details cannot be empty or null '),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return; // Stop execution if required fields are missing
    }
    String urlBuilder = URL + 'saveTransactionHistory';
    Uri url = Uri.parse(urlBuilder);
    Map<String, String> data = {
      'phone': phone,
      'transactionAmount': transactionAmount,
      'transactionDetails': transactionDetails,
      'transactionTo': transactionTo,
      'transactionType': transactionType,
      'userId': userId
    };
    String jsonData = json.encode(data);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    http.Response response =
        await http.post(url, headers: headers, body: jsonData);
    if (response.statusCode == 200) {
      print('Benifitiary successful!');
      Map<String, dynamic> responseBody = json.decode(response.body);
      String status = responseBody['status'];
      String message = responseBody['message'];
      if (status == 'SUCCESS') {
        String transactionId = responseBody['data'];
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Transaction Successfully Done'),
              content: Text('Transaction ID: $transactionId'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        String transactionId = responseBody['data'];
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Transaction Failed'),
              content: Text('$message'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle error
      print('Donation failed!');
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer Money'),
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
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer Money',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Transfer To',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: selectedBankAccount,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBankAccount = newValue;
                    });
                  },
                  items: listOfWithinBankTreansfer.map((dynamic bankAccount) {
                    return DropdownMenuItem<String>(
                      value: bankAccount['accountNo'],
                      child: Text(bankAccount['accountNo']),
                    );
                  }).toList(),
                  hint: Text('Select Bank Account No.'),
                  isExpanded: true, // Make the dropdown full width
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _transAmount,
                  decoration: InputDecoration(
                    labelText: 'Transfer Amount',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _transDetails,
                  decoration: InputDecoration(
                    labelText: 'Transaction Details',
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Transfer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
