import 'package:flutter/material.dart';
import 'package:sporta/view/calendar.dart';
import 'package:sporta/view/profil.dart';
import 'package:sporta/view/seance.dart';
import 'package:sporta/view/home.dart';


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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MainApp(),
    );
  }
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<Widget> _pages = [
    const HomePage(),
    const CalendarPage(),
    const SeancePage(),
    const ProfilPage(),
  ];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backColor = Theme.of(context).colorScheme.primaryContainer;
    return Scaffold(
    bottomNavigationBar: BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6,
      clipBehavior: Clip.antiAlias,
      child: 
      BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      // ignore: prefer_const_literals_to_create_immutables
      items: [
         BottomNavigationBarItem(icon: const Icon(Icons.home), 
          label: "Accueil",
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_outlined), 
          label : "Calendrier",
          backgroundColor: backColor),
         BottomNavigationBarItem(icon: const Icon(Icons.view_list_rounded), 
          label: "Seances",
          backgroundColor: backColor),
         BottomNavigationBarItem(icon: const Icon(Icons.person),
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
    floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
    floatingActionButton: new FloatingActionButton(
        
        onPressed:(){},
        tooltip: 'Créer une séance',
        child: new Icon(Icons.add),
      ),
      body: _pages.elementAt(_selectedIndex),
    );
  }
}