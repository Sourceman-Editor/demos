import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sourcemanv1/datatype.dart';
import 'package:sourcemanv1/event.dart';
import 'package:sourcemanv1/managers/env_var_manager.dart';
import 'package:sourcemanv1/widgets/rune.dart';
import 'package:sourcemanv1/parser.dart';
import 'package:sourcemanv1/widgets/var.dart';

class LineWidget extends StatefulWidget {
  final String lineText;
  final int lineCount;
  const LineWidget({required this.lineText, required this.lineCount, super.key});

  @override
  State<StatefulWidget> createState() => _LineWidgetState();

}

class _LineWidgetState extends State<LineWidget> {
  
  List<Rune> runes = [];

  @override
  void initState() {
    runes = parseline(widget.lineText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EnvVarManager manager = Provider.of<EnvVarManager>(context);
    EventManager events = Provider.of<EventManager>(context);

    List<Widget> children = [];
    for (var i = 0; i < runes.length; i++) {
      Rune r = runes[i];
      if (r.isVar) {
        children.add(VarWidget(
          posX: i, 
          posY: widget.lineCount, 
          varKey: r.varKey??"", 
          events: events,
          manager: manager,
          key: UniqueKey()
        ));
      } else {
        children.add(
          RuneWidget(
            eventManager: events,
            posX: i, 
            posY: widget.lineCount, 
            propagateOnPanDown: _propagateOnPanDown,
            propagateOnTapUp: _propagateOnTapUp,
            text: r.ch??""
          )
        );
      }
    }
    children.add(
      RuneWidget(
        eventManager: events,
        posX: runes.length, 
        posY: widget.lineCount, 
        text: "",
        propagateOnPanDown: _propagateOnPanDown,
        propagateOnTapUp: _propagateOnTapUp,
        isPlaceHolder: true,
      )
    ); // placeholder for end of line cursor
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: children,
    );
  }

  void _propagateOnPanDown() {

  }

  void _propagateOnTapUp() {

  }
}