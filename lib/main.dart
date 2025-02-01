import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe/services/connectivity_service.dart';
import 'package:swipe/theme/app_theme.dart';

import 'providers/product_provider.dart';
import 'screens/product_screen.dart';
import 'services/storage_service.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  // await DBService.database;
  await StorageService.initialize();

  WidgetsFlutterBinding.ensureInitialized();
  await ConnectivityService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Product App',
        theme: AppTheme.lightTheme,
        home: ProductListScreen(),
      ),
    );
  }
}
