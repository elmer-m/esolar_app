import 'dart:convert';

import 'package:esolar_app/app.dart';
import 'package:esolar_app/components/button.dart';
import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/input.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController passowrd = TextEditingController();
  
  Future<void> login() async {
    print("Chamou");
    var url = Uri.parse(Urls().url['login']!);
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });
    request.fields['email'] = email.text;
    request.fields['password'] = passowrd.text;
    var bruteResponse = await request.send();
    var response = await http.Response.fromStream(bruteResponse);
    if(jsonDecode(response.body)['success'] == true){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));
    }
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
                Input(label: "Email", place: 'email@gmail.com', controller: email,),
                SizedBox(height: 10,),
                Input(label: "Palavra-Passe", place: '••••••••', controller: passowrd, password: true,),
                SizedBox(height: 10,),
                Input(label: "Licença", place: 'JHS8JS9QPS4M1'),
                SizedBox(height: 20,),
                Button(label: 'ENTRAR', functionVoid: () => login(),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}