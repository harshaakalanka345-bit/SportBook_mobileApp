
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'toast.dart';
import 'location_service.dart';

/// Opens Google Maps directions / search for [destination] (an address or place name).
Future<void> openDirections(String? destination) async {
  final q = (destination ?? '').trim();
  if (q.isEmpty) {
    toast('This venue has no address on file.');
    return;
  }
  final position = await requestCurrentLocation();
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    if (position != null) 'origin': '${position.latitude},${position.longitude}',
    'destination': q,
    'travelmode': 'driving',
  });
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) toast('Could not open maps.');
}

/// Starts a phone call to [phone].
Future<void> callNumber(String? phone) async {
  final n = (phone ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
  if (n.isEmpty) {
    toast('No phone number available.');
    return;
  }
  if (!await launchUrl(Uri(scheme: 'tel', path: n))) toast('Could not start the call. Number: $phone');
}

Future<void> copyText(String text, {String message = 'Copied to clipboard'}) async {
  await Clipboard.setData(ClipboardData(text: text));
  toast(message);
}

/// Opens the system share sheet (falls back to copying the text if sharing isn't available).
Future<void> shareText(String text, {String? subject}) async {
  try {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  } catch (_) {
    await copyText(text, message: 'Sharing unavailable - copied to clipboard instead');
  }
}

/// Opens a pre-filled Google Calendar event.
Future<void> addToCalendar({required String title, required DateTime start, required DateTime end, String? location, String? details}) async {
  String fmt(DateTime d) {
    final u = d.toUtc();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${u.year}${p(u.month)}${p(u.day)}T${p(u.hour)}${p(u.minute)}${p(u.second)}Z';
  }

  final uri = Uri.https('calendar.google.com', '/calendar/render', {
    'action': 'TEMPLATE',
    'text': title,
    'dates': '${fmt(start)}/${fmt(end)}',
    'location': ?location,
    'details': ?details,
  });
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) toast('Could not open the calendar.');
}

/// Opens a WhatsApp chat with [number] (international format, digits only) and a pre-filled [message].
Future<void> openWhatsApp(String number, String message) async {
  final n = number.replaceAll(RegExp(r'[^0-9]'), '');
  if (n.isEmpty) {
    toast('WhatsApp support is not set up yet.');
    return;
  }
  final uri = Uri.https('wa.me', '/$n', {'text': message});
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) toast('Could not open WhatsApp.');
}

/// Opens the mail app with a pre-filled message.
Future<void> sendEmail(String to, {String subject = '', String body = ''}) async {
  if (to.trim().isEmpty) {
    toast('Support email is not set up yet.');
    return;
  }
  final uri = Uri(scheme: 'mailto', path: to, queryParameters: {'subject': subject, 'body': body});
  if (!await launchUrl(uri)) toast('Could not open your mail app. Write to $to');
}

/// Shares a generated file (e.g. a PDF report) through the system share sheet.
Future<void> shareFileBytes(List<int> bytes, String fileName, String mimeType, {String? text}) async {
  try {
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(Uint8List.fromList(bytes), mimeType: mimeType, name: fileName)],
      fileNameOverrides: [fileName],
      text: text,
    ));
  } catch (e) {
    toast('Could not share the file: $e');
  }
}
