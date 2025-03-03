import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sourcemanv1/datatype.dart';

import 'package:sourcemanv1/event.dart';
import 'package:sourcemanv1/managers/env_var_manager.dart';
import 'package:sourcemanv1/widgets/rune.dart';

class VarWidget extends StatefulWidget {
  final int posX;
  final int posY;
  final EventManager events;
  final EnvVarManager manager;
  final String varKey;
  // TODO ref to var

  const VarWidget({
    required this.posX, 
    required this.posY, 
    required this.varKey, 
    required this.events, 
    required this.manager,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _VarWidgetState();

}

class _VarWidgetState extends State<VarWidget> {
  String text = "?";
  // static bool cursorDragging = false;
  StreamSubscription? documentReadySubscription;
  StreamSubscription? profileOpenSubscription;

  static Border defaultBorder = const Border(
    left: BorderSide(width: 0.1, color: Colors.black,),
    right: BorderSide(width: 0.1, color: Colors.black,),
    top: BorderSide(width: 0.1, color: Colors.black,),
    bottom: BorderSide(width: 0.1, color: Colors.black,),
  );
  static TextStyle defaultStyle = const TextStyle(fontFamily: 'FiraCode', fontSize: 18, color: Color(0xff272822));

  void _loadValue() {
    EnvVar? v = widget.manager.findVarByKey("default", widget.varKey);
    setState(() {
      text = v?.value?? "?";
    });
  }

  void _changeValue(ProfileOpenEvent event) {
    EnvVar? v = widget.manager.findVarByKey(event.profileKey, widget.varKey);
    setState(() {
      text = v?.value?? "?";
    });
  }

  @override
  void initState() {
    profileOpenSubscription = widget.events.listen<ProfileOpenEvent>(_changeValue);
    _loadValue();
    super.initState();
  }

  @override
  void dispose() {
    documentReadySubscription?.cancel();
    profileOpenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MouseRegion(
        cursor: WidgetStateMouseCursor.clickable,
        child: Row(
          children: [
            RuneWidget(
              eventManager: widget.events,
              posX: widget.posX, 
              posY: widget.posY, 
              text: "", 
              propagateOnPanDown: () {},
              propagateOnTapUp: () {},
              isPlaceHolder: true,
            ),
            Container(
              decoration: BoxDecoration(border: defaultBorder),
              child: RichText(
                text: TextSpan(
                  text: text,
                  style: defaultStyle,
                )
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
      onPanDown: (DragDownDetails details) {
        
      },
      onTapCancel: () {
        
      },
      onPanEnd: (DragEndDetails details) {
        
      }
    );
  }
}