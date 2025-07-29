import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:esolar_app/components/colors.dart';
import 'package:esolar_app/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class VisitDetailsScreen extends StatefulWidget {
  final visit;

  const VisitDetailsScreen({super.key, required this.visit});

  @override
  State<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  bool loading = false;
  List<Uint8List> externalHouseImages = [];
  List<Uint8List> electricalCounterImages = [];
  List<Uint8List> electricalPanelImages = [];
  List<Uint8List> invoiceImages = [];
  List<Map<String, dynamic>> visitMaterials = [];
  var allMaterials;

  @override
  void initState() {
    super.initState();
    loadVisitImages();
    loadMaterials();
  }

  Future<void> loadVisitImages() async {
    var url = Uri.parse(Urls().url['getImages']!);

    // Carregar imagens do exterior da casa
    if (widget.visit['EXTERNAL_HOUSE_IDS'] != null &&
        widget.visit['EXTERNAL_HOUSE_IDS'].isNotEmpty) {
      await _loadImageCategory(
        widget.visit['EXTERNAL_HOUSE_IDS'],
        externalHouseImages,
      );
    }

    // Carregar imagens do contador elétrico
    if (widget.visit['ELETRICAL_COUNTER'] != null &&
        widget.visit['ELETRICAL_COUNTER'].isNotEmpty) {
      await _loadImageCategory(
        widget.visit['ELETRICAL_COUNTER'],
        electricalCounterImages,
      );
    }

    // Carregar imagens do quadro elétrico
    if (widget.visit['ELETRICAL_PANEL'] != null &&
        widget.visit['ELETRICAL_PANEL'].isNotEmpty) {
      await _loadImageCategory(
        widget.visit['ELETRICAL_PANEL'],
        electricalPanelImages,
      );
    }

    // Carregar imagens das faturas
    if (widget.visit['INVOICES'] != null &&
        widget.visit['INVOICES'].isNotEmpty) {
      await _loadImageCategory(widget.visit['INVOICES'], invoiceImages);
    }
  }

  Future<void> _loadImageCategory(
    String imageIds,
    List<Uint8List> targetList,
  ) async {
    var url = Uri.parse(Urls().url['getImages']!);
    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'ids': imageIds},
    );

    if (response.statusCode == 200) {
      var base64Images = jsonDecode(response.body)['images'];
      for (var base64 in base64Images) {
        setState(() {
          targetList.add(base64Decode(base64));
        });
      }
    }
  }

  Future<void> loadMaterials() async {
    var url = Uri.parse(Urls().url['getVisitAddInfo']!);
    var response = await http.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      allMaterials = jsonDecode(response.body)['materials'];

      // Parse dos materiais da visita
      if (widget.visit['MATERIALS'] != null &&
          widget.visit['MATERIALS'].isNotEmpty) {
        try {
          List<dynamic> materials = jsonDecode(widget.visit['MATERIALS']);
          visitMaterials = materials.cast<Map<String, dynamic>>();
        } catch (e) {
          print("Erro ao fazer parse dos materiais: $e");
        }
      }
      visitMaterials.forEach((material) {
        allMaterials.forEach((materialWValue){
          if(material['ID'] == materialWValue['ID']){
            print(materialWValue);
            setState(() {
              budget += (num.parse(materialWValue['VALUE']) * material['VALUE']);
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

  String getMaterialName(int materialId) {
    if (allMaterials == null) return 'Carregando...';
    var material = allMaterials.firstWhere(
      (m) => m['ID'] == materialId,
      orElse: () => {'NAME': 'Material desconhecido'},
    );
    return material['NAME'];
  }

  String getMaterialValue(int materialId) {
    if (allMaterials == null) return 'Carregando...';
    var material = allMaterials.firstWhere(
      (m) => m['ID'] == materialId,
      orElse: () => {'NAME': 'Material desconhecido'},
    );
    return material['VALUE'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.visit['VISIT_NAME'])),
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.title),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da visita
            Text(
              widget.visit['VISIT_NAME'],
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.title,
              ),
            ),
            Text(
               budgetLoaded ? 
              'Orçamento: ' + budget.toString() + '€': 'A carregar...',
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
                      // Informações básicas da visita
                      _buildInfoSection("Informações da Visita", [
                        _buildInfoRow(
                          Icons.business,
                          "Tipologia de Cliente",
                          widget.visit['CLIENT_TIPOLOGY'] ?? 'Não informado',
                        ),
                        _buildInfoRow(
                          Icons.build,
                          "Tipologia de Instalação",
                          widget.visit['INSTALL_TIPOLOGY'] ?? 'Não informado',
                        ),
                        if (widget.visit['NOTE'] != null &&
                            widget.visit['NOTE'].isNotEmpty)
                          _buildInfoRow(
                            Icons.note,
                            "Observações",
                            widget.visit['NOTE'],
                          ),
                      ]),

                      SizedBox(height: 25),

                      // Materiais utilizados
                      if (visitMaterials.isNotEmpty) ...[
                        _buildInfoSection("Materiais Utilizados", [
                          ...visitMaterials
                              .map(
                                (material) => _buildMaterialRow(
                                  getMaterialName(material['ID']) +
                                      ' - ' +
                                      getMaterialValue(material['ID']) +
                                      '€',
                                  material['VALUE'].toString(),
                                ),
                              )
                              .toList(),
                        ]),
                        SizedBox(height: 25),
                      ],

                      // Imagens do Exterior da Casa
                      if (externalHouseImages.isNotEmpty) ...[
                        _buildImageSection(
                          "Exterior da Casa",
                          externalHouseImages,
                        ),
                        SizedBox(height: 25),
                      ],

                      // Imagens do Contador Elétrico
                      if (electricalCounterImages.isNotEmpty) ...[
                        _buildImageSection(
                          "Contador Elétrico",
                          electricalCounterImages,
                        ),
                        SizedBox(height: 25),
                      ],

                      // Imagens do Quadro Elétrico
                      if (electricalPanelImages.isNotEmpty) ...[
                        _buildImageSection(
                          "Quadro Elétrico",
                          electricalPanelImages,
                        ),
                        SizedBox(height: 25),
                      ],

                      // Imagens das Faturas
                      if (invoiceImages.isNotEmpty) ...[
                        _buildImageSection("Faturas", invoiceImages),
                        SizedBox(height: 25),
                      ],

                      // // Botões de ação
                      // Text(
                      //   'Ações',
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.w600,
                      //     color: AppColors.title,
                      //   ),
                      // ),
                      // SizedBox(height: 15),

                      // // Botão Editar Visita
                      // _buildActionButton(
                      //   icon: Icons.edit,
                      //   label: 'Editar Visita',
                      //   color: AppColors.primary,
                      //   onTap: _editVisit,
                      // ),
                      // SizedBox(height: 10),

                      // // Botão Gerar Relatório
                      // _buildActionButton(
                      //   icon: Icons.description,
                      //   label: 'Gerar Relatório',
                      //   color: Colors.green,
                      //   onTap: _generateReport,
                      // ),
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

  Widget _buildMaterialRow(String materialName, String quantity) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.construction_outlined, size: 20, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              materialName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.title,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              quantity,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String title, List<Uint8List> images) {
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: images.asMap().entries.map((entry) {
              int index = entry.key;
              Uint8List image = entry.value;

              return Padding(
                padding: EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          body: PhotoViewGallery.builder(
                            itemCount: images.length,
                            builder: (context, index) {
                              return PhotoViewGalleryPageOptions(
                                imageProvider: MemoryImage(images[index]),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.covered * 2,
                              );
                            },
                            scrollPhysics: BouncingScrollPhysics(),
                            backgroundDecoration: BoxDecoration(
                              color: Colors.black,
                            ),
                            pageController: PageController(initialPage: index),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    width: 120,
                    height: 120,
                    child: Image.memory(image, fit: BoxFit.cover),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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

  void _editVisit() {
    // Navegar para tela de edição da visita
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar visita em desenvolvimento'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _generateReport() {
    // Gerar relatório da visita
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Relatório gerado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Visita'),
          content: Text(
            'Tem certeza que deseja excluir esta visita? Esta ação não pode ser desfeita.',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Visita excluída com sucesso!'),
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
