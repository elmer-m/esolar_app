import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:esolar_app/screens/projects/editProject_screen.dart';
import 'package:esolar_app/screens/projects/visits/newVisit_screen.dart';
import 'package:esolar_app/screens/projects/visits/visitDetails_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool loading = false;
  List<String> projectImages = [];
  List<Uint8List> images = [];
  var concelhos;
  var distritos;
  var freguesias;
  var visits;

  @override
  void initState() {
    super.initState();
    firstLoad().then((_) {
      getAddInfo();
      loadProjectImages();
    });
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

  Future<void> getAddInfo() async {
    var url = Uri.parse(Urls().url['getAddInfo']!);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        concelhos = jsonDecode(response.body)['concelhos'];
        distritos = jsonDecode(response.body)['distritos'];
        freguesias = jsonDecode(response.body)['freguesias'];
      });
    } else {
      print("Deu errado");
    }
  }

  Future<void> loadProjectImages() async {
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
      var base64Images = jsonDecode(response.body)['images'];
      base64Images.forEach((base64) {
        setState(() {
          images.add(base64Decode(base64));
        });
      });
      setState(() {
        visits = jsonDecode(response.body)['visits'];
      });
      loadMaterials();
    } else {
      print("Deu errado");
    }
  }

  Future<void> scheduleNewVisit() async {
    // Implementar lógica para agendar nova visita
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nova visita agendada com sucesso!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> editProject() async {
    // Navegar para tela de edição do projeto
    Navigator.of(context).pushNamed('/edit_project', arguments: widget.project);
  }

  Future<void> addProjectItem() async {
    // Implementar lógica para adicionar item ao projeto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item adicionado ao projeto!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  var allMaterials = [];
  Future<void> loadMaterials() async {
    var url = Uri.parse("${Urls().url['getVisitAddInfo']!}/${company['ID']}");
    var response = await http.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      allMaterials = jsonDecode(response.body)['materials'];
      var visitsMaterials = [];
      visits.forEach((visit) {
        jsonDecode(visit['MATERIALS']).forEach((visitMaterial) {
          print("Antes");
          print(visitMaterial);
          visitsMaterials.add(visitMaterial);
        });
      });
      print("Materiais das visitasx");
      print(visitsMaterials);

      visitsMaterials.forEach((material) {
        allMaterials.forEach((materialWValue) {
          if (material['ID'] == materialWValue['ID']) {
            print(materialWValue);
            setState(() {
              budget += num.parse(materialWValue['VALUE']) * material['VALUE'];
            });
          }
        });
      });
      setState(() {
        budgetLoaded = true;
      });
    }
  }

  var budget = 0.0;
  var budgetLoaded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.project['CLIENT_NAME'])),
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.title),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.title),
            onSelected: (String value) {
              switch (value) {
                case 'edit':
                  editProject();
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.title),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do projeto
            Text(
              widget.project['PROJECT_NAME'],
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.title,
              ),
            ),
            Text(
              budgetLoaded
                  ? 'Orçamento: ' + budget.toString() + '€'
                  : 'A carregar...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),

            // Cartão principal com informações
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                      blurRadius: 15,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações básicas
                      _buildInfoSection("Informações do Projeto", [
                        _buildInfoRow(
                          Icons.person,
                          "Cliente",
                          widget.project['CLIENT_NAME'],
                        ),
                        _buildInfoRow(
                          Icons.phone,
                          "Telefone",
                          widget.project['PHONE_NUMBER'],
                        ),
                        _buildInfoRow(
                          Icons.location_on,
                          "Endereço",
                          widget.project['ADDRESS'],
                        ),
                        _buildInfoRow(
                          Icons.timeline,
                          "Estado",
                          widget.project['STATE'],
                        ),
                        _buildInfoRow(
                          Icons.flag,
                          "Objetivo",
                          widget.project['GOAL'],
                        ),
                        widget.project['DATE'] != null
                            ? _buildInfoRow(
                                Icons.calendar_month,
                                "Data da Visita",
                                widget.project['DATE'].toString(),
                              )
                            : _buildInfoRow(
                                Icons.calendar_month,
                                "Data da Visita",
                                'Sem data marcada.',
                              ),
                      ]),

                      SizedBox(height: 25),

                      // Localização detalhada
                      _buildInfoSection("Localização", [
                        _buildInfoRow(
                          Icons.location_city,
                          "Concelho",
                          concelhos == null
                              ? 'Carregando...'
                              : concelhos.firstWhere(
                                  (concelho) =>
                                      concelho['CODIGO_CONCELHO'] ==
                                      widget.project['CONCELHO'],
                                  orElse: () => {'DESCRICAO': 'Desconhecido'},
                                )['DESCRICAO'],
                        ),
                        _buildInfoRow(
                          Icons.map,
                          "Distrito",
                          distritos == null
                              ? 'Carregando...'
                              : distritos.firstWhere(
                                  (distrito) =>
                                      distrito['CODIGO_DISTRITO'] ==
                                      widget.project['DISTRITO'],
                                )['DESCRICAO'],
                        ),
                        _buildInfoRow(
                          Icons.place,
                          "Freguesia",
                          freguesias == null
                              ? 'Carregando...'
                              : freguesias.firstWhere(
                                  (freguesia) =>
                                      freguesia['CODIGO_FREGUESIA'] ==
                                      widget.project['FREGUESIA'],
                                )['DESCRICAO'],
                        ),
                      ]),

                      SizedBox(height: 25),

                      // Imagens do projeto
                      if (images.isNotEmpty) ...[
                        Text(
                          'Imagens do Projeto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.title,
                          ),
                        ),
                        SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 10,
                            children: [
                              ...images.map((image) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Scaffold(
                                          backgroundColor: Colors.black38,
                                          body: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: PhotoView(
                                              imageProvider: MemoryImage(image),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    width: 150,
                                    height: 150,
                                    child: Image.memory(
                                      image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 25),
                      ] else if (images.isEmpty &&
                          widget.project['IMAGES_IDS'] != null) ...[
                        Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ],

                      // Botões de ação
                      Text(
                        'Ações',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.title,
                        ),
                      ),
                      SizedBox(height: 15),

                      // Botão Nova Visita
                      _buildActionButton(
                        icon: Icons.calendar_today,
                        label: 'Nova Visita',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewVisitScreen(
                                projectId: widget.project['ID'],
                                projectName: widget.project['PROJECT_NAME'],
                                clientName: widget.project['CLIENT_NAME'],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),

                      // Botão Adicionar Item
                      // Botão Mostrar Visitas
                      _buildActionButton(
                        icon: Icons.list_alt,
                        label: 'Mostrar Visitas',
                        color: Colors.blueAccent,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            clipBehavior: Clip.hardEdge,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
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
                                    SizedBox(height: 20),
                                    Expanded(
                                      child: visits == null
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : visits.isEmpty
                                          ? Center(
                                              child: Text(
                                                "Nenhuma visita encontrada.",
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: visits.length,
                                              itemBuilder: (context, index) {
                                                final visita = visits[index];
                                                return Card(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    side: BorderSide(
                                                      color: AppColors.border,
                                                    ),
                                                  ),
                                                  elevation: 0,
                                                  margin: EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                                  child: ListTile(
                                                    title: Text(
                                                      visita['VISIT_NAME'],
                                                    ),
                                                    subtitle: Text(
                                                      visita['NOTE'] ?? '',
                                                    ),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              VisitDetailsScreen(
                                                                visit:
                                                                    visits[index],
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
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

                      // Botão Editar Projeto
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Editar Projeto',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProjectScreen(project: widget.project),
                            ),
                          );
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

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
        SizedBox(height: 15),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Icon(icon, size: 20, color: AppColors.primary)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.title,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Projeto'),
          content: Text(
            'Tem certeza que deseja excluir este projeto? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implementar lógica de exclusão
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Projeto excluído com sucesso!'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
