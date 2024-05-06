import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nwara_store/core/general_components/color_helper.dart';
import 'package:nwara_store/features/home_screen/view/pages/home_screen.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const String routeName = 'splash';
  @override
  Widget build(BuildContext context) {

    Future.delayed(const Duration(seconds: 3), () {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Lottie.asset("assets/json_lottie/mSPxqTWZnc.json",
                    width: 250,
                    height: 250,
                   // fit: BoxFit.fill,
                  )
                      ),
               Hero(
                tag: "logo",
                child: Text("Nwara Store",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: ColorHelper.mainColor,
                    fontFamily: "Cairo"
                ),),
              )
            ],
          ),
      ),
    ));
  }

}
