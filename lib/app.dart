import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/screens/home_screen.dart';
import 'package:esolar_app/screens/login_screen.dart';
import 'package:esolar_app/screens/projects/addMaterial_screen.dart';
import 'package:esolar_app/screens/projects/addProject_screen.dart';
import 'package:esolar_app/screens/projects_screen.dart';
import 'package:esolar_app/screens/settingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  List<Widget> items = [
    HomeScreen(),
    ProjectsScreen(),
    SettingsScreen(), // Substitua o Center(child: Text("Oi")) por SettingsScreen()
  ];

  Future<void> verifyLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('user');
    if (id == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }



  int selected = 0;

  void changeMenu(i) {
    setState(() {
      selected = i;
    });
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    verifyLogin();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: items[selected]),
      floatingActionButton: selected == 1
          ? SpeedDial(
              direction: SpeedDialDirection.left,
              overlayColor: Colors.black,
              icon: Icons.add,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              activeIcon: Icons.close,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.folder_outlined),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddprojectScreen(),
                      ),
                    );
                  },
                  label: "Projeto",
                ),
                SpeedDialChild(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMaterialScreen(),
                      ),
                    );
                  },
                  child: Icon(Icons.construction_outlined),
                  label: "Material",
                ),
              ],
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
