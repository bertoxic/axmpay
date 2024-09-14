import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
   double? height=50.sp;
   final String path;
   double? width=50.sp;
   Color? color= Color(0xeb151c88);
   SvgIcon(this.path, {super.key,  this.height,  this.width, this.color,  });

  @override
  Widget build(BuildContext context) {
    return Container(

      height: height,
      width: width,
      child: SvgPicture.asset(path,fit:BoxFit.contain,color: color,// height: height, width: width,
      ),
    );
  }
}
