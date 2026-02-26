import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String number) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: number);

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    debugPrint('Could not launch $phoneUri');
  }
}
