import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sporta/models/exercice_db.dart';
import 'package:sporta/models/seance.dart';
import 'package:sporta/models/muscle.dart';
import 'package:sporta/models/history.dart';
import 'package:sporta/models/current_seance.dart';
import 'package:sporta/models/profil.dart';
import 'package:sporta/models/quest.dart';

import 'package:sporta/view/basicadd.dart';
import 'package:sporta/view/calendar.dart';
import 'package:sporta/view/profil.dart';
import 'package:sporta/view/seance_templates.dart';
import 'package:sporta/view/seance_page.dart';
import 'package:sporta/view/home.dart';
import 'package:sporta/view/create_profil.dart';

import 'package:sporta/widgets/buttons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => HistoryModel()),
          ChangeNotifierProvider(create: (context) => BodyModel()),
          ChangeNotifierProvider(create: (context) => Profil()),
          ChangeNotifierProvider(create: (context) => ExerciceDB()),
          ChangeNotifierProvider(create: (context) => SeanceDB()),
          ChangeNotifierProvider(create: (context) => QuestDB()),
          ChangeNotifierProvider(create: (context) => CurrentTemplateSeance()),
          ChangeNotifierProvider(create: (context) => CurrentExecSeance()),
        ],
        child: MaterialApp(
          title: 'Sporta',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back t: Colors.blue,

            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: const MainApp(),
        ));
  }
}

void plusClic(BuildContext context) {
  showDialog(
      context: context,
      builder: ((context) => Dialog(
          // title: const Text(" ",
          //         textAlign: TextAlign.center,
          //         style: TextStyle(color: Colors.redAccent)),
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(children: [
                      Expanded(
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: const BasicButton(
                                  title: "Lancer une séance vide")))
                    ]),
                    Row(children: [
                      Expanded(
                        child: ActionButton(
                          action: () {
                            Navigator.of(context).pop();
                            context.read<CurrentTemplateSeance>().clear();
                            // On crée une nouvelle séance courrante
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => Consumer3<HistoryModel,
                                        BodyModel, ExerciceDB>(
                                    builder: (context, history, body, exercices,
                                            child) =>
                                        TemplateCreatorPage(
                                            history: history,
                                            body: body,
                                            exercices: exercices)))));
                          },
                          title: "Créer un modèle de séance",
                        ),
                      )
                    ]),
                    //const BasicButton(title: ),
                    Row(children: [
                      Expanded(
                        child: ActionButton(
                          title: "Ajouter une séance basique",
                          action: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => Consumer<HistoryModel>(
                                    builder: (context, value, child) =>
                                        BasicAddition(history: value)))));
                          },
                        ),
                      )
                    ]),
                    Row(children: [
                      Expanded(
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child:
                                  const BasicButton(title: "Lancer un timer")))
                    ]),
                    //const BasicButton(title: "Lancer un timer"),
                  ])))));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<Widget> _pages = [
    HomePage(),
    const CalendarPage(),
    Consumer2<HistoryModel, SeanceDB>(
        builder: (context, history, seanceDB, child) =>
            SeancePage(history: history, seanceDB: seanceDB)),
    const ProfilPage(),
  ];
  int _selectedIndex = 0;
  late List<Muscle> muscles;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late Future<bool> _isLoaded;

  Future<bool> load(BuildContext context) async {
    await context.read<CurrentExecSeance>().getPreferences();
    print("load 1");
    await context.read<CurrentTemplateSeance>().getPreferences();
    await context.read<ExerciceDB>().loadExs();
    await context.read<QuestDB>().getPreferences();
    print("load 2");
    await context.read<Profil>()
      ..getPreferences()
      ..loadMusclesLevel();
      print("load full");

    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    _isLoaded = load(context);
    print(_isLoaded);
  }

  @override
  Widget build(BuildContext context) {
    Color backColor = Theme.of(context).colorScheme.primaryContainer;
    return FutureBuilder<bool>(
        future: _isLoaded,
         builder: (context, AsyncSnapshot<bool> snapshot) {
          // print(snapshot.hasData);
         if (snapshot.hasData){
              return Scaffold(
                bottomNavigationBar: BottomAppBar(
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 6,
                  clipBehavior: Clip.antiAlias,
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    // ignore: prefer_const_literals_to_create_immutables
                    items: [
                      BottomNavigationBarItem(
                          icon: const Icon(Icons.home),
                          label: "Accueil",
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiaryContainer),
                      BottomNavigationBarItem(
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: "Calendrier",
                          backgroundColor: backColor),
                      BottomNavigationBarItem(
                          icon: const Icon(Icons.view_list_rounded),
                          label: "Seances",
                          backgroundColor: backColor),
                      BottomNavigationBarItem(
                          icon: const Icon(Icons.person),
                          label: "Profil",
                          backgroundColor: backColor),
                    ],
                    currentIndex: _selectedIndex,
                    elevation: 30,
                    onTap: _onItemTapped,
                    //showUnselectedLabels: true,
                    //backgroundColor: Colors.yellowAccent,//Theme.of(context).colorScheme.onPrimaryContainer,
                    //selectedItemColor: Theme.of(context).colorScheme.secondary,
                    //unselectedItemColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniCenterDocked,
                floatingActionButton: FloatingActionButton(
                  onPressed: () => plusClic(context),
                  tooltip: 'Créer une séance',
                  child: const Icon(Icons.add),
                ),
                body: _pages.elementAt(_selectedIndex),
              );
          } else if (snapshot.hasError) {
              // Dans le cas où nous obtenons une erreur
              return Center(
                  child: Text('Erreur lors du chargement des préférences'));
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
              body: Center(
                child: Row(children : [ CircularProgressIndicator(),
                Text(_isLoaded.toString()),])),
            );
        });
  }
}
