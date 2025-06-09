import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔹 provider 추가
import 'pages/contact_list_page.dart';
import 'pages/contact_add_page.dart';
import 'pages/contact_detail_page.dart';
import 'pages/contact_edit_page.dart';
import 'app_theme.dart';
import 'models/contact.dart';

import './providers/contact_provider.dart';
import './providers/group_provider.dart';
import './providers/favorite_provider.dart';
import './pages/search_controller.dart';
import './pages/search_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchStateController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '전화번호부 앱',
        // theme: ThemeData(primarySwatch: Colors.blue),
        // theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => ContactListPage());
            case '/add':
              return MaterialPageRoute(builder: (_) => ContactAddPage());
            case '/detail':
              final contact = settings.arguments as Contact;
              return MaterialPageRoute(
                builder: (_) => ContactDetailPage(contact: contact),
              );
            case '/edit':
              final contact = settings.arguments as Contact;
              return MaterialPageRoute(
                builder: (_) => ContactEditPage(contact: contact),
              );
            case '/search':
              // SearchScreen 라우트 추가 (필요하면)
              return MaterialPageRoute(builder: (_) => SearchScreen());
            default:
              return MaterialPageRoute(
                builder:
                    (_) => Scaffold(
                      body: Center(child: Text('알 수 없는 경로: ${settings.name}')),
                    ),
              );
          }
        },
      ),
    );
  }
}
