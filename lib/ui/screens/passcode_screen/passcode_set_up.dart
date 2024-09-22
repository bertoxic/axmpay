import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/screens/passcode_screen/passcode_provider.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasscodeSetupScreen extends StatelessWidget {
  final String email;
  const PasscodeSetupScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return  _PasscodeSetupScreenContent( email);
  }
}

class _PasscodeSetupScreenContent extends StatelessWidget {
  final String email;
   _PasscodeSetupScreenContent( this.email);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<PasscodeSetupModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, overscroll: false),
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.h).copyWith(top: 8.h),
            child: Column (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Setting up', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                 SizedBox(height: 8.h),
                 Text('Your PIN code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                Text(
                  'To set up your PIN create 4 digit code\nthen confirm it below',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                 SizedBox(height: 8.h),
                Text(
                  'PIN CODE',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                 SizedBox(height: 12.h),
                _buildPinCodeRow(model, isConfirmation: false),
                 SizedBox(height: 24.h),
                if (model.isConfirming) ...[
                  Text(
                    'CONFIRM YOUR PIN CODE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                   SizedBox(height: 8.h),
                  _buildPinCodeRow(model, isConfirmation: true),
                ],
                if (model.passcode.length == 4 && model.confirmedPasscode.length == 4)
                  _buildValidationMessage(model),
                SizedBox(height: 24.h),
                _buildNumberPad(model),
                 SizedBox(height: 16.h),
                _buildContinueButton(model, context, email),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(PasscodeSetupModel model) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            color: index < (model.isConfirming ? 3 : 2) ? Colors.red : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildPinCodeRow(PasscodeSetupModel model, {required bool isConfirmation}) {
    String currentPasscode = isConfirmation ? model.confirmedPasscode : model.passcode;
    bool isVisible = isConfirmation ? model.isConfirmedPasscodeVisible : model.isPasscodeVisible;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            border: Border.all(color: model.isConfirming? colorScheme.primary:Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: index < 4
                ? isVisible
                ? Text(
              index < currentPasscode.length ? currentPasscode[index] : '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
                : Icon(
              Icons.circle,
              size: 8.sp,
              color: index < currentPasscode.length ? Colors.black : Colors.grey[300],
            )
                : IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                if (isConfirmation) {
                  model.toggleConfirmedPasscodeVisibility();
                } else {
                  model.togglePasscodeVisibility();
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildValidationMessage(PasscodeSetupModel model) {
    bool isValid = model.passcode == model.confirmedPasscode;
    return AnimatedOpacity(
      opacity: model.passcode.length == 4 && model.confirmedPasscode.length == 4 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding:  EdgeInsets.only(top: 16.h),
        child: Row(
          children: [
            Icon(
              isValid ? Icons.check : Icons.close,
              color: isValid ? Colors.green : Colors.red,
            ),
             SizedBox(width: 8.w),
            Text(
              isValid ? 'Your PIN codes are the same' : 'Your PIN codes do not match',
              style: TextStyle(
                color: isValid ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(PasscodeSetupModel model) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: List.generate(12, (index) {
        if (index == 9) {
          return const SizedBox.shrink();
        } else if (index == 10) {
          return _buildNumberButton('0', model);
        } else if (index == 11) {
          return _buildBackspaceButton(model);
        } else {
          return _buildNumberButton('${index + 1}', model);
        }
      }),
    );
  }

  Widget _buildNumberButton(String number, PasscodeSetupModel model) {
    return InkWell(
      onTap: () {
        model.addDigit(number);
        if (model.passcode.length == 4 && !model.isConfirming) {
          model.switchToConfirmation();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:  colorScheme.primary.withOpacity(0.15),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(PasscodeSetupModel model) {
    return InkWell(
      onTap: model.removeDigit,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withOpacity(0.15),
        ),
        child: const Center(
          child: Icon(Icons.backspace, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildContinueButton(PasscodeSetupModel model, BuildContext context, String email) {
    return AnimatedOpacity(
      opacity: model.passcode.length == 4 && model.confirmedPasscode.length == 4 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: model.passcode.length == 4 && model.confirmedPasscode.length == 4 && model.passcode == model.confirmedPasscode
            ? () async {
          await model.savePasscode(email);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN set successfully!')),
          );
          model.resetAndClearPassCodeField();
          Navigator.of(context).pop();
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
        child: const Text('CONTINUE'),
      ),
    );
  }
}