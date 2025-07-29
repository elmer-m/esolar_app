import 'dart:convert';
import 'dart:io';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:esolar_app/components/attachment.dart';
import 'package:esolar_app/components/button.dart';
import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/counter.dart';
import 'package:esolar_app/components/input.dart';
import 'package:esolar_app/components/select.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewVisitScreen extends StatefulWidget {
  final projectId;
  final projectName;
  final clientName;
  
  NewVisitScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  @override
  State<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  var client_types;
  var install_types;
  var materials;
  List<Map<String, dynamic>> choosedMaterials = [];
  bool loading = false;
  bool loaded = false;

  TextEditingController visit_name = TextEditingController();
  TextEditingController note = TextEditingController();

  SingleValueDropDownController client_tipology_type = SingleValueDropDownController();
  SingleValueDropDownController install_tipology = SingleValueDropDownController();

  List<File> external_house = [];
  List<File> eletrical_counter = [];
  List<File> eletrical_panel = [];
  List<File> invoices = [];

  Future<void> createVisit() async {

    // Validação de campos obrigatórios (exceto nota)
    if (visit_name.text.isEmpty || 
        client_tipology_type.dropDownValue == null ||
        install_tipology.dropDownValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    var url = Uri.parse(Urls().url['newVisit']!);

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });

    // Campos obrigatórios
    request.fields['project_id'] = widget.projectId.toString();
    request.fields['visit_name'] = visit_name.text;
    request.fields['client_tipology'] = client_tipology_type.dropDownValue!.value.toString();
    request.fields['install_tipology'] = install_tipology.dropDownValue!.value.toString();
    
    // Campo opcional
    request.fields['note'] = note.text;

    // Materiais escolhidos
    if (choosedMaterials.isNotEmpty) {
      request.fields['materials'] = jsonEncode(choosedMaterials);
    }

    // Adicionar imagens - Exterior da Casa
    for (int i = 0; i < external_house.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath('external_house[]', external_house[i].path),
      );
    }

    // Adicionar imagens - Contador Elétrico
    for (int i = 0; i < eletrical_counter.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath('eletrical_counter[]', eletrical_counter[i].path),
      );
    }

    // Adicionar imagens - Quadro Elétrico
    for (int i = 0; i < eletrical_panel.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath('eletrical_panel[]', eletrical_panel[i].path),
      );
    }

    // Adicionar imagens - Faturas
    for (int i = 0; i < invoices.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath('invoices[]', invoices[i].path),
      );
    }

    try {
      var bruteResponse = await request.send();
      var response = await http.Response.fromStream(bruteResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visita criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar visita. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      print("Resposta: ${response.body}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão. Verifique sua internet.'),
          backgroundColor: Colors.red,
        ),
      );
      print("Erro: $e");
    }
  }

      var user;
  var company;

  Future<void> firstLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = jsonDecode(prefs.getString('user')!);
      company = jsonDecode(prefs.getString('company')!);
    });
  }

  Future<void> getVisitAddInfo() async {
    var url = Uri.parse("${Urls().url['getVisitAddInfo']!}/${company['ID']}");
    var response = await http.get(url, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      client_types = jsonDecode(response.body)['client_types'];
      install_types = jsonDecode(response.body)['install_types'];
      materials = jsonDecode(response.body)['materials'];
    } else {
      print("Deu errado " + response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    firstLoad().then((_){
      getVisitAddInfo().then((_) {
        setState(() {
          loaded = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.clientName),
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
                        "Nova Visita",
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
                  Row(
                    children: [
                      Text(
                        widget.projectName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
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
                              controller: visit_name,
                              label: "Nome da visita",
                              place: 'Leroy Merlin - Visita 3',
                            ),
                            SizedBox(height: 10),
                            Select(
                              data: client_types, 
                              label: 'TYPES', 
                              value: 'TYPES', 
                              selectLabel: 'Tipologia de Cliente', 
                              controller: client_tipology_type,
                            ),
                            SizedBox(height: 10),
                            Select(
                              data: install_types, 
                              label: 'TYPES', 
                              value: 'TYPES', 
                              selectLabel: 'Tipologia de Instalação', 
                              controller: install_tipology,
                            ),
                            SizedBox(height: 10),
                            _buildActionButton(
                              icon: Icons.construction_outlined,
                              label: 'Materiais',
                              color: AppColors.primary,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  clipBehavior: Clip.hardEdge,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Container(
                                      color: Colors.white,
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 20,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Materiais",
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
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: materials.isNotEmpty
                                                    ? materials.map<Widget>((material) {
                                                        return Column(
                                                          children: [
                                                            CounterWidget(
                                                              initialValue: () {
                                                                final index =
                                                                    choosedMaterials
                                                                        .indexWhere(
                                                                          (m) =>
                                                                              m['ID'] ==
                                                                              material['ID'],
                                                                        );
                                                                return index != -1
                                                                    ? choosedMaterials[index]['VALUE'] ?? 0
                                                                    : 0;
                                                              }(),
                                                              onChanged: (value) {
                                                                final index =
                                                                    choosedMaterials
                                                                        .indexWhere(
                                                                          (m) =>
                                                                              m['ID'] ==
                                                                              material['ID'],
                                                                        );

                                                                if (index != -1) {
                                                                  choosedMaterials[index]['VALUE'] = value;
                                                                  if (value == 0) {
                                                                    choosedMaterials.removeAt(index);
                                                                  }
                                                                } else {
                                                                  if (value != 0) {
                                                                    choosedMaterials.add({
                                                                      'ID': material['ID'],
                                                                      'VALUE': value,
                                                                    });
                                                                  }
                                                                }
                                                                print(choosedMaterials);
                                                              },
                                                              label: material['NAME'],
                                                              primaryColor: AppColors.primary,
                                                            ),
                                                            SizedBox(height: 15),
                                                          ],
                                                        );
                                                      }).toList()
                                                    : [
                                                        Center(
                                                          child: Text(
                                                            "Ainda não há materiais.",
                                                          ),
                                                        )
                                                      ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            AttachmentWidget(
                              label: "Exterior da Casa",
                              images: external_house,
                              onChanged: ((newImages) {
                                setState(() {
                                  external_house = newImages;
                                });
                              }),
                            ),
                            SizedBox(height: 10),
                            AttachmentWidget(
                              label: "Contador Elétrico",
                              images: eletrical_counter,
                              onChanged: ((newImages) {
                                setState(() {
                                  eletrical_counter = newImages;
                                });
                              }),
                            ),
                            SizedBox(height: 10),
                            AttachmentWidget(
                              label: "Quadro Elétrico",
                              images: eletrical_panel,
                              onChanged: ((newImages) {
                                setState(() {
                                  eletrical_panel = newImages;
                                });
                              }),
                            ),
                            SizedBox(height: 10),
                            AttachmentWidget(
                              label: "Fatura(Imagem)",
                              images: invoices,
                              onChanged: ((newImages) {
                                setState(() {
                                  invoices = newImages;
                                });
                              }),
                            ),
                            SizedBox(height: 10),
                            Input(
                              controller: note,
                              label: "Nota (Opcional)",
                              place: 'Observações adicionais...',
                            ),
                            SizedBox(height: 20),
                            Button(
                              loading: loading,
                              icon: Icons.folder_outlined,
                              label: 'Criar Visita',
                              functionVoid: () {
                                setState(() {
                                  loading = true;
                                });
                                createVisit().then((_) {
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

Widget _buildActionButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Spacer(),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    ),
  );
}