import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class SearchBarPage extends StatefulWidget {
  const SearchBarPage({super.key});

  @override
  State<SearchBarPage> createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
    List filteredList =[] ;
    List entireList =[] ;
    bool _loading= false;
   late UserServiceProvider  _userServiceProvider;
  @override
  void initState() {
    super.initState();
    _userServiceProvider = UserServiceProvider();
  }

  List getTotalList(){
    return [];
  }
  @override
  Widget build(BuildContext context) {
    return !_loading?CircularProgressIndicator(): Container(
      padding: EdgeInsets.all(8.sp),
      child: CustomTextField(
         fieldName: "search",
        onChanged: (value){},
      ),
    );
  }
}
