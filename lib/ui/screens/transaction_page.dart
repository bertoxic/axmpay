import 'dart:math';

import 'package:fintech_app/constants/app_colors.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/%20widgets/custom_buttons.dart';
import 'package:fintech_app/ui/%20widgets/custom_container.dart';
import 'package:fintech_app/ui/%20widgets/custom_pop_up.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/ui/%20widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';

class TransferScreen extends StatefulWidget {
   TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}
class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Bank> filter_search = [];
  List<Bank> total_items = [];
  @override
  void initState() {
    super.initState();
    Provider.of<UserServiceProvider>(context, listen: false).getBankNames();
      _controller.addListener(_filterItems);
    filter_search = total_items;
  }
  void dispose() {
    _controller.removeListener(_filterItems);
    _controller.dispose();
    super.dispose();
  }
  void _filterItems() {
    final query = _controller.value.text.toLowerCase();
    setState(() {
      filter_search = total_items.where((item) {
       // String? bankname = item.bankName?.toLowerCase();
        print("$query");
        return item.bankName!.toLowerCase()!.contains(query);
      }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    final userp = Provider.of<UserServiceProvider>(context);
    total_items = userp.bankListResponse?.bankList ?? [];
  return  Scaffold(
      appBar: AppBar(),
      body: SpacedContainer(
        containerColor: Colors.grey.shade200,
        margin: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: 12.0.sp),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.sp),
                            child:  CircleAvatar(radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(Icons.person),
                            )),
    Consumer<UserServiceProvider>(
    builder: (context, userServiceProvider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.caption("${userp.userdata?.fullName}"),
          AppText.body("${userServiceProvider.userdata?.availableBalance}")
        ],
      ); //xxxxxxxxxx
    })
                      ],
                    ),
                  ),

                  SpacedContainer(
                    height: 100.h,
                      containerColor: Colors.red.shade200,
                      borderRadius: BorderRadius.circular(8),
                      padding: EdgeInsets.all(8.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          children: [
                            AppText.subtitle("Select Bank"),
                          ],),
    GestureDetector(
      onTap: (){

           ScrollablePopup.show(context: context,
               isDismissible: true,
               child:  StatefulBuilder(
    builder: (BuildContext context, StateSetter setState)
           {
             return SizedBox(
               width: 340.h,
               height: 800.h,
               child: Consumer<UserServiceProvider>(
                 builder: (context, userServiceProvider, child) {
                   return Column(
                     children: [
                       SizedBox(
                           height: 36.h,
                           width: 240.w,
                           child: CustomTextField(
                             controller: _controller,
                             onChanged: (value) {
                               setState(() {
                                 _filterItems();
                               });
                             },
                             fieldName: "fieldName", hintText: "search bank",
                           )),
                       SizedBox(
                         width: 340.h,
                         height: 720.h,
                         child: ListView.builder(
                           itemCount: filter_search.length,
                           itemBuilder: (BuildContext context, int index) {
                             final item = filter_search[index];
                             Color itemColor = getRandomColor();
                             return ListTile(onTap: () {
                               print("${item?.bankName}");
                               Navigator.pop(context);
                             },
                               leading: Container(
                                   padding: EdgeInsets.all(4),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(100),
                                       color: itemColor.withOpacity(0.2),
                                   ),
                                   child: Icon(Icons.home_work_outlined,)),
                               iconColor: itemColor,
                               title: AppText.caption(item?.bankName ?? ""),
                               // Add more widgets (e.g., subtitle, trailing icon) as needed
                             );
                           },
                         ),
                       ),
                     ],
                   );
                 }, //////////////////////////////////////
               ),
             );
           },)
    );
      },
      child: Consumer<UserServiceProvider>(
      builder: (context, userServiceProvider, child) {
        return AppText.caption(
            userServiceProvider.bankListResponse?.bankList[3].bankName ?? "loading ...");
      }),
    ),
                        ],)),
                  SizedBox(
                    height: 20.h,
                  ),
                  Container(
                    height: 100.sp,
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8)
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppText.body("Amount"),
                            SizedBox(
                              width: 20.sp,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.green.shade200,
                                  borderRadius: BorderRadius.circular(16)
                              ),
                              child: SpacedContainer(
                                padding: EdgeInsets.all(2.sp),
                                child: AppText.caption(
                                  "transaction amount",
                                  style: TextStyle(fontSize: 8.sp),
                                  color: Colors.green.shade800,
                                ),
                              ),

                            )
                          ],
                        ),
                        SizedBox(height: 8.sp,),
                        SizedBox( height: 40.h,
                          child: CustomTextField(
                            hintText: "  100 - 50 000 000",
                              prefix: AppText.body("\$"),

                              fieldName: "transaction_amount"),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Container(
                    height: 100.h,
                    width: double.maxFinite,
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.body("Remark"),
                        SizedBox(height: 8.sp,),
                        SizedBox(
                          height: 40.h,
                          child: CustomTextField(
                            hintText: "write anything here",
                              fieldName: "remark"),
                        )
                      ],
                    ),),
  SizedBox(height: 20.h,),
                CustomButton(
                    text: "Confirm",
                  type: ButtonType.elevated,
                   size: ButtonSize.large,
                  width: 220.w,
                  onPressed: ()=> _showBottomSheet(context),
                )



                ],
          ),
        ),
      ),
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
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

  const BottomSheetContent({Key? key, required this.controller}) : super(key: key);

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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child:SpacedContainer(
            margin: EdgeInsets.all(12.sp),
            child: Column(
              children: [
                Center(
                  child: AppText.headline("800"),
                ),
                SizedBox(height: 16.h,),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body("Account number",color: Colors.grey.shade500,),
                      AppText.body("700 9890 8977"),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 4.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body("Recipient's Name",color: Colors.grey.shade500,),
                      AppText.body("Barry felix king"),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body("Amount",color: Colors.grey.shade500,),
                      AppText.body(" 700 "),
                    ],
                  ),
                ),
                SizedBox(height: 20.h,),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffdeffe6),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 16.w),
                  width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.wallet_sharp,color: Colors.green.shade700,),
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
                            AppText.caption("Top up ", style: const TextStyle(fontSize: 12), ),
                            const Icon(Icons.arrow_forward_ios_outlined,size: 12,)
                          ],
                        ),
                        
                      ],
                    ),
                ),
                SizedBox(height: 40.h,),
                const CustomButton(text: "SEND", size: ButtonSize.large,width: double.maxFinite,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Color getRandomColor() {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.teal,
    Colors.indigo,
    Colors.lime,
  ];
  final randomIndex = Random().nextInt(_colors.length);
  return _colors[randomIndex];
}