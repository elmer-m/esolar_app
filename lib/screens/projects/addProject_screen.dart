import 'package:esolar_app/components/button.dart';
import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/input.dart';
import 'package:flutter/material.dart';

class AddprojectScreen extends StatefulWidget {
  const AddprojectScreen({super.key});

  @override
  State<AddprojectScreen> createState() => _AddprojectScreenState();
}

class _AddprojectScreenState extends State<AddprojectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Novo Projeto",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.title,
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20,),
            Container(
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
                  Input(label: "Nome do(a) cliente", place: 'Maria Fonseca'),
                  SizedBox(height: 10),
                  Input(label: "Número de Telemóvel", place: '351 935 123 758'),
                  SizedBox(height: 10),
                  Input(label: "Endereço", place: 'Rua das flores Nº34'),
                  SizedBox(height: 10),
                  Input(label: "Freguesia", place: '...'),
                  SizedBox(height: 10),
                  Input(label: "Conselho", place: '...'),
                  SizedBox(height: 10),
                  Input(label: "Distrito", place: '...'),
                  SizedBox(height: 20),
                  Button(label: 'ENTRAR'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
