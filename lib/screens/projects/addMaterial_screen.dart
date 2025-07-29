import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:esolar_app/components/button.dart';
import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/input.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  bool loading = false;

  TextEditingController material_name = TextEditingController();
  TextEditingController value = TextEditingController();

  Future<void> createProject() async {
    var url = Uri.parse(Urls().url['newMaterial']!);

    if (material_name.text.isEmpty ||
        material_name.text.isEmpty ||
        value.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });
    request.fields['material_name'] = material_name.text;
    request.fields['value'] = value.text;

    var bruteResponse = await request.send();
    var response = await http.Response.fromStream(bruteResponse);
    if(response.statusCode == 200){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Material adicionado com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    }
    print("Resposta: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
                  "Novo Material",
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
            SizedBox(height: 20),
            Center(
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Input(
                        controller: material_name,
                        label: "Novo Material",
                        place: 'Páinel Solar',
                      ),
                      SizedBox(height: 10),
                      Input(
                        type: TextInputType.number,
                        controller: value,
                        label: "Valor",
                        place: '120.00',
                      ),
                      SizedBox(height: 20),
                      Button(
                        loading: loading,
                        icon: Icons.construction_outlined,
                        label: 'Adicionar',
                        functionVoid: () {
                          setState(() {
                            loading = true;
                          });
                          createProject().then((_) {
                            setState(() {
                              loading = false;
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
