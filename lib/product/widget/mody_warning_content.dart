import 'package:flutter/material.dart';

// Üret SnackBar'ı ve seçim kartı bildirimi aynı metin/ikon görünümünü kullanır.
class ModyWarningContent extends StatelessWidget {
  const ModyWarningContent({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.error_outline, color: Colors.white, size: 24),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    ],
  );
}
