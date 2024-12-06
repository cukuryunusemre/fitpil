import 'package:flutter/material.dart';

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmButtonText,
  required String cancelButtonText,
  required VoidCallback onConfirm,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Diyaloğu kapat
              onConfirm(); // Onay işlemini çalıştır
            },
            child: Text(confirmButtonText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Diyaloğu kapat
              // İptal işlemini çalıştır
            },
            child: Text(cancelButtonText),
          ),
        ],
      );
    },
  );
}
