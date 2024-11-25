import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> requestBodySensorsPermission() async {
  var status = await Permission.sensors.status;

  if (status.isDenied) {
    // İzin talebi
    var result = await Permission.sensors.request();
    if (result.isGranted) {
      print("Body Sensors izni verildi.");
    } else {
      print("Body Sensors izni reddedildi.");
    }
  } else if (status.isPermanentlyDenied) {
    print("Body Sensors izni kalıcı olarak reddedildi. Ayarlara yönlendirin.");
    await openAppSettings();
  } else if (status.isGranted) {
    print("Body Sensors izni zaten verilmiş.");
  }
}

Future<void> requestCameraPermission() async {
  var status = await Permission.camera.status;

  if (status.isDenied) {
    // İzin talebi
    var result = await Permission.camera.request();
    if (result.isGranted) {
      print("Kamera izni verildi.");
    } else {
      print("Kamera izni reddedildi.");
    }
  } else if (status.isPermanentlyDenied) {
    print("Kamera izni kalıcı olarak reddedildi. Ayarlara yönlendirin.");
    await openAppSettings();
  } else if (status.isGranted) {
    print("Kamera izni zaten verilmiş.");
  }

}

Future<void> requestStoragePermission() async{
  var status = await Permission.storage.status;

  if (status.isDenied) {
    // İzin talebi
    var result = await Permission.storage.request();
    if (result.isGranted) {
      print("Dosya izni verildi.");
    } else {
      print("Dosya izni reddedildi.");
    }
  } else if (status.isPermanentlyDenied) {
    print("Dosya izni kalıcı olarak reddedildi. Ayarlara yönlendirin.");
    await openAppSettings();
  } else if (status.isGranted) {
    print("Dosya izni zaten verilmiş.");
  }
}


