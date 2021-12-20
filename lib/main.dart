import 'dart:developer';
import 'dart:convert' show utf8;
import 'dart:io';
import 'package:scanner_qr/screens/splashscreen.dart';

import 'generate_qr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import './widget/modalSheet.dart';

void main() => runApp(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );



class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String cameraState = 'Pause';
  late List<int> encoded;

  void toggleCamera() async {
    if (cameraState == 'Pause') {
      try {
        await controller?.pauseCamera();
        setState(() {
          cameraState = 'Resume';
        });
      } catch (error) {
        cameraState = 'Pause';
        print(error);
      }
    } else if (cameraState == 'Resume') {
      try {
        await controller?.resumeCamera();
        setState(() {
          cameraState = 'Pause';
        });
      } catch (error) {
        cameraState = 'Resume';
        print(error);
      }
    }
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 1, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                        'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            icon: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                if (snapshot.data == false) {
                                  return Icon(
                                    Icons.flash_off,
                                    size: 16,
                                  );
                                } else {
                                  return Icon(
                                    Icons.flash_on,
                                    size: 16,
                                  );
                                }
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            icon: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (describeEnum(snapshot.data!) == 'back') {
                                  return Icon(
                                    Icons.camera_rear,
                                    size: 16,
                                  );
                                } else {
                                  return Icon(Icons.camera_front, size: 16);
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: toggleCamera,
                          child:
                              Text(cameraState, style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      result == null
                          ? Container()
                          : Container(
                              margin: const EdgeInsets.all(8),
                              child: TextButton(
                                child: Text('view data',
                                    style: TextStyle(fontSize: 16)),
                                onPressed: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          padding: EdgeInsets.all(20),
                                          height: 200,
                                          child: Text(
                                              'Data: ${utf8.decode(encoded)}'),
                                        );
                                      });
                                },
                              ))
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(
    QRViewController controller,
  ) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        encoded = utf8.encode(result!.code ?? '');
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
