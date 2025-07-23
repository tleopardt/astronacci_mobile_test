import 'package:astronacci_mobile_test/screens/App/profile/profile_screen.dart';
import 'package:astronacci_mobile_test/screens/App/user/user_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          // appBar: AppBar(),
          body: const TabBarView(
            children: [
              UserList(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Material(
            elevation: 12, // adds shadow
            child: SizedBox(
              height: 80, // custom height
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.home_outlined)),
                  Tab(icon: Icon(Icons.person_2_outlined)),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.transparent, // optional
              ),
            ),
          ),
        ),
      ),
    );
  }
}
