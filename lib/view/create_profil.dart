
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:sporta/models/profil.dart';


class PseudoDialog extends StatefulWidget {
  const PseudoDialog({super.key});

  @override
  State<PseudoDialog> createState() => _PseudoDialogState();
}

class _PseudoDialogState extends State<PseudoDialog> {

  final _pseudoC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content : 
      Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children : [ 
        const Text("Entrer votre pseudo"),
        TextFormField(
          controller: _pseudoC,
          decoration: const InputDecoration(
            hintText: 'Pseudo',
          ),

        )]) ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () { 
              //validate
              if (_formKey.currentState!.validate()) {
                context.read<Profil>().pseudo = _pseudoC.text;
                Navigator.pop(context, _pseudoC.text);
                }
              },
            child: const Text('Valider'),
          ),
        ],
        );
  }
}