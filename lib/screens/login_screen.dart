import 'dart:convert';

import 'package:esolar_app/app.dart';
import 'package:esolar_app/components/button.dart';
import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/input.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController passowrd = TextEditingController();
  TextEditingController key = TextEditingController();
  bool loading = false;
  Future<void> login() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    loading = true; // Começa o carregamento aqui
  });

  var url = Uri.parse(Urls().url['login']!);
  var request = http.MultipartRequest('POST', url);
  request.headers.addAll({
    'Accept': 'application/json',
    'Content-Type': 'multipart/form-data',
  });

  request.fields['email'] = email.text;
  request.fields['password'] = passowrd.text;
  request.fields['key'] = key.text;

  try {
    var bruteResponse = await request.send();
    var response = await http.Response.fromStream(bruteResponse);

    var data = jsonDecode(response.body);

    if (data['success'] == true) {
      await prefs.setString('user', jsonEncode(data['user']));
      await prefs.setString('company', jsonEncode(data['company']));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => App()),
      );
    } else {
      // ❗️ Mostra mensagem de erro
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Credenciais inválidas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // ❗️ Se falhar (por exemplo, sem conexão)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao conectar ao servidor'),
        backgroundColor: Colors.red,
      ),
    );
  }

  setState(() {
    loading = false; // Finaliza o carregamento
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(10, 0),
                  spreadRadius: 0,
                  blurRadius: 20,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Input(
                  label: "Email",
                  place: 'email@gmail.com',
                  controller: email,
                ),
                SizedBox(height: 10),
                Input(
                  label: "Palavra-Passe",
                  place: '••••••••',
                  controller: passowrd,
                  password: true,
                ),
                SizedBox(height: 10),
                Input(
                  label: "Licença",
                  place: 'JHS8JS9QPS4M1',
                  controller: key,
                ),
                SizedBox(height: 20),
                Button(
                  label: 'ENTRAR',
                  functionVoid: () => login(),
                  loading: loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
