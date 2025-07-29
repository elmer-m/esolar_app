import 'dart:convert';
import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  bool loaded = false;
  var employees;
  var user;
  var company;

  Future<void> firstLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = jsonDecode(prefs.getString('user')!);
      company = jsonDecode(prefs.getString('company')!);
    });
    var url = Uri.parse("${Urls().url['getEmployees']!}/${company['ID']}");
    var response = await http.get(url, headers: {'Accept': 'application/json'});
    if (mounted) {
      setState(() {
        employees = jsonDecode(response.body)['employees'];
        loaded = true;
      });
    }
  }

  Future<void> deleteEmployee(int employeeId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirmar Exclusão',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir este colaborador?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                var url = Uri.parse(Urls().url['deleteEmployee']!);
                var response = await http.post(
                  url,
                  headers: {'Accept': 'application/json'},
                  body: {'employee_id': employeeId.toString()},
                );

                if (response.statusCode == 200) {

                  firstLoad();
                } else {
                  
                }
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    firstLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Equipe'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.title),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              child: Row(
                children: [
                  Text(
                    "Colaboradores",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: AppColors.title,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.people, color: AppColors.primary),
                ],
              ),
            ),
            loaded
                ? Expanded(
                    child: RefreshIndicator(
                      onRefresh: firstLoad,
                      child: employees.isEmpty
                          ? Center(
                              child: Text(
                                "Nenhum colaborador encontrado.",
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: employees.length,
                              itemBuilder: (context, index) {
                                final employee = employees[index];
                                return Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: AppColors.border),
                                  ),
                                  elevation: 0,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Icon(Icons.person,
                                          color: AppColors.primary),
                                    ),
                                    title: Text(
                                      employee['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      employee['email'],
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => deleteEmployee(
                                          employee['id']),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
} 