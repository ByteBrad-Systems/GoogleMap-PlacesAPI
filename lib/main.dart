import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:map_widget/blocs/application_bloc.dart';
import 'package:map_widget/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApplicationBloc(),
      child: GetMaterialApp(
        title: 'Flutter Demo',
        home: MyHomePage(title: 'Map Widget Demo',),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

