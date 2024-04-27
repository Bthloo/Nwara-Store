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
              title: const Text("Nwara Store"),
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
