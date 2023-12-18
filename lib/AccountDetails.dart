import 'dart:convert';

import 'package:bankapi/Dashboard.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'SessionManagement.dart';

class AccountDetails extends StatefulWidget {
  @override
  _AccountDetailsState createState() => _AccountDetailsState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _AccountDetailsState extends State<AccountDetails> {
  String phone = '';
  String accountNo = '';
  String balance = '';
  String userId = '';
  Map<String, dynamic>? userDataGlobal;
  Map<String, dynamic>? bankDetailsGlobal;

  bool isLoading = true; // Add a loading indicator flag

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
      setState(() {
        userDataGlobal = userData;
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
        setState(() {
          bankDetailsGlobal = data2;
          isLoading = false; // Set the loading indicator flag to false
        });
      } else {
        setState(() {
          isLoading = false; // Set the loading indicator flag to false
        });
      }
    } else {
      // Login failed, handle the error here
      print('Login failed!');
      print('Error: ${response.statusCode}');
      setState(() {
        isLoading = false; // Set the loading indicator flag to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Details'),
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
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator(), // Display a loading indicator while data is being fetched
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.0,
                  columns: [
                    DataColumn(
                        label: Text('Account Details ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17))),
                    DataColumn(label: Text(' ')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text(
                        'Full Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(userDataGlobal?['fullName'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'User ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(userDataGlobal?['userId'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Email',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(userDataGlobal?['email'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Mobile',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(userDataGlobal?['mobile'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Branch Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(userDataGlobal?['branchName'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Bank Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(bankDetailsGlobal?['bankName'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Account No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(bankDetailsGlobal?['accountNo'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Mobile No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(bankDetailsGlobal?['mobileNo'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(bankDetailsGlobal?['address'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Opening Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(bankDetailsGlobal?['openingDate'] ?? '')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text(
                        'Balance in ₹',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                          bankDetailsGlobal?['openingBalance']?.toString() ??
                              '')),
                    ]),
                  ],
                ),
              ),
      ),
    );
  }
}
