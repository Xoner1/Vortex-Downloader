import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart'; // To navigate to MainTabScreen

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  String _input = '';
  String? _savedPasscode;
  bool _isSettingUp = false;

  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  Future<void> _loadPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPasscode = prefs.getString('passcode');
      _isSettingUp = _savedPasscode == null;
    });
  }

  Future<void> _savePasscode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('passcode', code);
    setState(() {
      _savedPasscode = code;
      _isSettingUp = false;
      _input = '';
    });
  }

  void _onKeyPress(String key) {
    if (_input.length < 4) {
      setState(() {
        _input += key;
      });
      if (_input.length == 4) {
        if (_isSettingUp) {
          _savePasscode(_input);
        } else {
          if (_input == _savedPasscode) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainTabScreen()),
            );
          } else {
            setState(() {
              _input = '';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incorrect Passcode', textAlign: TextAlign.center)),
            );
          }
        }
      }
    }
  }

  void _onDelete() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isSettingUp ? 'Set a 4-Digit Passcode' : 'Enter Passcode',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _input.length ? const Color(0xFF0A84FF) : Colors.grey.withOpacity(0.3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 60),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var j = 1; j <= 3; j++) _buildKey((i * 3 + j).toString()),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80),
            _buildKey('0'),
            _buildKey('⌫', onTap: _onDelete),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => _onKeyPress(label),
      child: Container(
        margin: const EdgeInsets.all(10),
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1C1C1E).withOpacity(0.8),
          border: Border.all(color: Colors.white12, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }
}
