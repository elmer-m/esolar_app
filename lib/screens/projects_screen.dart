import 'dart:convert';

import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:esolar_app/screens/projects/projectDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool loaded = false;
  var projects;
  var user;
  var company;

  Future<void> firstLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = jsonDecode(prefs.getString('user')!);
      company = jsonDecode(prefs.getString('company')!);
    });
    var url = Uri.parse("${Urls().url['getProjects']!}/${company['ID']}");
    var response = await http.get(url, headers: {'Accept': 'application/json'});
    print(response.body);
    if (mounted) {
      setState(() {
        projects = jsonDecode(response.body)['projects'];
      });
    }
    print(response.body);
  }

  Future<void> oi() async {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstLoad().then((_) {
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              children: [
                Text(
                  "Projetos",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.title,
                  ),
                ),
                Spacer(),
                // Icon(Icons.more_horiz),
              ],
            ),
          ),
          loaded
              ? Expanded(
                  child: RefreshIndicator(
                    elevation: 1,
                    backgroundColor: Colors.white,
                    color: AppColors.primary,
                    onRefresh: () => firstLoad(),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          projects.isEmpty
                              ? Column(
                                  children: [
                                    Center(child: Text("Não há projetos.")),
                                    SizedBox(height: 2000),
                                  ],
                                )
                              : Column(
                                  children: projects.map<Widget>((project) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProjectDetailsScreen(
                                                  project: project,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: AppColors.border,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  project['PROJECT_NAME'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  project['CLIENT_NAME'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  project['GOAL'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Expanded(child: Text(
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      project['ADDRESS'],
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),),
                                                  ],
                                                ),
                                                SizedBox(height: 7),
                                                Row(
                                                  children: [
                                                    Icon(Icons.timeline),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      project['STATE'],
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    );
                                  }).toList(), // ← AQUI
                                ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
        ],
      ),
    );
  }
}
