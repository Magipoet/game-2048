import 'package:flutter/material.dart';

class FocusManagerWidget extends StatefulWidget {
  final Widget child;
  final FocusNode focusNode;

  const FocusManagerWidget({
    super.key,
    required this.child,
    required this.focusNode,
  });

  @override
  State<FocusManagerWidget> createState() => _FocusManagerWidgetState();
}

class _FocusManagerWidgetState extends State<FocusManagerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(widget.focusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(widget.focusNode);
      },
      child: widget.child,
    );
  }
}
