import 'dart:convert';
import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:esolar_app/components/input.dart';
import 'package:esolar_app/components/button.dart';
import 'package:esolar_app/screens/login_screen.dart';
import 'package:esolar_app/screens/settings/employees_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool loaded = true;
  bool loadingLogout = false;
  bool loadingAddUser = false;

  var user;
  var company;

  Future<void> firstLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = jsonDecode(prefs.getString('user')!);
      company = jsonDecode(prefs.getString('company')!);
    });
  }

  // Controllers para adicionar colaborador
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> addCol(BuildContext contextt) async {
    var url = Uri.parse(Urls().url['addCol']!);
    // var request = http.post(url, headers: {'Accept': 'application/json'});
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Accept': 'application/json'});
    request.fields['name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['password'] = passwordController.text;
    request.fields['company_id'] = company['ID'].toString();
    var bruteReponse = await request.send();
    var response = await http.Response.fromStream(bruteReponse);
    Navigator.pop(contextt);
    print(response.body);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loadingLogout = true;
    });

    prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> addCollaborator() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      loadingAddUser = true;
    });

    try {
      var url = Uri.parse(Urls().url['addCollaborator']!);
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Colaborador adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Limpar campos
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar colaborador'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        loadingAddUser = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstLoad();
  }

  void showAddCollaboratorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Adicionar Colaborador',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.title,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Input(
                      controller: nameController,
                      label: "Nome completo",
                      place: 'João Silva',
                    ),
                    SizedBox(height: 15),
                    Input(
                      controller: emailController,
                      label: "Email",
                      place: 'joao@empresa.com',
                      type: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    Input(
                      controller: passwordController,
                      label: "Senha",
                      place: '••••••••',
                      password: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    addCol(context);
                  },
                  child: loadingAddUser
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirmar Logout',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),
          content: Text(
            'Tem certeza que deseja sair da aplicação?',
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
              onPressed: loadingLogout
                  ? null
                  : () {
                      Navigator.pop(context);
                      logout();
                    },
              child: loadingLogout
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  Widget buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.grey,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.title,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.border, indent: 60),
      ],
    );
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
                  "Configurações",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.title,
                  ),
                ),
                Spacer(),
                Icon(Icons.settings, color: AppColors.primary),
              ],
            ),
          ),
          loaded
              ? Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Seção do usuário
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user != null ? user['name'] : 'user',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.title,
                                      ),
                                    ),
                                    Text(
                                      user != null
                                          ? user['email']
                                          : 'user@gmail.com',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Configurações da empresa
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  "Empresa",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.title,
                                  ),
                                ),
                              ),
                              buildSettingItem(
                                icon: Icons.person_add,
                                title: "Adicionar Colaborador",
                                subtitle: "Convide novos membros para a equipe",
                                iconColor: AppColors.primary,
                                onTap: showAddCollaboratorDialog,
                              ),
                              buildSettingItem(
                                icon: Icons.people,
                                title: "Gerenciar Equipe",
                                subtitle: "Visualizar e editar colaboradores",
                                iconColor: Colors.blue,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeesScreen()));
                                },
                              ),
                              buildSettingItem(
                                icon: Icons.business,
                                title: "Informações da Empresa",
                                subtitle: "Editar dados da organização",
                                iconColor: Colors.green,
                                onTap: () {
                                  // Implementar navegação para info da empresa
                                },
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Configurações da aplicação
                        // Container(
                        //   width: double.infinity,
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     border: Border.all(
                        //       color: AppColors.border,
                        //       width: 1,
                        //     ),
                        //     borderRadius: BorderRadius.circular(15),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Padding(
                        //         padding: EdgeInsets.all(15),
                        //         child: Text(
                        //           "Aplicação",
                        //           style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.w700,
                        //             color: AppColors.title,
                        //           ),
                        //         ),
                        //       ),
                        //       buildSettingItem(
                        //         icon: Icons.notifications,
                        //         title: "Notificações",
                        //         subtitle: "Gerenciar alertas e lembretes",
                        //         iconColor: Colors.orange,
                        //         onTap: () {
                        //           // Implementar configurações de notificação
                        //         },
                        //       ),
                        //       buildSettingItem(
                        //         icon: Icons.language,
                        //         title: "Idioma",
                        //         subtitle: "Português (Brasil)",
                        //         iconColor: Colors.purple,
                        //         onTap: () {
                        //           // Implementar seleção de idioma
                        //         },
                        //       ),
                        //       buildSettingItem(
                        //         icon: Icons.dark_mode,
                        //         title: "Tema",
                        //         subtitle: "Claro",
                        //         iconColor: Colors.indigo,
                        //         onTap: () {
                        //           // Implementar mudança de tema
                        //         },
                        //       ),
                        //       buildSettingItem(
                        //         icon: Icons.backup,
                        //         title: "Backup",
                        //         subtitle: "Fazer backup dos dados",
                        //         iconColor: Colors.teal,
                        //         onTap: () {
                        //           // Implementar backup
                        //         },
                        //         showDivider: false,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 20),

                        // Suporte e informações
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  "Suporte",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.title,
                                  ),
                                ),
                              ),
                              // buildSettingItem(
                              //   icon: Icons.help,
                              //   title: "Central de Ajuda",
                              //   subtitle: "FAQ e tutoriais",
                              //   iconColor: Colors.cyan,
                              //   onTap: () {
                              //     // Implementar central de ajuda
                              //   },
                              // ),
                              // buildSettingItem(
                              //   icon: Icons.contact_support,
                              //   title: "Contatar Suporte",
                              //   subtitle: "Envie suas dúvidas",
                              //   iconColor: Colors.amber,
                              //   onTap: () {
                              //     // Implementar contato com suporte
                              //   },
                              // ),
                              buildSettingItem(
                                icon: Icons.info,
                                title: "Sobre",
                                subtitle: "Versão 1.0.0",
                                iconColor: Colors.grey,
                                onTap: () {
                                  // Implementar tela sobre
                                },
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Logout
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: buildSettingItem(
                            icon: Icons.logout,
                            title: "Sair da Conta",
                            subtitle: "Fazer logout da aplicação",
                            iconColor: Colors.red,
                            onTap: showLogoutConfirmation,
                            showDivider: false,
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
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
