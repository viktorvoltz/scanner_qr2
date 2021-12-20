import 'dart:async';

import 'package:flutter/material.dart';

import '../generate_qr.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 10), 
      () => Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (context) => MyHome())
      )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: Text('scanner_Qr', style: TextStyle(fontSize: 18, color: Colors.white),),
          decoration: BoxDecoration(
            color: Colors.black
          ),
        )
      ),
    );
  }
}

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QRViewExample(),
                ));
              },
              child: const Text('qrView'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GenerateQRPage(),
                ));
              },
              child: const Text('Generate QR'),
            ),
          ),
        ],
      ),
    );
  }
}