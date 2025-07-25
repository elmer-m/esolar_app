import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/screens/home_screen.dart';
import 'package:esolar_app/screens/projects/addProject_screen.dart';
import 'package:esolar_app/screens/projects_screen.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  List<Widget> items = [
    HomeScreen(),
    ProjectsScreen(),
    Center(child: Text("Oi")),
  ];

  int selected = 0;

  void changeMenu(i) {
    setState(() {
      selected = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: items[selected]),
      floatingActionButton: selected == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddprojectScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              shape: CircleBorder(),
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 1, color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          onTap: changeMenu,
          selectedItemColor: AppColors.primary,
          currentIndex: selected,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ínicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Projetos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configurações',
            ),
          ],
        ),
      ),
    );
  }
}
