import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:nwara_store/core/general_components/build_show_toast.dart';
import 'package:nwara_store/core/general_components/custom_form_field.dart';
import 'package:nwara_store/core/models/item_model.dart';

import '../../../../core/general_components/dialog.dart';
import '../../../home_screen/view/pages/items_tab.dart';

class ItemDetailsScreen extends StatelessWidget {
   ItemDetailsScreen({super.key});
   static const String routeName = "details-screen";
   final itemBox = Hive.box<ItemModel>("items");
   final _formKey = GlobalKey<FormState>();

   final TextEditingController nameController = TextEditingController();
   final TextEditingController originalPriceController = TextEditingController();
   final TextEditingController sellPriceController = TextEditingController();
   final TextEditingController quantityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Argument argument = ModalRoute.of(context)!.settings.arguments as Argument;
    nameController.text = argument.itemFromHive.itemModel.name;
    quantityController.text = argument.itemFromHive.itemModel.quantity.toString();
    originalPriceController.text = argument.itemFromHive.itemModel.originalPrice.toString();
    sellPriceController.text = argument.itemFromHive.itemModel.sellPrice.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل العنصر",style: TextStyle(
          fontFamily: "Cairo"
        ),),
        actions: [
          TextButton.icon(
              onPressed: (){
                DialogUtilities.showMessage(
                    context, "هل انت متاكد من مسح هذا العنصر؟",
                    nigaiveAction: ()async{
                      await itemBox.delete(argument.itemFromHive.key);
                      if(context.mounted){Navigator.pop(context);}
                    },
                    nigaiveActionName: "نعم",
                    posstiveActionName: "الغاء"
                );
              },
              icon: const Icon(Icons.delete,color: Colors.red,),
            label: const Text("مسح",style: TextStyle(
              color: Colors.red
            ),),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomFormField(
                  hintText: "الاسم",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "قم باضافه اسم العنصر";
                    } else {
                      return null;
                    }
                  },
                  controller: nameController,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomFormField(
                  keyboardType: TextInputType.number,
                  hintText: "الكميه",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "قم باضافه الكميه للعنصر";
                    }else if(value.contains("-")){
                      return "مسموح بادخال ارقام موجبه فقط";
                    } else if(value.contains(",")){
                      return "غير مسموح بادخال الفاصله";
                    }else {
                      return null;
                    }
                  },
                  controller: quantityController,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomFormField(
                  keyboardType: TextInputType.number,
                  hintText: "السعر الاساسي",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "قم باضافه السعر الاساسي للعنصر";
                    }else if(value.contains("-")){
                      return "مسموح بادخال ارقام موجبه فقط";
                    } else if(value.contains(",")){
                      return "غير مسموح بادخال الفاصله";
                    }else {
                      return null;
                    }
                  },
                  controller:
                  originalPriceController,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomFormField(
                  keyboardType: TextInputType.number,
                  hintText: "سعر البيع",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "قم باضافه سعر البيع للعنصر";
                    }else if(value.contains("-")){
                      return "مسموح بادخال ارقام موجبه فقط";
                    } else if(value.contains(",")){
                      return "غير مسموح بادخال الفاصله";
                    }else {
                      return null;
                    }
                  },
                  controller:
                  sellPriceController,
                ),
                SizedBox(height: 40.h,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        if(_formKey.currentState!.validate()== false) {
                          return;
                        }else{
                          try{
                            itemBox.put(argument.itemFromHive.key,  ItemModel(
                                name: nameController.text,
                                originalPrice: num.parse(originalPriceController.text),
                                sellPrice: num.parse(sellPriceController.text),
                                quantity: int.parse(quantityController.text)
                            ));
                            // itemBox.putAt(argument.index,
                            //     ItemModel(
                            //     name: nameController.text,
                            //     originalPrice: num.parse(originalPriceController.text),
                            //     sellPrice: num.parse(sellPriceController.text)
                            // )
                            // );
                            buildShowToast("تم حفظ التغييرات بنجاح");
                            Navigator.pop(context);
                          }catch(e){
                            buildShowToast(e.toString());
                          }
                        }


                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "حفظ التغييرات",
                          style: TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
