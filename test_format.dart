// ignore_for_file: avoid_print, unused_import
import 'dart:convert';
void main() {
  try {
    int.parse("null");
  } catch (e) {
    print("Test 1: $e");
  }
  try {
    Uri.parse("http://127.0.0.1:8000/api").port;
    print("Test 2: Uri valid");
  } catch (e) {
    print("Test 2: $e");
  }
}
