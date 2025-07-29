import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  final String label;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final Function(int)? onChanged;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const CounterWidget({
    super.key,
    required this.label,
    this.initialValue = 0,
    this.minValue = 0,
    this.maxValue = 999,
    this.onChanged,
    this.primaryColor,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  void _increment() {
    if (_currentValue < widget.maxValue) {
      setState(() {
        _currentValue++;
      });
      widget.onChanged?.call(_currentValue);
    }
  }

  void _decrement() {
    if (_currentValue > widget.minValue) {
      setState(() {
        _currentValue--;
      });
      widget.onChanged?.call(_currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;
    
    return Container(
      width: widget.width ?? 180,
      height: widget.height ?? 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Counter Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Decrease Button
                  Expanded(
                    flex: 3,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _currentValue > widget.minValue ? _decrement : null,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: _currentValue > widget.minValue
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      primaryColor.withOpacity(0.1),
                                      primaryColor.withOpacity(0.05),
                                    ],
                                  )
                                : null,
                          ),
                          child: Icon(
                            Icons.remove,
                            color: _currentValue > widget.minValue
                                ? primaryColor
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Value Display
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            _currentValue.toString(),
                            key: ValueKey(_currentValue),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Increase Button
                  Expanded(
                    flex: 3,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _currentValue < widget.maxValue ? _increment : null,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: _currentValue < widget.maxValue
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      primaryColor.withOpacity(0.1),
                                      primaryColor.withOpacity(0.05),
                                    ],
                                  )
                                : null,
                          ),
                          child: Icon(
                            Icons.add,
                            color: _currentValue < widget.maxValue
                                ? primaryColor
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}