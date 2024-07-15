import 'package:flutter/material.dart';



class QuitDialog extends StatelessWidget {
  const QuitDialog({
    super.key,
    this.message,
    this.onValidate,
    this.onCancel,
  });

  final String? message;
  final Function? onValidate;
  final Function? onCancel;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(message ?? "Voulez-vous quitter sans sauvegarder ?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) onCancel!();
          },
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onValidate != null) onValidate!();
          },
          child: const Text("Valider"),
        ),
      ],
    );
  }
}