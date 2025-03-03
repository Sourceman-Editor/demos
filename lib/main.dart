import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sourcemanv1/datatype.dart';

import 'package:sourcemanv1/event.dart';
import 'package:sourcemanv1/managers/doc_manager.dart';
import 'package:sourcemanv1/managers/env_var_manager.dart';
import 'package:sourcemanv1/managers/profile_manager.dart';
import 'package:sourcemanv1/widgets/line.dart';
import 'package:sourcemanv1/widgets/profile_accordion.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 206, 178, 255)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  EventManager eventManager = EventManager();
  EnvVarManager envVarManager = EnvVarManager();
  ProfileManager profileManager = ProfileManager();
  DocManager docManager = DocManager();
  Doc document = Doc(key: "default", name: "default", lines: []);
  bool loading = true;

  @override
  void initState() {
    docManager.loadDocFromPath("test_data", "testdoc.yaml", profileManager, envVarManager).then((doc) => {
      setState(() {
        loading = false;
        eventManager.emit<DocumentReadyEvent>(DocumentReadyEvent());
        document = doc;
      })
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    
    Widget main = const Center(child: Icon(Icons.pending),);

    if (!loading) {
      List<Widget> lines = [];
      for (var i = 0; i < document.lines.length; i++) {
        lines.add(LineWidget(lineText: document.lines[i], lineCount: i));
      }
      main = Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines,
              ),
            ),
            Expanded(
              flex: 1,
              child: ProfileAccordion(documentKey: document.key)
            )
          ],
        ),
      );  
    }

    return MultiProvider(
      providers: [
        Provider(create: (context) => eventManager),
        Provider(create: (context) => envVarManager),
        Provider(create: (context) => profileManager),
        Provider(create: (context) => docManager),
      ],
      child: main,
    );
  }
}
