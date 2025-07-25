import 'package:esolar_app/components/colors.dart';
import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  var label;
  var controller;
  var place;
  var password;
  Input({super.key, 
  required this.label,
  required this.place,
  this.controller,
  this.password = false,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            widget.label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        SizedBox(height: 5),
        TextField(
          obscureText: widget.password,
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.place,
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
        ),
      ],
    );
  }
}
