import 'package:flutter/material.dart';


class UIComponentInputWidget extends StatefulWidget {

  final bool obsecureText;

  final String hintText;

  final IconData iconData;

  final ValueChanged<String> onChanged;

  final TextEditingController controller;


  UIComponentInputWidget({Key key, this.hintText, this.iconData, this.onChanged, this.controller, this.obsecureText = false}) : super (key : key);


  @override
  _UIComponentInputWidgetState createState() => new _UIComponentInputWidgetState();

}

class _UIComponentInputWidgetState extends State<UIComponentInputWidget> {
  @override
  Widget build(BuildContext context) {
    return new TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: widget.obsecureText,
      decoration: new InputDecoration(
        hintText: widget.hintText,
        icon: widget.iconData == null ? null : new Icon(widget.iconData),
      ),
    );
  }

}