import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

class EditProjectScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
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
  List<File> newImages = []; // Novas imagens selecionadas
  List<Uint8List> existingImages = []; // Imagens existentes do projeto
  List<int> imagesToDelete = []; // IDs das imagens a serem deletadas
  List<int> existingImageIds = []; // IDs das imagens existentes

  DateTime? selectedDateTime;
  TextEditingController dateTimeController = TextEditingController();

  final ImagePicker pickerImage = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    getAddInfo().then((_) {
      loadExistingImages().then((_) {
        setState(() {
          loaded = true;
        });
      });
    });
  }

  void _initializeControllers() {
    client_name.text = widget.project['CLIENT_NAME'] ?? '';
    project_name.text = widget.project['PROJECT_NAME'] ?? '';
    phone_number.text = widget.project['PHONE_NUMBER'] ?? '';
    address.text = widget.project['ADDRESS'] ?? '';

    // Parse existing date if available
    if (widget.project['DATE'] != null) {
      try {
        selectedDateTime = DateTime.parse(widget.project['SCHEDULED_DATE']);
        dateTimeController.text = DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(selectedDateTime!);
      } catch (e) {
        selectedDateTime = null;
        dateTimeController.text = '';
      }
    }
  }

  Future<void> selectImageGallery() async {
    final XFile? image = await pickerImage.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        newImages.add(File(image.path));
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
          dateTimeController.text = DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(selectedDateTime!);
        });
      }
    }
  }

  Future<void> loadExistingImages() async {
    if (widget.project['IMAGES_IDS'] != null &&
        widget.project['IMAGES_IDS'].isNotEmpty) {
      var url = Uri.parse(Urls().url['getImages']!);
      var response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'ids': widget.project['IMAGES_IDS'],
          'project_id': widget.project['ID'].toString(),
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var base64Images = responseData['images'] as List<dynamic>? ?? [];
        var imageIds = responseData['image_ids'] as List<dynamic>? ?? [];

        print('Imagens carregadas: ${base64Images.length}');
        print('IDs das imagens: $imageIds');

        for (int i = 0; i < base64Images.length; i++) {
          setState(() {
            existingImages.add(base64Decode(base64Images[i]));
            if (i < imageIds.length) {
              existingImageIds.add(int.parse(imageIds[i].toString()));
            }
          });
        }

        print('IDs carregados no Flutter: $existingImageIds');
      } else {
        print('Erro ao carregar imagens: ${response.statusCode}');
        print('Resposta: ${response.body}');
      }
    }
  }

  Future<void> updateProject() async {
    var url = Uri.parse(Urls().url['updateProject']!);

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
    request.fields['project_id'] = widget.project['ID'].toString();
    request.fields['client_name'] = client_name.text;
    request.fields['project_name'] = project_name.text;
    request.fields['phone_number'] = phone_number.text;
    request.fields['concelho'] = jsonEncode(concelho.dropDownValue!.value);
    request.fields['distrito'] = jsonEncode(distrito.dropDownValue!.value);
    request.fields['freguesia'] = jsonEncode(freguesia.dropDownValue!.value);
    request.fields['goal'] = goal.dropDownValue!.value.toString();
    request.fields['state'] = state.dropDownValue!.value.toString();
    request.fields['address'] = address.text;
    request.fields['images_to_delete'] = jsonEncode(imagesToDelete);

    print('IDs de imagens para deletar: $imagesToDelete');

    if (selectedDateTime != null) {
      request.fields['scheduled_date'] = selectedDateTime!.toIso8601String();
    }

    // Adicionar novas imagens
    for (int i = 0; i < newImages.length; i++) {
      final file = newImages[i];
      request.files.add(
        await http.MultipartFile.fromPath('new_images[]', file.path),
      );
    }

    setState(() {
      loading = true;
    });

    try {
      var bruteResponse = await request.send();
      var response = await http.Response.fromStream(bruteResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Projeto atualizado com sucesso!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop(true); // Retorna true indicando sucesso
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar projeto.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> getAddInfo() async {
    var url = Uri.parse(Urls().url['getAddInfo']!);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        concelhos = jsonDecode(response.body)['concelhos'];
        distritos = jsonDecode(response.body)['distritos'];
        freguesias = jsonDecode(response.body)['freguesias'];
        goals = jsonDecode(response.body)['goals'];
        states = jsonDecode(response.body)['states'];
      });

      // Definir valores iniciais dos dropdowns
      _setInitialDropdownValues();
    } else {
      print("Erro ao carregar informações");
    }
  }

  void _setInitialDropdownValues() {
    // Definir concelho inicial
    if (widget.project['CONCELHO'] != null && concelhos != null) {
      var concelhoItem = concelhos.firstWhere(
        (item) =>
            item['CODIGO_CONCELHO'] ==
                jsonDecode(widget.project['CONCELHO'])['CODIGO_CONCELHO'] &&
            item['CODIGO_DISTRITO'] ==
                jsonDecode(widget.project['CONCELHO'])['CODIGO_DISTRITO'],
        orElse: () => null,
      );
      if (concelhoItem != null) {
        print("Tentou definir concelho");
        concelho.setDropDown(
          DropDownValueModel(
            name: concelhoItem['DESCRICAO'],
            value: {'CODIGO_CONCELHO': concelhoItem['CODIGO_CONCELHO'], 'CODIGO_DISTRITO': concelhoItem['CODIGO_DISTRITO']},
          ),
        );
      }
    }

    // Definir distrito inicial
    if (widget.project['DISTRITO'] != null && distritos != null) {
      var distritoItem = distritos.firstWhere(
        (item) =>
            item['CODIGO_DISTRITO'] ==
            jsonDecode(widget.project['DISTRITO'])['CODIGO_DISTRITO'],
        orElse: () => null,
      );
      if (distritoItem != null) {
        distrito.setDropDown(
          DropDownValueModel(
            name: distritoItem['DESCRICAO'],
            value: {'CODIGO_DISTRITO': distritoItem['CODIGO_DISTRITO']},
          ),
        );
      }
    }

    // Definir freguesia inicial
    if (widget.project['FREGUESIA'] != null && freguesias != null) {
      var freguesiaItem = freguesias.firstWhere(
        (item) => item['CODIGO_FREGUESIA'] == jsonDecode(widget.project['FREGUESIA'])['CODIGO_FREGUESIA'] && item['CODIGO_DISTRITO'] == jsonDecode(widget.project['FREGUESIA'])['CODIGO_DISTRITO'] && item['CODIGO_CONCELHO'] == jsonDecode(widget.project['FREGUESIA'])['CODIGO_CONCELHO'],
        orElse: () => null,
      );
      if (freguesiaItem != null) {
        freguesia.setDropDown(
          DropDownValueModel(
            name: freguesiaItem['DESCRICAO'],
            value: {
                                              'CODIGO_CONCELHO':
                                                  freguesiaItem['CODIGO_CONCELHO'],
                                              'CODIGO_DISTRITO':
                                                  freguesiaItem['CODIGO_DISTRITO'],
                                              'CODIGO_FREGUESIA':
                                                  freguesiaItem['CODIGO_FREGUESIA'],
                                            },
          ),
        );
      }
    }

    // Definir estado inicial
    if (widget.project['STATE'] != null && states != null) {
      var stateItem = states.firstWhere(
        (item) => item['ESTADO'] == widget.project['STATE'],
        orElse: () => null,
      );
      if (stateItem != null) {
        state.setDropDown(
          DropDownValueModel(
            name: stateItem['ESTADO'],
            value: stateItem['ESTADO'],
          ),
        );
      }
    }

    // Definir objetivo inicial
    if (widget.project['GOAL'] != null && goals != null) {
      var goalItem = goals.firstWhere(
        (item) => item['OBJETIVO'] == widget.project['GOAL'],
        orElse: () => null,
      );
      if (goalItem != null) {
        goal.setDropDown(
          DropDownValueModel(
            name: goalItem['OBJETIVO'],
            value: goalItem['OBJETIVO'],
          ),
        );
      }
    }
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
                        "Editar Projeto",
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    'Distrito',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                DropDownTextField(
                                  onChanged: (value) {
                                    print(value);
                                  },
                                  controller: distrito,
                                  enableSearch: true,
                                  searchDecoration: InputDecoration(
                                    hintText: 'Pesquisar...',
                                    border: InputBorder.none,
                                  ),
                                  textFieldDecoration: InputDecoration(
                                    hintText: 'Distrito',
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  dropDownList: [
                                    ...distritos
                                        .map(
                                          (distrito) => DropDownValueModel(
                                            name: distrito['DESCRICAO'],
                                            value: {
                                              'CODIGO_DISTRITO':
                                                  distrito['CODIGO_DISTRITO'],
                                            },
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    'Concelho',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                DropDownTextField(
                                  onChanged: (value) {
                                    print(value);
                                  },
                                  controller: concelho,
                                  enableSearch: true,
                                  searchDecoration: InputDecoration(
                                    hintText: 'Pesquisar...',
                                    border: InputBorder.none,
                                  ),
                                  textFieldDecoration: InputDecoration(
                                    hintText: 'Concelho',
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  dropDownList: [
                                    ...concelhos
                                        .map(
                                          (concelho) => DropDownValueModel(
                                            name: concelho['DESCRICAO'],
                                            value: {
                                              'CODIGO_CONCELHO':
                                                  concelho['CODIGO_CONCELHO'],
                                              'CODIGO_DISTRITO':
                                                  concelho['CODIGO_DISTRITO'],
                                            },
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    'Freguesia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                DropDownTextField(
                                  onChanged: (value) {
                                    print(value);
                                  },
                                  controller: freguesia,
                                  enableSearch: true,
                                  searchDecoration: InputDecoration(
                                    hintText: 'Pesquisar...',
                                    border: InputBorder.none,
                                  ),
                                  textFieldDecoration: InputDecoration(
                                    hintText: 'Freguesia',
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  dropDownList: [
                                    ...freguesias
                                        .map(
                                          (freguesia) => DropDownValueModel(
                                            name: freguesia['DESCRICAO'],
                                            value: {
                                              'CODIGO_CONCELHO':
                                                  freguesia['CODIGO_CONCELHO'],
                                              'CODIGO_DISTRITO':
                                                  freguesia['CODIGO_DISTRITO'],
                                              'CODIGO_FREGUESIA':
                                                  freguesia['CODIGO_FREGUESIA'],
                                            },
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ],
                            ),
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
                                'Data e Hora Agendada',
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
                                    // Imagens existentes
                                    ...existingImages.asMap().entries.map((
                                      entry,
                                    ) {
                                      int index = entry.key;
                                      Uint8List image = entry.value;

                                      return Stack(
                                        children: [
                                          Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            width: 100,
                                            height: 100,
                                            child: Image.memory(
                                              image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () {
                                                print(
                                                  'Tentando deletar imagem no índice: $index',
                                                );
                                                print(
                                                  'IDs existentes: $existingImageIds',
                                                );
                                                print(
                                                  'Total de imagens existentes: ${existingImages.length}',
                                                );

                                                setState(() {
                                                  if (index <
                                                      existingImageIds.length) {
                                                    int imageIdToDelete =
                                                        existingImageIds[index];
                                                    print(
                                                      'Adicionando ID $imageIdToDelete para deletar',
                                                    );
                                                    imagesToDelete.add(
                                                      imageIdToDelete,
                                                    );
                                                    existingImageIds.removeAt(
                                                      index,
                                                    );
                                                  }
                                                  existingImages.removeAt(
                                                    index,
                                                  );
                                                });

                                                print(
                                                  'IDs para deletar: $imagesToDelete',
                                                );
                                                print(
                                                  'IDs restantes: $existingImageIds',
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                      );
                                    }),
                                    // Novas imagens
                                    ...newImages.map(
                                      (image) => Stack(
                                        children: [
                                          Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                                  newImages.remove(image);
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                    // Botão para adicionar imagem
                                    GestureDetector(
                                      onTap: () => selectImageGallery(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                              icon: Icons.save_outlined,
                              label: 'Salvar Alterações',
                              functionVoid: updateProject,
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
