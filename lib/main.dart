import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nwara_store/core/general_components/theme_data.dart';
import 'package:nwara_store/core/models/item_from_hive_model.dart';
import 'package:nwara_store/core/models/item_model.dart';
import 'package:nwara_store/features/item_details_screen/view/pages/item_details_screen.dart';
import 'package:nwara_store/features/new_receipt_details/view/pages/new_receipt_details_screen.dart';
import 'package:nwara_store/features/splash_screen/View/Pages/splash_screen.dart';
import 'package:path_provider/path_provider.dart';

import 'core/models/receipt_model.dart';
import 'features/home_screen/view/pages/home_screen.dart';

Box? myBox;
Future<Box>openHiveBox(String boxName)async{
  if(!Hive.isBoxOpen(boxName)){
    Hive.init((await getApplicationDocumentsDirectory()).path);
  }
  return Hive.openBox(boxName);
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ItemModelAdapter());
  Hive.registerAdapter(ReceiptModelAdapter());
  Hive.registerAdapter(ItemFromHiveAdapter());
  await Hive.openBox<ItemModel>("items");
  await Hive.openBox<ReceiptModel>("receipts");
  await Hive.openBox<ItemFromHive>("itemFromHive");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      useInheritedMediaQuery: true,
      child: MaterialApp(
        title: 'Nwara Store',
        darkTheme: themeData(context),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        theme: themeData(context),
        initialRoute: SplashScreen.routeName,
        routes: {
          NewReceiptDetailsScreen.routeName : (_) =>  NewReceiptDetailsScreen(),
          SplashScreen.routeName : (_) => const SplashScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          ItemDetailsScreen.routeName : (_) => ItemDetailsScreen(),
        },
      ),
    );
  }
}