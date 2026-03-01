import 'package:flutter/material.dart';

class PasscodeScreen extends StatelessWidget {
  const PasscodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Passcode Screen\n(Clean Architecture Ready)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
