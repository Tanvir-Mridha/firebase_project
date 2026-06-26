import 'package:flutter/material.dart';

void showSnackBarMassage(BuildContext context, String title){

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));

}