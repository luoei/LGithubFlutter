import 'package:flutter/material.dart';

typedef void SelectedItemChanged<int>(int value);

class RepositoryDetailInfoSegementPage extends StatefulWidget implements PreferredSizeWidget {

  final List<String> titles;

  final SelectedItemChanged selectedItemChanged;

  final double height;

  RepositoryDetailInfoSegementPage({Key key, this.selectedItemChanged, this.titles, this.height = 70}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _RepositoryDetailInfoSegementPage();

  @override
  Size get preferredSize => Size.fromHeight(height);

}

class _RepositoryDetailInfoSegementPage extends State<RepositoryDetailInfoSegementPage> {

  int currentSelectedIndex = 0;

  _renderList() {
    List<Widget> list = new List();
    for(int idx = 0; idx < widget.titles.length; idx++){
      var style = idx == currentSelectedIndex ? TextStyle(color: Colors.white, fontSize: 18) : TextStyle(color: Colors.white70, fontSize: 18);
      Widget buttonWidget = Expanded(
        flex: 1,
        child: FlatButton(
          onPressed: (){
            if(currentSelectedIndex != idx){
              currentSelectedIndex = idx;
              widget.selectedItemChanged?.call(idx);
            }
            setState(() {
              currentSelectedIndex = idx;
            });
          },
          child: Text(widget.titles[idx], style: style,),
        ),
      );
      list.add(buttonWidget);
      list.add(new Container(width: 0.3, height: 25.0, color: Colors.white));
    }
    if(list.length>1)list.removeLast();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      margin: EdgeInsets.all(0),
      child:  Container(
        height: widget.height,
        child: Row(
          children: _renderList(),
        ),
      ),
    );
  }

}


