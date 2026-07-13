import 'package:flutter/material.dart';

class NetworkQrImage extends StatelessWidget {
  const NetworkQrImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      key: const Key('sepay-network-qr'),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Text('Khong the tai ma QR'),
      ),
    );
  }
}
