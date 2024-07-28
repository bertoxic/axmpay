import 'package:fintech_app/constants/app_colors.dart';
import 'package:fintech_app/main.dart';
import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/providers/Custom_Widget_State_Provider.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/services/auth_service.dart';
import 'package:fintech_app/ui/%20widgets/custom_buttons.dart';
import 'package:fintech_app/ui/%20widgets/custom_container.dart';
import 'package:fintech_app/ui/%20widgets/custom_dropdown.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/ui/%20widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

    class HomePage extends StatelessWidget {
      const HomePage({super.key});

      @override
      Widget build(BuildContext context) {
        String? selectedValue = "";
        UserServiceProvider userProvider= UserServiceProvider();
        return Container(
            //color: Colors.green,
            child: Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: colorScheme.background,
              child: FutureBuilder<UserData?>(
                future: userProvider.getUserDetails(),
                builder: (BuildContext context, AsyncSnapshot<UserData?> snapshot) {
                if(snapshot.connectionState ==ConnectionState.waiting){

                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }else if (snapshot.hasData && snapshot.data != null) {
                  UserData userData = snapshot.data!;
                  return Column(

                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        margin: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: colorScheme.onBackground),
                        child: Column(
                          children: [
                            SpacedContainer(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20.sp,
                                          backgroundColor: Colors.grey,
                                          child: Text("${userData.username}"),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.w, vertical: 0),
                                          child:  Text("${userData.firstname} ${userData.lastname}"),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.help,
                                          color: colorScheme.primary,
                                        ),
                                        Icon(
                                          Icons.notification_important,
                                          color: colorScheme.onSurface,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SpacedContainer(
                                child: Container(
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    width: double.maxFinite,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.w),
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: <Color>[
                                            colorScheme.primary,
                                            Color(0xB20CAB18),
                                            // Color(0xB643C036),
                                            Color(0xFF5EE862),
                                          ]),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(12.w),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppText.caption(
                                                "Available Balance",
                                                color: colorScheme.onPrimary,
                                              ),
                                              AppText.caption(" Transaction details",
                                                  color: colorScheme.onPrimary),
                                            ],
                                          ),
                                        ),
                                        Center(
                                            child: AppText.title(
                                              "\$ ${userData.availableBalance}",
                                              color: colorScheme.onPrimary,
                                            )),
                                      ],
                                    )))
                          ],
                        ),
                      ),
                      Container(
                        height: 120,
                        padding: EdgeInsets.all(2.w),
                        margin: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white.withOpacity(0.9),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                                  child: AppText.body("Services"),
                                )),
                            SizedBox(
                              height: 8.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildColumn(Icons.message, "pay bill"),
                                  _buildColumn(Icons.food_bank_outlined, "recharge"),
                                  _buildColumn(Icons.widgets, "buy ticket"),
                                  _buildColumn(Icons.face, "transfer"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2.w),
                        margin: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                                  child: AppText.body("Mobile Top up "),
                                )),
                            SizedBox(
                              height: 20.h,
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 12, left: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                        color: Colors.green.shade400,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8))),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: AppText.caption("Ng +234"),
                                    ),
                                  ),
                                  SizedBox(
                                      width: 260.w,
                                      height: 40.w,
                                      child: CustomTextField(
                                        fieldName: "phone",
                                        // textStyle: TextStyle(height: 20),
                                        decoration: InputDecoration(
                                            fillColor: Colors.grey.shade50,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(8),
                                                  bottomRight: Radius.circular(8)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(8),
                                                  bottomRight: Radius.circular(8)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            )),
                                      ))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CustomDropdown<String>(
                                items: const ['Account 1', 'Account 2', 'Account 3'],
                                initialValue: "Account 1",
                                onChanged: (newValue) => print("$newValue"),
                                itemBuilder: (item) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(item),
                                ),
                                selectedItemBuilder: (item) => Text(item),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CustomDropdown<String>(
                                items: const ['airtime', 'data ', 'recharge'],
                                initialValue: "data",
                                onChanged: (newValue) => print("object"),
                                itemBuilder: (item) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(item),
                                ),
                                selectedItemBuilder: (item) => Text(item),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomButton(
                                height: 40.h,
                                text: "Top up",
                                width: double.maxFinite,
                                onPressed: () => _showBottomSheet(context),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                } else{
                  return  Text(snapshot.data?.fullName??" no data");
                }
      },
              ),
        ),
      ),
    ));
  }
}

Widget _buildColumn(IconData icon, String text) {
  return Card(
    elevation: 0.8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.all(4.0).copyWith(left: 8, right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.green.shade400,
          ),
          SizedBox(height: 4.h), // Add some space between icon and text
          AppText.caption(
            text,
          ),
        ],
      ),
    ),
  );
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.1,
      maxChildSize: 0.65,
      expand: false,
      builder: (_, controller) => BottomSheetContent(controller: controller),
    ),
  );
}

class BottomSheetContent extends StatelessWidget {
  final ScrollController controller;

  const BottomSheetContent({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      children: [
        SizedBox(height: 10.h),
        Center(
          child: Container(
            width: 40.h,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SpacedContainer(
            margin: EdgeInsets.all(12.sp),
            child: Column(
              children: [
                Center(
                  child: AppText.headline("800"),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Account number",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body("700 9890 8977"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Recipient's Name",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body("Barry felix king"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Amount",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body(" 700 "),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffdeffe6),
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.w),
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.wallet_sharp,
                        color: Colors.green.shade700,
                      ),
                      //  SizedBox(width: 30.w,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.caption("Account to be Debited"),
                          AppText.caption("Azuma nioman"),
                        ],
                      ),
                      // SizedBox(width: 30.w,),
                      Row(
                        children: [
                          AppText.caption(
                            "Top up ",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 12,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                const CustomButton(
                  text: "SEND",
                  size: ButtonSize.large,
                  width: double.maxFinite,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
