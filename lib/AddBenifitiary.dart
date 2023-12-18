import 'dart:convert';

import 'package:bankapi/Dashboard.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'SessionManagement.dart';

class AddBenifitiary extends StatefulWidget {
  @override
  _AddBenifitiaryState createState() => _AddBenifitiaryState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _AddBenifitiaryState extends State<AddBenifitiary> {
  String phone = '';
  String userId = '';
  TextEditingController _beniAccNo = TextEditingController();
  TextEditingController _beniName = TextEditingController();
  TextEditingController _beniIfscCode = TextEditingController();
  List<dynamic> listOfBeneficiary = [];
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
      getAllBeneficiaryMaster();
    }
  }

  Future<void> getAllBeneficiaryMaster() async {
    String urlBuilder = URL + 'getAllBeneficiaryMaster';
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
          listOfBeneficiary = data2;
        });
      } else {
        // Handle error
      }
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
    print('Donation Account Numbers: $listOfBeneficiary');
  }

  Future<void> _submit() async {
    String beniAccNo = _beniAccNo.text.trim();
    String beniName = _beniName.text.trim();
    String beniIfscCode = _beniIfscCode.text.trim();
    if (beniAccNo.isEmpty || beniName.isEmpty || beniIfscCode.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Required Fields Missing'),
            content: Text(
                'Please enter the Beneficiary Account and Beneficiary Name and Beneficiary IFSC.'),
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
    String urlBuilder = URL + 'saveBenifitiary';
    Uri url = Uri.parse(urlBuilder);
    Map<String, String> data = {
      'phone': phone,
      'beniAccNo': beniAccNo,
      'beniName': beniName,
      'beniIfscCode': beniIfscCode
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
        //String transactionId = responseBody['data'];
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Beneficiary Added'),
              content: Text('Kindly Wait 2 Hours To Get Beneficiary Approval'),
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
              title: Text('Beneficiary Not Added.Please try after some time.'),
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
          title: Text('Add Benifitiary'),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                TextField(
                  controller: _beniAccNo,
                  decoration: InputDecoration(
                    labelText: 'Beneficiary Account No.',
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _beniName,
                  decoration: InputDecoration(
                    labelText: 'Beneficiary Name',
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _beniIfscCode,
                  decoration: InputDecoration(
                    labelText: 'Beneficiary IFSC',
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Add Beneficiary'),
                ),
                SizedBox(height: 16),
                Text(
                  'List of Beneficiaries:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Column(
                  children: List.generate(listOfBeneficiary.length, (index) {
                    var beneficiary = listOfBeneficiary[index];
                    return Card(
                      child: ListTile(
                        title: Text('${beneficiary['beniName']}'),
                        trailing: beneficiary['beniAccountStatus'] == 'Pending'
                            ? Icon(Icons.pending,
                                color: Color.fromARGB(255, 45, 163, 241))
                            : Icon(Icons.check, color: Colors.green),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
