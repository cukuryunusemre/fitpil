import 'package:flutter/material.dart';

class SnackbarHelper {
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info_outline, // Varsayılan ikon
    Color backgroundColor = Colors.blueAccent, // Varsayılan arka plan rengi
    Duration duration = const Duration(seconds: 3), // Varsayılan süre
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white), // İkon
            SizedBox(width: 10), // İkon ve metin arası boşluk
            Expanded(
              child: Text(
                message,
                style:
                    TextStyle(color: Colors.white, fontSize: 16), // Metin stili
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor, // Arka plan rengi
        behavior: SnackBarBehavior.floating, // Yüzer tasarım
        margin: EdgeInsets.all(16), // Kenar boşlukları
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Köşe yuvarlaklıkları
        ),
        duration: duration, // Görünme süresi
      ),
    );
  }
}

// SnackbarHelper.show(
// context,
// message: 'Kamera izni gerekli!',
// icon: Icons.camera_alt_outlined,
// backgroundColor: Colors.redAccent,
// );
