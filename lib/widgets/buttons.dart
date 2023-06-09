import 'package:flutter/material.dart';



class BasicButton extends StatelessWidget {
  const BasicButton({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
            height : 100,
            margin: const EdgeInsets.all(10),
            //width : 100,
            child : TextButton(
              onPressed: () => null, 
              style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.amber.shade200),
                          shape: const MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))))
                          
              ),
              child: Text(title,textAlign: TextAlign.center,),
              ),
          );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, required this.title, required this.action});
  final String title;
  final void Function() action;

  @override
  Widget build(BuildContext context) {
    return Container(
            margin: const EdgeInsets.all(10),
            height : 100,
            //width : 100,
            child : TextButton(
              onPressed: () => action(), 
              
              style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.amber),
                          shape: MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))))
              ),
              child: Text(title,textAlign: TextAlign.center,),
  ),
          );
  }
}
