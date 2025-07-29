import 'dart:convert';

import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:esolar_app/screens/projects/projectDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool loaded = false;
  var projects;

  Future<void> firstLoad() async {
    var url = Uri.parse(Urls().url['getProjects']!);
    var response = await http.get(url);
    if(mounted){
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
                Icon(Icons.more_horiz),
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
                          ...projects.map((project) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailsScreen(project: project)));
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            project['PROJECT_NAME'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            project['CLIENT_NAME'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          child: Text(
                                            project['GOAL'],
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined),
                                            SizedBox(width: 5),
                                            Container(
                                              child: Text(
                                                project['ADDRESS'],
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 7),
                                        Row(
                                          children: [
                                            Icon(Icons.timeline),
                                            SizedBox(width: 5),
                                            Container(
                                              child: Text(
                                                project['STATE'],
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 7),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            );
                          }),
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
