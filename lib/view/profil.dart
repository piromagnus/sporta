
import 'package:flutter/material.dart';
import 'package:sporta/models/exercice_db.dart';
import 'package:sporta/view/library.dart';
import 'package:sporta/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:sporta/models/muscle.dart';
import 'level.dart';


class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child:
          Column(
            children:[
              // Première ligne d'icon
              
              Row(
                children: [
                   Expanded(
                    flex : 1,
                    child : 
                        ActionButton(title:"Caractéristique",
                          action : () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>
                          Consumer<BodyModel>(builder: (context, body, child) 
                            => LevelPage()))),
                        
                        ),
                      ),
                   Expanded(
                    flex : 1,
                    child : 
                      ActionButton(title:"Bibliothèque", 
                        action: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => 
                          Consumer2<BodyModel,ExerciceDB>(builder: (context, body, exDB, child) 
                            => LibraryView(body: body, exDB: exDB,))))),
                  ),
                   const Expanded(
                    flex : 1,
                    child : 
                     BasicButton(title:"Quêtes"),
                  ),
              ],), 
              Row(
                
                
                children: [
                  Expanded(
                    flex:2,
                    child: 
                  Image.asset("assets/body.png",height: MediaQuery.of(context).size.height*0.7,)
                  ),
                  Expanded(child:
                     Column(
                      
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly
                      ,
                      children: [
                        SizedBox(height: (MediaQuery.of(context).size.height*0.7-200)/7,),
                        Row(children: const [Expanded(child:BasicButton(title:"Centre de Performance"))]),
                        SizedBox(height: (MediaQuery.of(context).size.height*0.7-200)/7,),
                        Row(children: const [Expanded(child:BasicButton(title:"Centre Médical"))]),
                        SizedBox(height: (MediaQuery.of(context).size.height*0.7-200)/7,),
                        Row(children: const [Expanded(child:BasicButton(title:"Paramètres"))]),
                        SizedBox(height: (MediaQuery.of(context).size.height*0.7-200)/7,),       
                    ])),
              ],
            )
          ],
        ))
          
    );
  }
}