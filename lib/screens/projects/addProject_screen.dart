import 'dart:convert';
import 'dart:io';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:esolar_app/components/button.dart';
import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/input.dart';
import 'package:esolar_app/components/select.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddprojectScreen extends StatefulWidget {
  const AddprojectScreen({super.key});

  @override
  State<AddprojectScreen> createState() => _AddprojectScreenState();
}

class _AddprojectScreenState extends State<AddprojectScreen> {
  var concelhos;
  var distritos;
  var freguesias;
  var goals;
  var states;
  bool loading = false;

  TextEditingController client_name = TextEditingController();
  TextEditingController project_name = TextEditingController();
  TextEditingController phone_number = TextEditingController();
  SingleValueDropDownController concelho = SingleValueDropDownController();
  SingleValueDropDownController distrito = SingleValueDropDownController();
  SingleValueDropDownController freguesia = SingleValueDropDownController();
  TextEditingController address = TextEditingController();
  SingleValueDropDownController state = SingleValueDropDownController();
  SingleValueDropDownController goal = SingleValueDropDownController();

  var loaded = false;
  List<File> images = [];

  // Campos para data e hora
  DateTime? selectedDateTime;
  TextEditingController dateTimeController = TextEditingController();

  final ImagePicker pickerImage = ImagePicker();

  Future<void> selectImageGalery() async {
    final XFile? image = await pickerImage.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        images.add(File(image.path));
      });
    }
  }

  Future<void> selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.title,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedDateTime != null 
          ? TimeOfDay.fromDateTime(selectedDateTime!) 
          : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.title,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateTimeController.text = DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime!);
        });
      }
    }
  }

  Future<void> createProject() async {
    var url = Uri.parse(Urls().url['createProject']!);

    if (client_name.text.isEmpty ||
        project_name.text.isEmpty ||
        phone_number.text.isEmpty ||
        concelho.dropDownValue == null ||
        distrito.dropDownValue == null ||
        freguesia.dropDownValue == null ||
        address.text.isEmpty ||
        state.dropDownValue == null ||
        goal.dropDownValue == null) {
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

    request.fields['client_name'] = client_name.text;
    request.fields['project_name'] = project_name.text;
    request.fields['phone_number'] = phone_number.text;
    request.fields['concelho'] = concelho.dropDownValue!.value.toString();
    request.fields['distrito'] = distrito.dropDownValue!.value.toString();
    request.fields['freguesia'] = freguesia.dropDownValue!.value.toString();
    request.fields['goal'] = goal.dropDownValue!.value.toString();
    request.fields['state'] = state.dropDownValue!.value.toString();
    request.fields['address'] = address.text;
    request.fields['user_id'] = user['id'].toString();
    request.fields['company_id'] = company['ID'].toString();


    // Adicionar data agendada se selecionada
    if (selectedDateTime != null) {
      request.fields['scheduled_date'] = selectedDateTime!.toIso8601String();
    }

    for (int i = 0; i < images.length; i++) {
      final file = images[i];

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath('images[]', file.path),
        );
      }
    }

    try {
      var bruteResponse = await request.send();
      var response = await http.Response.fromStream(bruteResponse);
      
      print("Status: ${response.statusCode}");
      print("Resposta: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Projeto criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar projeto.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Erro: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  var user;
  var company;
  Future<void> getAddInfo() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = jsonDecode(prefs.getString('user')!);
      company = jsonDecode(prefs.getString('company')!);
    });
    var url = Uri.parse(Urls().url['getAddInfo']!);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      concelhos = jsonDecode(response.body)['concelhos'];
      distritos = jsonDecode(response.body)['distritos'];
      freguesias = jsonDecode(response.body)['freguesias'];
      goals = jsonDecode(response.body)['goals'];
      states = jsonDecode(response.body)['states'];
    } else {
      print("Deu errado");
    }
  }

  @override
  void initState() {
    getAddInfo().then((_) {
      setState(() {
        loaded = true;
      });
    });
    super.initState();
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
      body: loaded
          ? Padding(
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
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
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
                              controller: project_name,
                              label: "Nome do projeto",
                              place: 'Leroy Merlin - Instalação 3',
                            ),
                            SizedBox(height: 10),
                            Input(
                              controller: client_name,
                              label: "Nome do(a) cliente",
                              place: 'Maria Fonseca',
                            ),
                            SizedBox(height: 10),
                            Input(
                              controller: phone_number,
                              label: "Número de Telemóvel",
                              place: '351 935 123 758',
                            ),
                            SizedBox(height: 10),
                            Select(
                              controller: concelho,
                              data: concelhos,
                              label: 'DESCRICAO',
                              value: 'CODIGO_CONCELHO',
                              selectLabel: 'Concelho',
                            ),
                            SizedBox(height: 10),
                            Select(
                              controller: distrito,
                              data: distritos,
                              label: 'DESCRICAO',
                              value: 'CODIGO_DISTRITO',
                              selectLabel: 'Distrito',
                            ),
                            SizedBox(height: 10),
                            Select(
                              controller: freguesia,
                              data: freguesias,
                              label: 'DESCRICAO',
                              value: 'CODIGO_FREGUESIA',
                              selectLabel: 'Freguesia',
                            ),
                            SizedBox(height: 10),
                            Input(
                              controller: address,
                              label: "Endereço",
                              place: 'Rua das flores Nº34',
                            ),
                            SizedBox(height: 10),
                            Select(
                              controller: state,
                              data: states,
                              label: 'ESTADO',
                              value: 'ESTADO',
                              selectLabel: 'Estado',
                            ),
                            SizedBox(height: 10),
                            Select(
                              controller: goal,
                              data: goals,
                              label: 'OBJETIVO',
                              value: 'OBJETIVO',
                              selectLabel: 'Objetivo',
                            ),
                            SizedBox(height: 10),
                            
                            // Campo de data e hora
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                'Data e Hora Agendada (Opcional)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: selectDateTime,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        dateTimeController.text.isEmpty 
                                          ? 'Selecionar data e hora'
                                          : dateTimeController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: dateTimeController.text.isEmpty 
                                            ? Colors.grey[600]
                                            : AppColors.title,
                                        ),
                                      ),
                                    ),
                                    if (dateTimeController.text.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDateTime = null;
                                            dateTimeController.clear();
                                          });
                                        },
                                        child: Icon(
                                          Icons.clear,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                'Imagens',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              clipBehavior: Clip.hardEdge,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    ...images.map(
                                      (image) => Stack(
                                        children: [
                                          Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            width: 100,
                                            height: 100,
                                            child: Image.file(
                                              image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  images.remove(image);
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => selectImageGalery(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        width: 100,
                                        height: 100,
                                        child: Icon(
                                          Icons.add_photo_alternate_outlined,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'Clique no X para remover a imagem.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Button(
                              loading: loading,
                              icon: Icons.folder_outlined,
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
            )
          : Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}