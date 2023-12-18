import 'dart:convert';

import 'package:bankapi/Dashboard.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'SessionManagement.dart';

class Donation extends StatefulWidget {
  @override
  _DonationState createState() => _DonationState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _DonationState extends State<Donation> {
  String phone = '';
  String userId = '';
  late List<dynamic> listOfDonation = [];
  String selectedDonation = '';
  TextEditingController _donationAmount = TextEditingController();

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

      getAllDonationMaster();
    }
  }

  Future<void> getAllDonationMaster() async {
    String urlBuilder = URL + 'getAllDonationMaster';
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
          listOfDonation = data2;
        });
      } else {
        // Handle error
      }
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
    print('Donation Account Numbers: $listOfDonation');
  }

  Future<void> _submit() async {
    String donationAmount = _donationAmount.text.trim();
    String transactionTo = selectedDonation.trim();

    if (donationAmount.isEmpty || transactionTo.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Required Fields Missing'),
            content: Text(
                'Please enter the donation amount and select the donation account.'),
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

    String urlBuilder = URL + 'savedonation';
    Uri url = Uri.parse(urlBuilder);
    Map<String, String> data = {
      'transactionAmount': donationAmount,
      'transactionTo': transactionTo,
      'phone': phone,
      'userId': userId,
      'transactionDetails': "Donation To  $transactionTo",
    };
    String jsonData = json.encode(data);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    http.Response response =
        await http.post(url, headers: headers, body: jsonData);
    if (response.statusCode == 200) {
      print('Donation successful!');
      Map<String, dynamic> responseBody = json.decode(response.body);
      String status = responseBody['status'];
      String message = responseBody['message'];
      if (status == 'SUCCESS') {
        String transactionId = responseBody['data'];
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Donation Successful'),
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
              title: Text('Donation Failed'),
              content: Text('$message \n Transaction ID: $transactionId'),
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
        title: Text('Donation'),
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
                  'Select Donation Account:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: DropdownButton<String>(
                    value: selectedDonation,
                    onChanged: (newValue) {
                      setState(() {
                        selectedDonation = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('Donate To'),
                      ),
                      ...listOfDonation.map((donation) {
                        return DropdownMenuItem<String>(
                          value: donation['accountNo'],
                          child: Text(donation['accountNo']),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _donationAmount,
                  decoration: InputDecoration(
                    labelText: 'Donation Amount',
                  ),
                  //obscureText: true,
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Donate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
