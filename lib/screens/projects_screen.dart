import 'package:esolar_app/components/colors.dart';
import 'package:flutter/material.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
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
                Icon(Icons.more_horiz)
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Exemplo",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          child: Text(
                            "Orçamento",
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
                                "Rua das flores nº 35, Corroios",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                "Orçamento",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                "Orçamento",
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
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Exemplo",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          child: Text(
                            "Orçamento",
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
                                "Rua das flores nº 35, Corroios",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                "Orçamento",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                "Orçamento",
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
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Exemplo",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          child: Text(
                            "Orçamento",
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
                                "Rua das flores nº 35, Corroios",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                "Orçamento",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                "Orçamento",
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
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Exemplo",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          child: Text(
                            "Orçamento",
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
                                "Rua das flores nº 35, Corroios",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                "Orçamento",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                "Orçamento",
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
            ),
          ),
        ],
      ),
    );
  }
}
