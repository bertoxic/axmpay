import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dojah_kyc/flutter_dojah_kyc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VerificationScreen extends StatefulWidget {
  final Function(bool) onVerificationComplete;
  final UserServiceProvider usrprovider;

  const VerificationScreen({
    Key? key,
    required this.onVerificationComplete, required this.usrprovider
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // User information
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _gender = 'male';

  // ID verification
  String _selectedIdType = 'BVN';
  final TextEditingController _idNumberController = TextEditingController();

  bool _isVerificationInProgress = false;
  DojahKYC? _dojahKYC;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _verifyIdentity() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isVerificationInProgress = true;
      });

      // Depending on selected ID type, either populate BVN or NIN field
      String bvn = "";
      String nin = "";

      if (_selectedIdType == 'BVN') {
        bvn = _idNumberController.text;
      } else {
        nin = _idNumberController.text;
      }

      showWidgetID(
        context,
        false, // Initial verified state
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _dobController.text,
        _gender,
        bvn, // Pass BVN (empty if NIN was selected)
        nin, // Pass NIN (empty if BVN was selected)
        // Callback functions
        onSuccess: () {
          setState(() {
            _isVerificationInProgress = false;
          });

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Verification Successful'),
              content: const Text('Your identity has been successfully verified.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Notify parent widget that verification is complete
                    widget.onVerificationComplete(true);
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        },
        onError: (error) {
          setState(() {
            _isVerificationInProgress = false;
          });

          // Error is already being shown in a snackbar via the showWidgetID function
        },
        onClose: () {
          setState(() {
            _isVerificationInProgress = false;
          });
        },
      );
    }
  }

  String? validator(String? input) {
    if (input == null || input.isEmpty) {
      return "This field cannot be empty";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // User data fields to display in personal information section
    final userInfoFields = [
      {'label': 'First Name', 'value': widget.usrprovider.userdata?.firstname},
      {'label': 'Last Name', 'value': widget.usrprovider.userdata?.lastname},
      {'label': 'Email Address', 'value': widget.usrprovider.userdata?.email},
      {'label': 'Date of Birth', 'value': widget.usrprovider.userdata?.dob},
      {'label': 'Gender', 'value': widget.usrprovider.userdata?.gender},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isVerificationInProgress
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verifying your identity...', style: TextStyle(fontSize: 16)),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionCard(
                context,
                title: 'Personal Information',
                icon: Icons.person,
                child: Column(
                  children: [
                    // Dynamic generation of personal information fields
                    for (int i = 0; i < userInfoFields.length; i++)
                      _buildInfoRow(
                        context,
                        userInfoFields[i]['label']!,
                        userInfoFields[i]['value'] ?? 'Not provided',
                        showDivider: i < userInfoFields.length - 1,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ID Verification Section
              _buildSectionCard(
                context,
                title: 'ID Verification',
                icon: Icons.verified_user,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select ID Type'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // BVN Option
                        Expanded(
                          child: _buildIdTypeOption(
                            context,
                            type: 'BVN',
                            icon: Icons.credit_card,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // NIN Option
                        Expanded(
                          child: _buildIdTypeOption(
                            context,
                            type: 'NIN',
                            icon: Icons.perm_identity,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _idNumberController,
                      decoration: InputDecoration(
                        labelText: _selectedIdType == 'BVN' ? 'BVN Number' : 'NIN Number',
                        border: const OutlineInputBorder(),
                        hintText: _selectedIdType == 'BVN'
                            ? 'Enter your 11-digit BVN'
                            : 'Enter your 11-digit NIN',
                        prefixIcon: Icon(
                          _selectedIdType == 'BVN' ? Icons.credit_card : Icons.perm_identity,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty';
                        }
                        if (value.length != 11) {
                          return '${_selectedIdType} must be 11 digits';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return '${_selectedIdType} must contain only digits';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyIdentity,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    'Verify Identity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build section cards with consistent styling
  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent info rows
  Widget _buildInfoRow(BuildContext context, String label, String value, {bool showDivider = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        showDivider
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Colors.grey.shade300),
        )
            : const SizedBox(height: 12),
      ],
    );
  }

  // Helper method to build ID type selection options
  Widget _buildIdTypeOption(BuildContext context, {required String type, required IconData icon}) {
    final isSelected = _selectedIdType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIdType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showWidgetID(BuildContext context, bool verified, String firstName, String lastName, String email, String dateOfBirth, String gender, String nin, String bvn, {
    Function? onSuccess,
    Function(String)? onError,
    Function? onClose,
  }) {
    final metaData = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "dob": dateOfBirth,
      "gender": gender.toLowerCase(),
    };

    final govData = {
      "bvn": bvn,
      //"nin": "", // Keep empty for now
      "dl": "",
      "mobile": ""
    };

    final config = {
      'widget_id': dotenv.env['WIDGET_ID']
    };

    _dojahKYC = DojahKYC(
      appId: dotenv.env['APP_ID']!,
      publicKey: dotenv.env['PUBLIC_KEY']!,
      type: "custom",
      userData: metaData,
      govData: govData,
      config: config,
    );

    print(govData);
    print(config);
    print(metaData);

    _dojahKYC!.open(
        context,
        onSuccess: (result) {
          print(result);
          if (onSuccess != null) {
            onSuccess();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification successful!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onClose: (close) {
          print('Widget Closed');
          if (onClose != null) {
            onClose();
          }
        },
        onError: (error) {
          print(error);
          if (onError != null) {
            onError(error.toString());
          }
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
    );
  }
}

// Example usage in your app:
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Identity Verification',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: Scaffold(
//         body: VerificationScreen(
//           onVerificationComplete: (success) {
//             // Navigate to next screen when verification is complete
//             if (success) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const SuccessScreen(),
//                 ),
//               );
//             }
//           }, usrprovider: null,
//         ),
//       ),
//     );
//   }
// }

// Example success screen
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Complete'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 24),
            const Text(
              'Verification Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your identity has been successfully verified.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Continue to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}