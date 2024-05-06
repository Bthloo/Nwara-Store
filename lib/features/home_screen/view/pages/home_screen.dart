import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nwara_store/core/general_components/color_helper.dart';
import 'package:nwara_store/features/home_screen/viewmodel/appbar_viewmodel/app_bar_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = "home-screen";

  @override
  Widget build(BuildContext context) {
    debugPrint("home rebuild");
    return BlocProvider(
      create: (context) => BottomAppBarCubit(),
      child: BlocBuilder< BottomAppBarCubit, BottomAppBarState>(
        builder: (context, state) {
          return Scaffold(
            bottomNavigationBar: NavigationBar(
              selectedIndex: BottomAppBarCubit.get(context).currentTapIndex,
              onDestinationSelected: (value) {
                BottomAppBarCubit.get(context).changeIndex(value);
              },
              backgroundColor: ColorHelper.mainColor,
              indicatorColor: ColorHelper.darkColor,

              destinations: const [
                NavigationDestination(
                  selectedIcon: Icon(Icons.receipt_long, color: ColorHelper.mainColor,),
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'الفواتير',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.warehouse, color: ColorHelper.mainColor,),
                  icon: Icon(Icons.warehouse_outlined),
                  label: 'المخزن',
                ),
                
              ],
            ),
            appBar: AppBar(
              // actions: [
              //   IconButton(
              //     onPressed: () {
              //       showDialog(
              //           context: context,
              //
              //           builder: (context) {
              //             return AlertDialog(
              //               title: Row(
              //                 children: [
              //                   Image.asset("assets/images/img.png",
              //                     height: 40,
              //                     width: 40,
              //                   ),
              //                   const SizedBox(width: 5,),
              //                   const Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       Text("Nwara Store"),
              //                       SizedBox(height: 5,),
              //                       Text("1.0.0",style: TextStyle(
              //                         fontSize: 12,
              //                         color: Colors.white
              //                       ),),
              //                     ],
              //                   ),
              //                 ],
              //               ),
              //               content: const Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   Text(
              //                       "© Bthloo"),
              //                   Text(
              //                       "جميع الحقوق محفوظه لدى"),
              //                 ],
              //               ),
              //               actions: [
              //                 TextButton(
              //                     onPressed: () {
              //                       Navigator.pop(context);
              //                     },
              //                     child: const Text("حسنا",style: TextStyle(
              //                       color: ColorHelper.mainColor
              //                     ),))
              //               ],
              //             );
              //           },);
              //     },
              //     icon: const Icon(Icons.info_outline),
              //   ),
              // ],
              title:  Hero(
                tag: "logo",
                child: Text("Nwara Store",style:  Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: ColorHelper.mainColor,
                    fontFamily: "Cairo"
                ),),
              )
            ),
            body: BottomAppBarCubit.get(context).tabs
            [BottomAppBarCubit.get(context).currentTapIndex],
          );
        },
      ),
    );
  }



}




// bottomNavigationBar: BottomAppBar(
//   color: ColorHelper.mainColor,
//   elevation: 0,
//   height: 68.h,
//   child:
//   BottomNavigationBar(
//     showUnselectedLabels: false,
//     unselectedItemColor: ColorHelper.darkColor,
//     selectedItemColor: Colors.white,
//     backgroundColor: Colors.transparent,
//
//     elevation: 0,
//     currentIndex: 0,
//     items: const [
//       BottomNavigationBarItem(
//           icon: Icon(Icons.home_filled),
//         label: "Home"
//       ),
//       BottomNavigationBarItem(
//           icon: Icon(Icons.add),
//           label: "Add"
//       ),
//
//     ],
//   ),
// ),
