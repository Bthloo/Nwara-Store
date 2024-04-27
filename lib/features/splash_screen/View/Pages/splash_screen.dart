import 'package:flutter/material.dart';
import 'package:nwara_store/core/general_components/color_helper.dart';
import 'package:nwara_store/features/home_screen/view/pages/home_screen.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const String routeName = 'splash';
  @override
  Widget build(BuildContext context) {

    Future.delayed(const Duration(seconds: 2), () {
      if(context.mounted){
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    });


    return  Scaffold(
      //backgroundColor: Color(0xff171717),
      body: Center(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              const Spacer(),
             Center(
                 child: Image.asset("assets/images/img.png",width: 150,height: 150,)),
              const Spacer(),
              const Text(
                '0.2.0 ( Beta )',
                style: TextStyle(
                    color: ColorHelper.mainColor, fontSize: 15),
              ),

            ],
          ),
        ),
      ),
    );
  }

}
