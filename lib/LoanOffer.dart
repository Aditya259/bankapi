import 'dart:convert';

import 'package:bankapi/Dashboard.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'LoanDetailsScreen.dart';
import 'Menu.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'SessionManagement.dart';

class LoanOffer extends StatefulWidget {
  @override
  _LoanOfferState createState() => _LoanOfferState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _LoanOfferState extends State<LoanOffer> {
  String phone = '';
  List<dynamic> loanOffers = new List.empty();
  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    getAllLoanMaster();
  }

  Future<void> getAllLoanMaster() async {
    String urlBuilder = URL + 'getAllLoanMaster';
    Uri url = Uri.parse(urlBuilder);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    http.Response response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      print('Login successful!');
      Map<String, dynamic> responseBody = json.decode(response.body);
      String status = responseBody['status'];
      String message = responseBody['message'];
      if (status == 'SUCCESS') {
        List<dynamic> data2 = responseBody['data'];
        // print("Account Data ==" + data2.toString());
        setState(() {
          loanOffers = data2;
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
          title: Text('Loan Offers'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            },
          )),
      drawer: Menu(),
      body: ListView.builder(
        itemCount: loanOffers.length,
        itemBuilder: (context, index) {
          final loanOffer = loanOffers[index];
          final loanName = loanOffer['loanName'];
          final id = loanOffer['id'];
          final icon = Icons.document_scanner; // Default icon

          return Card(
            elevation: 2, // Adjust the elevation value as desired
            margin: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16), // Adjust the margin values as desired
            child: Tooltip(
              message: loanName, // Display the loanName as the tooltip message
              child: ListTile(
                leading: Icon(icon, color: Color.fromARGB(120, 29, 99, 230)),
                title: Text(
                  loanName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  print('Selected loan offer ID: $id');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoanDetailsScreen(loanId: id),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
