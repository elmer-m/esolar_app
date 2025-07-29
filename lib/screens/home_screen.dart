import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:esolar_app/screens/projects/projectDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loaded = false;
  bool hasProject = true;
  var user;
  var company;
  var project;

  Future<void> getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = jsonDecode(prefs.getString('user')!);
      company = jsonDecode(prefs.getString('company')!);
    });
    try {
      var url = Uri.parse("${Urls().url['getHomeInfo']!}/${company['ID']}");
      var response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      var data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          hasProject = data['has'];
          project = data['project'];
          loaded = true;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Olá " +
                ((user != null && user['name'] != null)
                    ? (user['name'].contains(' ')
                          ? user['name'].split(' ')[0]
                          : user['name'])
                    : "visitante"),
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.title,
            ),
          ),
          Row(
            children: [
              Text(
                "Bem vindo a ",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.title,
                ),
              ),
              Text(
                company != null ? company['NAME'] : '',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (hasProject && project != null)
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 20),
              child: Text(
                "Próxima Visita",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.title,
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      if (hasProject && project != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProjectDetailsScreen(project: project),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project['PROJECT_NAME'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  project['CLIENT_NAME'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  project['GOAL'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined),
                                    const SizedBox(width: 5),
                                    Text(
                                      project['ADDRESS'],
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    const Icon(Icons.timeline),
                                    const SizedBox(width: 5),
                                    Text(
                                      project['STATE'],
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month),
                                    const SizedBox(width: 5),
                                    Text(
                                      project['DATE'],
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      _buildBox("Propostas Pendentes", "2"),
                      const SizedBox(height: 10),
                      _buildBox("Propostas Pendentes", "2"),
                      const SizedBox(height: 10),
                      _buildBox("Propostas Pendentes", "2"),
                    ],
                  ),
                ),

                // Blur Overlay (usando Container ao invés de Positioned.fill)
                AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: loaded ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: Colors.black.withOpacity(0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para criar os blocos com título e número
  Widget _buildBox(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 40)),
        ],
      ),
    );
  }
}
