import 'dart:convert';

import 'package:bankapi/Dashboard.dart';
import 'package:bankapi/LoanOffer.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'Menu.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoanDetailsScreen extends StatefulWidget {
  final int loanId;

  const LoanDetailsScreen({required this.loanId});

  @override
  _LoanDetailsScreenState createState() => _LoanDetailsScreenState();
}

Future<void> _initializeSharedPreferences() async {
  await SharedPreferences.getInstance();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  String phone = '';
  Map<String, dynamic> loanData = {};
  Map<String, dynamic> temp = {};
  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    getLoanMasterDataById();
  }

  Future<void> getLoanMasterDataById() async {
    String loanId = widget.loanId.toString();
    String urlBuilder = URL + 'getLoanMasterDataById';
    Uri url = Uri.parse(urlBuilder);
    Map<String, String> data = {'id': loanId};
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
        //String dataJson = json.encode(data2);
        //print("data ===" + dataJson);
        if (data2.isNotEmpty) {
          if (data2['loanName'] != null) {
            temp.putIfAbsent("Loan Name", () => data2['loanName']);
          }
          if (data2['emiCollection'] != null) {
            //emiCollection
            temp.putIfAbsent("EMI Collection", () => data2['emiCollection']);
          }
          //emiType
          if (data2['emiType'] != null) {
            //emiCollection
            temp.putIfAbsent("EMI Type", () => data2['emiType']);
          }
          //roiType
          if (data2['roiType'] != null) {
            //emiCollection
            temp.putIfAbsent("ROI TYPE", () => data2['roiType']);
          }
          //minAge
          if (data2['minAge'] != null) {
            //emiCollection
            temp.putIfAbsent("Minimum Age", () => data2['minAge']);
          }
          //maxAge
          if (data2['maxAge'] != null) {
            //emiCollection
            temp.putIfAbsent("Maximum Age", () => data2['maxAge']);
          }
          //minAmount
          if (data2['minAmount'] != null) {
            //emiCollection
            temp.putIfAbsent("Minimum Amount", () => data2['minAmount']);
          }
          //maxAmount
          if (data2['maxAmount'] != null) {
            //emiCollection
            temp.putIfAbsent("Maximum Amount", () => data2['maxAmount']);
          }
          //minTerm
          if (data2['minTerm'] != null) {
            //emiCollection
            temp.putIfAbsent("Minimum Term", () => data2['minTerm']);
          }
          //maxTer\r\nm
          if (data2['maxTer\r\nm'] != null) {
            //emiCollection
            temp.putIfAbsent("Maximum Term", () => data2['maxTer\r\nm']);
          }
          //securityType
          if (data2['securityType'] != null) {
            //emiCollection
            temp.putIfAbsent("Security Type", () => data2['securityType']);
          }
          //processingFee
          if (data2['processingFee'] != null) {
            //emiCollection
            temp.putIfAbsent("Processing Fee", () => data2['processingFee']);
          }
          //legalAmt
          if (data2['legalAmt'] != null) {
            //emiCollection
            temp.putIfAbsent("Legal Amount", () => data2['legalAmt']);
          }
          //gst
          if (data2['gst'] != null) {
            //emiCollection
            temp.putIfAbsent("GST", () => data2['gst']);
          }
        }
        String dataJson = json.encode(temp);
        setState(() {
          loanData = json.decode(dataJson);
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
          title: Text('Loan Details'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoanOffer()),
              );
            },
          )),
      drawer: Menu(),
      body: ListView.builder(
        itemCount: loanData.length,
        itemBuilder: (context, index) {
          final key = loanData.keys.elementAt(index);
          final value = loanData[key].toString();

          return ListTile(
            title: Text(
              key,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(value),
          );
        },
      ),
    );
  }
}
