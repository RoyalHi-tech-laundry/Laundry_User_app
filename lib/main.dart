import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_router.dart';
import 'features/cart/view_model/cart_viewmodel.dart';
import 'features/address/view_model/address_list_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => AddressListViewModel()),
      ],
      child: MaterialApp(
      title: 'Laun Easy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRouter.splashRoute,
      onGenerateRoute: AppRouter.generateRoute,
    ),
    );
  }
}
