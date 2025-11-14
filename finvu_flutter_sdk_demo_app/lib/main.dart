import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/finvu_bloc.dart';
import 'constants/routes.dart';
import 'pages/home_page.dart';
import 'pages/discover_accounts_page.dart';
import 'pages/linked_accounts_page.dart';
import 'pages/discovered_accounts_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinvuBloc(),
      child: SafeArea(
        child: MaterialApp(
          title: 'Finvu Flutter SDK Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: Routes.home,
          routes: {
            Routes.home: (context) => const HomePage(),
            Routes.discoverAccounts: (context) => const DiscoverAccountsPage(),
            Routes.linkedAccounts: (context) => const LinkedAccountsPage(),
            Routes.discoveredAccounts: (context) =>
                const DiscoveredAccountsPage(),
          },
        ),
      ),
    );
  }
}
