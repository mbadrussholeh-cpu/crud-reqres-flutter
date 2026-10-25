import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String url;
  final String name;
  final double radius;

  const UserAvatar({
    super.key,
    required this.url,
    required this.name,
    this.radius = 20,
  });

  String get _initials {
    final parts =
    name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(radius: radius, child: Text(_initials));
    if (url.isEmpty) return fallback;

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          // Di web, pakai tag <img> agar tidak terblokir CORS
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }
}