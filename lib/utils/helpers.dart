import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getInitials(String name) {
  final parts = name.trim().split(' ');
  
  if (parts.length == 1) return parts.first[0].toUpperCase();

  return (parts.first[0] + parts.last[0]).toUpperCase();
}

Color generateRandomColor(String input) {
  final hash = input.hashCode;

  final r = (hash & 0xFF0000) >> 16;
  final g = (hash & 0x00FF00) >> 8;
  final b = (hash & 0x0000FF);

  return Color.fromARGB(204, r, g, b);
}

String formatBirthDate(String dateString) {
  try {
    final parsedDate = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(parsedDate); // e.g. 21 Jun 2004
  } catch (e) {
    return dateString; // fallback if parsing fails
  }
}


