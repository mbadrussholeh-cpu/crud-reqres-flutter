import 'package:flutter/material.dart';

import 'screens/user_list_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'CRUD reqres.in',
debugShowCheckedModeBanner: false,
theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
home: const UserListPage(),
);
}
}
