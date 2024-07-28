


import 'package:flutter/cupertino.dart';

class SpacedContainer extends StatelessWidget {
 final  Widget child;
 final EdgeInsets padding;
 final EdgeInsets margin;
 final Color? containerColor;
 final  BorderRadius? borderRadius;

  const SpacedContainer({
   Key? key,
   required this.child,
    this.padding = const EdgeInsets.all(8.0),
    this.margin= const EdgeInsets.all(4.0),
   this.containerColor,
   this.borderRadius,
}): super(key:key);

@override
  Widget build(BuildContext context){
  return Container(
    padding: padding,
    margin: margin,
    decoration: BoxDecoration(
      color: containerColor,
      borderRadius: borderRadius
    ),
    child:  child,
  );
}
}