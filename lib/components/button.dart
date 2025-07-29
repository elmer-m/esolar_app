import 'package:esolar_app/components/colors.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  var icon;
  var label;
  var functionVoid;
  bool loading;

  Button({
    super.key,
    required this.label,
    this.functionVoid,
    this.loading = false,
    this.icon,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.functionVoid(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: widget.loading
              ? CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white,),
                    SizedBox(width: 5,),
                    Text(
                      widget.label.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
