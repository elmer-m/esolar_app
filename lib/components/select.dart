import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:esolar_app/components/colors.dart';
import 'package:flutter/material.dart';

class Select extends StatefulWidget {
  var selectLabel;
  var data;
  var controller;
  var label;
  var value;
  Select({super.key, required this.data, required this.label, required this.value, required this.selectLabel, this.controller});

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            widget.selectLabel,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        SizedBox(height: 5),
        DropDownTextField(
          controller: widget.controller,
          enableSearch: true,
          searchDecoration: InputDecoration(hintText: 'Pesquisar...', border: InputBorder.none),
          textFieldDecoration: InputDecoration(
            hintText: widget.selectLabel,
            contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.border, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          dropDownList:[
            ...widget.data.map((item) => 
              DropDownValueModel(name: item[widget.label] ?? 'Vazio', value: item[widget.value] ?? 'Vazio'),
            ).toList(),
          ],
        ),
      ],
    );
  }
}
