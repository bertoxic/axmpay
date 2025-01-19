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
  final double keypadSpacing = 16.0;

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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.9,
            maxHeight: isSmallScreen ? size.height * 0.9 : size.height * 0.6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible( // Allow dynamic height adjustment
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 20),
                      _buildPasscodeDots(),
                      SizedBox(height: 20),
                      _buildKeypad(context),
                      _buildContinueButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Column(
      children: [

        Text(
          'Enter Your Passcode',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Please enter your 4-digit security code',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPasscodeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < _passcode.length;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 16 : 12,
          height: isFilled ? 16 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? colorScheme.primary : Colors.grey[300],
            border: isFilled
                ? null
                : Border.all(color: Colors.grey[400]!, width: 1.5),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize = (constraints.maxWidth - (keypadSpacing * 4)) / 3;

        return Container(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            children: List.generate(4, (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (col) {
                  final index = row * 3 + col;
                  return _buildKeypadButton(
                    index: index,
                    size: buttonSize,
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildKeypadButton({required int index, required double size}) {
    Widget child;
    VoidCallback? onPressed;

    if (index == 9) {
      child = Icon(Icons.close, color: colorScheme.primary);
      onPressed = () => Navigator.of(context).pop();
    } else if (index == 10) {
      child = Text('0',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black87));
      onPressed = () => _addDigit('0');
    } else if (index == 11) {
      child = Icon(Icons.backspace_rounded, color: colorScheme.primary);
      onPressed = _removeDigit;
    } else {
      child = Text(
        '${index + 1}',
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87),
      );
      onPressed = () => _addDigit('${index + 1}');
    }

    return Padding(
      padding: EdgeInsets.all(keypadSpacing / 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 16.sp),
      child: AnimatedOpacity(
        opacity: _passcode.length == 4 ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          width: double.infinity,
          height: 40.h,
          child: ElevatedButton(
            onPressed: _passcode.length == 4
                ? () async {
              bool? correctPass = await confirmPasscode(_passcode);
              Navigator.pop(context, correctPass);
            }
                : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: colorScheme.primary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'CONFIRM',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> confirmPasscode(String passcode) async {
    final storage = FlutterSecureStorage();
    String? passCodeMapString = await storage.read(key: "passcodeMap");
    var passCodeMap = jsonDecode(passCodeMapString ?? "{}");
    String pass = passCodeMap["passcode"] ?? "";
    return (passcode == pass);
  }
}