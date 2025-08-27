import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showError(String message, {String title = "Error"}) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.white,
    colorText: Colors.red,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(16),
    duration: Duration(seconds: 3),
  );
}

void showSuccess(String message, {String title = "Success"}) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.green.shade100,
    colorText: Colors.green.shade900,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(16),
    duration: Duration(seconds: 3),
  );
}
