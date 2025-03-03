import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sourcemanv1/event.dart';

class RuneWidget extends StatefulWidget {
  final EventManager eventManager;
  final int posX;
  final int posY;
  final String text;
  final bool isPlaceHolder;
  final Function propagateOnPanDown;
  final Function propagateOnTapUp;
  const RuneWidget({
    required this.eventManager,
    required this.posX, 
    required this.posY, 
    required this.text, 
    required this.propagateOnTapUp,
    required this.propagateOnPanDown,
    this.isPlaceHolder=false,
    super.key, 
  });

  @override
  State<StatefulWidget> createState() => _RuneWidgetState();
}

class _RuneWidgetState extends State<RuneWidget> {
  static Color highlightColor = const Color.fromARGB(255, 110, 147, 226);
  static TextStyle defaultStyle = const TextStyle(fontFamily: 'FiraCode', fontSize: 18, color: Color(0xff272822));
  static Border cursorBorder = const Border(left: BorderSide(width: 0.8, color: Colors.black,));
  static Border defaultBorder = const Border(left: BorderSide(width: 0.8, color: Colors.white,));
  static Border highlightBorder = const Border(left: BorderSide(width: 0.8, style: BorderStyle.none,));
  static BoxShadow highlightBoxShadow = const BoxShadow(color: Color.fromARGB(255, 110, 147, 226), offset: Offset(1, 0));
              

  static BoxDecoration defaultDecoration = const BoxDecoration();
  static BoxDecoration cursorDecoration = const BoxDecoration(
    border: Border(
      left: BorderSide(width: 1, color: Colors.yellow,)
    )
  );

  List<Widget>? currChildren;
  TextStyle? currStyle;
  Decoration? currDecoration;
  Border? currBorder;
  StreamSubscription? cursorEventSubscription;
  Timer? cursorTimer;
  static bool cursorDragging = false;
  static int selectionStartX = -1;
  static int selectionStartY = -1;
  Color? currHighlightColor;
  List<BoxShadow> boxShadows = [];
  StreamSubscription? highlightSelectionSubscription;
  StreamSubscription? cursorDraggingSubscription;
  // events

  void _blinkCursor() {
    cursorTimer ??= Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (currBorder == defaultBorder) {
        setState(() {
          currBorder = cursorBorder;
        });
      } else {
        setState(() {
          currBorder = defaultBorder;
        });
      }
    });
  }

  void _hideCursor(CursorClickEvent e) {
    cursorEventSubscription?.cancel();
    cursorTimer?.cancel();
    cursorTimer = null;
    if (currBorder != highlightBorder) {
      setState(() {
        currBorder = defaultBorder;
      });
    }
  }

  void _showCursor(EventManager events) {
    cursorEventSubscription?.cancel();
    events.emit<CursorClickEvent>(CursorClickEvent());
    cursorEventSubscription = events.listen<CursorClickEvent>(_hideCursor);
    if (currBorder != highlightBorder) {
      setState(() {
        currBorder = cursorBorder;

      });
      _blinkCursor();
    }
  }

  void _highlightSelection(EventManager events) {
    if (widget.isPlaceHolder) {
      return;
    }
    setState(() {
      boxShadows.add(highlightBoxShadow);
      currHighlightColor = highlightColor;
      currBorder = highlightBorder;
    });
  }

  void _cancelSelection(event) {
    setState(() {
      boxShadows.remove(highlightBoxShadow);
      currHighlightColor = Colors.transparent;
      currBorder = defaultBorder;
    });
  }

  void _selectionHandler(CursorDraggingEvent e) {
    // check if this widget is inside selection or not
    int smallerY = min(selectionStartY, e.posY);
    int largerY = max(selectionStartY, e.posY);
    int smallerX = selectionStartX;
    int largerX = e.posX;
    if (smallerY == e.posY) {
      smallerX = e.posX;
      largerX = selectionStartX;
    }
    if (smallerY == largerY) {
      smallerX = min(selectionStartX, e.posX);
      largerX = max(selectionStartX, e.posX);
    }
    // online situation
    if (smallerY == largerY && widget.posY == smallerY) {
      if (smallerX <= widget.posX && widget.posX <= largerX) {
        _highlightSelection(widget.eventManager);
      }
    }
    // multiline situation
    else if (widget.posY > smallerY && widget.posY < largerY) {
      _highlightSelection(widget.eventManager);
    } 
    else if (widget.posY == smallerY) {
      if (widget.posX >= smallerX) {
        _highlightSelection(widget.eventManager);
      }
    }
    else if (widget.posY == largerY) {
      if (widget.posX <= largerX) {
        _highlightSelection(widget.eventManager);
      }
    }
    else if (currBorder == highlightBorder) {
      _cancelSelection(widget.eventManager);
    }
  }

  @override
  void initState() {
    currStyle = defaultStyle;
    currBorder = defaultBorder;
    currChildren = [
      RichText(
        text: TextSpan(
          text: widget.text,
          style: currStyle,
        )
      )
    ];
    if (widget.isPlaceHolder) {
      currChildren?.add(const SizedBox(width: 3));
    }
    cursorDraggingSubscription = widget.eventManager.listen<CursorDraggingEvent>(_selectionHandler);
    highlightSelectionSubscription ??= widget.eventManager.listen<SelectionCancelEvent>(_cancelSelection);
    super.initState();
  }

  @override
  void dispose() {
    cursorTimer?.cancel();
    cursorEventSubscription?.cancel();
    highlightSelectionSubscription?.cancel();
    cursorDraggingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("${context.hashCode}");
    return GestureDetector(
      child: MouseRegion(
        cursor: WidgetStateMouseCursor.textable,
        child: Container(
          decoration: BoxDecoration(
            border: currBorder,
            boxShadow: boxShadows,
            color: currHighlightColor,
          ),
          child: Row(
            children: currChildren?? [],
          ),
        ),
        onEnter: (PointerEnterEvent e) {
          if (cursorDragging) {
            _showCursor(widget.eventManager);
            widget.eventManager.emit<CursorDraggingEvent>(
              CursorDraggingEvent(posX: widget.posX, posY: widget.posY)
            );
          }
        },
        onExit: (PointerExitEvent e) {
          if (cursorDragging) {
            _highlightSelection(widget.eventManager);
          }
        }
      ),
      onPanDown: (DragDownDetails details) {
        widget.eventManager.emit<SelectionCancelEvent>(
          SelectionCancelEvent(posX: widget.posX, posY: widget.posY)
        );
        setState(() {
          cursorDragging = true;
          selectionStartX = widget.posX;
          selectionStartY = widget.posY;
        });
        _showCursor(widget.eventManager);
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          cursorDragging = false;
        });
        widget.eventManager.emit<SelectionCancelEvent>(
          SelectionCancelEvent(posX: widget.posX, posY: widget.posY)
        );
        Function.apply(widget.propagateOnTapUp, null);
      },
      // onTapCancel: () {
      //   _hideCursor();
      // },
      onPanEnd: (DragEndDetails details) {
        setState(() {
          cursorDragging = false;
        });
        widget.eventManager.emit<SelectionEndEvent>(SelectionEndEvent());
        // _hideCursor();
      },
      onSecondaryTapUp: (TapUpDetails details) {
        showMenu(
          context: context, 
          position: RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, details.globalPosition.dx, details.globalPosition.dy),
          popUpAnimationStyle: AnimationStyle(
            duration: Duration.zero,
          ),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              onTap: () {
                print("hi");
              },
              child: const Text("Mark Variable")
            ),
          ]
        );
      }
    );
  }
}

