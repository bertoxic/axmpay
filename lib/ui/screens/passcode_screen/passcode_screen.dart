import 'dart:convert';

import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../main.dart';

class PasscodeInputScreen extends StatefulWidget {
  const PasscodeInputScreen({super.key});

  @override
  _PasscodeInputScreenState createState() => _PasscodeInputScreenState();
}

class _PasscodeInputScreenState extends State<PasscodeInputScreen> {
  String _passcode = '';

  void _addDigit(String digit) {
    if (_passcode.length < 4) {
      setState(() {
        _passcode += digit;
      });
    }
  }

  void _removeDigit() {
    if (_passcode.isNotEmpty) {
      setState(() {
        _passcode = _passcode.substring(0, _passcode.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          color: Colors.white
        ),
        padding:  EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          children: [
            // const CircleAvatar(
            //   radius: 40,
            //   backgroundImage: AssetImage('assets/profile_image.jpg'), // Replace with profile image
            // ),
            const Text(
              'Enter Your Passcode!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin:  EdgeInsets.symmetric(horizontal: 8.w),
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _passcode.length ? Colors.blue : Colors.grey.shade300,
                  ),
                );
              }),
            ),
             SizedBox(height: 20.h),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              children: List.generate(12, (index) {
                if (index == 9) {
                  return _buildKeypadButton(
                    child:   Icon(Icons.arrow_back, color: colorScheme.primary),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  );
                } else if (index == 10) {
                  return _buildKeypadButton(
                    child: const Text('0', style: TextStyle(fontSize: 24)),
                    onPressed: () => _addDigit('0'),
                  );
                } else if (index == 11) {
                  return _buildKeypadButton(
                    child:  Icon(Icons.backspace, color: colorScheme.primary),
                    onPressed: _removeDigit,
                  );
                } else {
                  return _buildKeypadButton(
                    child: Text('${index + 1}', style: const TextStyle(fontSize: 24)),
                    onPressed: () => _addDigit('${index + 1}'),
                  );
                }
              }),
            ),
             SizedBox(height: 32.h),

            _buildContinueButton(context, _passcode)
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton({required Widget child, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin:  const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Center(child: child),
      ),
    );
  }
  Widget _buildContinueButton( BuildContext context, String passcode) {
    return AnimatedOpacity(
      opacity: passcode.length == 4 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: passcode.length == 4
            ? () async {
          bool? correctPass = await confirmPasscode(passcode);
          Navigator.pop(context,correctPass);
        }
            : null,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.primary,
          minimumSize:  Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('SEND'),
      ),
    );

  }
  Future<bool?> confirmPasscode(String passcode)async{
    final storage = FlutterSecureStorage();
    String? passCodeMapString = await storage.read(key: "passcodeMap");
    var passCodeMap = jsonDecode(passCodeMapString??"");
    String pass = passCodeMap["passcode"];
    print("secondhand person is $pass vs first is $passcode, ... ${passcode==pass}");

    return (passcode==pass);
  }

}

