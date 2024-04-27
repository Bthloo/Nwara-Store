import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:nwara_store/features/new_receipt_details/get_receipt_details_cubit.dart';
import '../../../../core/general_components/build_show_toast.dart';
import '../../../../core/general_components/color_helper.dart';
import '../../../../core/general_components/custom_form_field.dart';
import '../../../../core/general_components/dialog.dart';
import '../../../../core/models/item_from_hive_model.dart';
import '../../../../core/models/item_model.dart';
import '../../../../core/models/receipt_model.dart';

//ignore: must_be_immutable
class NewReceiptDetailsScreen extends StatelessWidget {
   NewReceiptDetailsScreen({super.key});

  static const routeName = 'NewReceiptDetailsScreen';
  final receiptsBox = Hive.box<ReceiptModel>("receipts");
   final itemBox = Hive.box<ItemModel>("items");

   final TextEditingController quantityController = TextEditingController();
   final TextEditingController externalNameItemController = TextEditingController();
   final TextEditingController externalPriceItemController = TextEditingController();

   final _nameFormKey = GlobalKey<FormState>();
   final _addItemFormKey = GlobalKey<FormState>();
   final _addExternalItemFormKey = GlobalKey<FormState>();

   BuildContext? getReceiptsContext;
   //final AddItemToReceiptCubit addItemToReceiptCubit = AddItemToReceiptCubit();

   ItemFromHive? itemFromHive ;
   int itemQuantity = 0;
   num newOriginalPrice = 0;
   num newSellPrice = 0;
   num newNetIncome = 0;



   @override
  Widget build(BuildContext context) {
     int argument = ModalRoute.of(context)!.settings.arguments as int;
    return BlocProvider(
      create: (context) => GetReceiptDetailsCubit()
        ..getReceiptDetails(receiptIndex: argument),
      child: BlocBuilder<GetReceiptDetailsCubit, GetReceiptDetailsState>(
  builder: (context, state) {
    getReceiptsContext =context;
    if(state is GetReceiptDetailsLoading){
      return const Center(child: CircularProgressIndicator(),);
    }else if(state is GetReceiptDetailsSuccess){
      //nameController.text = state.receiptModel.name;
      return Scaffold(
        appBar: AppBar(
          title: const Text("تفاصيل الفاتورة"),
          actions: [
            TextButton.icon(
              onPressed: (){
                DialogUtilities.showMessage(
                    context, "هل انت متاكد من مسح هذه الفاتورة؟",
                    nigaiveAction: ()async{
                      await receiptsBox.deleteAt(argument);
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
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Form(
                key: _nameFormKey,
                child: CustomFormField(
                  suffix: IconButton(
                    onPressed: () {
                      if(_nameFormKey.currentState!.validate() == false){
                        return;
                      }else{
                        try{
                          receiptsBox.putAt(
                              argument,
                              ReceiptModel(
                                  name: GetReceiptDetailsCubit.get(context).nameController.text,
                                  sellPrice: state.receiptModel.sellPrice,
                                  originalPrice: state.receiptModel.originalPrice,
                                  netIncome: state.receiptModel.netIncome,
                                  itemModel: state.receiptModel.itemModel
                              ));
                          GetReceiptDetailsCubit.get(context).getReceiptDetails(receiptIndex: argument);
                          buildShowToast("تم حفظ التغييرات بنجاح");
                          //Navigator.pop(context);
                        }catch(e){
                          buildShowToast(e.toString());
                        }
                      }


                    },
                    icon: const Icon(Icons.check,color: ColorHelper.mainColor,),
                  ),
                  hintText: 'اسم الفاتورة',
                  validator: (value){
                    if(value!.trim().isEmpty){
                      return "قم باخال اسم الفاتورة";
                    }else{
                      return null;
                    }
                  },
                  controller: GetReceiptDetailsCubit.get(getReceiptsContext).nameController,

                ),
              ),
              SizedBox(height: 25.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: (){
                        _showAddItem(
                          index: argument,
                          context: context,
                          state: state
                        );
                        // _showAddItem(
                        //     index: argument!.index,
                        //     context: context,
                        //     key: argument!.receiptModel.key
                        // );
                      },
                      icon: const Icon(Icons.add_circle_sharp,color: ColorHelper.mainColor,size: 30,)
                  ),
                  IconButton(
                      onPressed: (){
                        _showAddExternalItem(
                            index: argument,
                            context: context,
                            state: state
                        );
                      },
                      icon: const Icon(Icons.mode_edit_sharp,color: ColorHelper.mainColor,size: 30,)
                  ),
                  const Spacer(),
                  Container(
                    height: 3.h,
                    width: MediaQuery.of(context).size.width*.1,
                    decoration: const BoxDecoration(
                        color: ColorHelper.mainColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            topLeft: Radius.circular(25)

                        )

                    ),
                  ),
                  SizedBox(width: 5.w,),
                  Text("البضاعه المباعه",style: TextStyle(
                      color: ColorHelper.mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp
                  ),textDirection: TextDirection.rtl),


                ],
              ),
              SizedBox(height: 10.h,),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border.all(color: ColorHelper.mainColor,width: 2)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Container(
                      width: MediaQuery.sizeOf(context).width*.3,
                      decoration: const BoxDecoration(
                          color: ColorHelper.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text("العدد",style: TextStyle(
                              color: ColorHelper.darkColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp
                          ),textAlign: TextAlign.center,),
                        ),
                      ),
                    ),
                    Container(
                      height: 20.h,
                      width: 3.w,
                      color: ColorHelper.mainColor,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width*.3,
                      decoration: const BoxDecoration(
                          color: ColorHelper.mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text("اسم الصنف",style: TextStyle(
                              color: ColorHelper.darkColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp
                          ),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(20),
                    //   bottomRight: Radius.circular(20)
                    // ),
                      border: BorderDirectional(
                          start: BorderSide(width: 2,color: ColorHelper.mainColor),
                          end: BorderSide(width: 2,color: ColorHelper.mainColor)
                      )
                  ),
                  // height: 100.h,
                  // width: double.infinity,
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width*.3,
                          color: ColorHelper.mainColor,),
                    itemCount: state.receiptModel.itemModel.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:  Slidable(
                      endActionPane: ActionPane(
                            extentRatio: .25,
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed:(buildContext){
                                  DialogUtilities.showMessage(
                                    context, "هل انت متاكد من مسح هذا العنصر؟",
                                    nigaiveActionName: "مسح",
                                    nigaiveAction: () async{
                                       try{
                                        num afterDeleteOriginalPrice = (state.receiptModel.originalPrice) -
                                             (state.receiptModel.itemModel[index].itemModel.originalPrice*
                                                 state.receiptModel.itemModel[index].itemModel.quantity);
                                         num afterDeleteSellPrice = (state.receiptModel.sellPrice) -
                                             (state.receiptModel.itemModel[index].itemModel.sellPrice*
                                                 state.receiptModel.itemModel[index].itemModel.quantity
                                             );

                                         num afterDeleteNetIncome = afterDeleteSellPrice - afterDeleteOriginalPrice;

                                        receiptsBox.putAt(argument,
                                            ReceiptModel(
                                                name: state.receiptModel.name,
                                                itemModel: state.receiptModel.itemModel,
                                                originalPrice: afterDeleteOriginalPrice,
                                                sellPrice: afterDeleteSellPrice,
                                                netIncome: afterDeleteNetIncome
                                            ));
                                        state.receiptModel.itemModel.removeAt(index);

                                       //await itemBox.deleteAt(index);

                                          GetReceiptDetailsCubit.get(context).getReceiptDetails(receiptIndex: argument);

                                        buildShowToast("تم المسح بنجاح");
                                       }catch(e){
                                         buildShowToast(e.toString());
                                          debugPrint(e.toString());
                                       }

                                    },
                                    posstiveActionName: "الغاء",
                                  );
                                },
                                //icon: Icons.delete,
                                backgroundColor: const Color(0xffDA0037),
                                label: 'مسح',
                                borderRadius: const BorderRadius.all(Radius.circular(5)),

                              )
                            ],
                          ),
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                 shape: MaterialStatePropertyAll(
                                   RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))
                                 )
                              ),
                              onPressed: (){
                                DialogUtilities.showMessage(
                                    context,
                                    "${state.receiptModel.itemModel[index].itemModel.name}\n"
                                    "السعر الاصلي :  ${state.receiptModel.itemModel[index].itemModel.originalPrice }\n "
                                    "سعر البيع : ${state.receiptModel.itemModel[index].itemModel.sellPrice }\n صافي الربح: ${(state.receiptModel.itemModel[index].itemModel.sellPrice)-(state.receiptModel.itemModel[index].itemModel.originalPrice) }"
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*.2,
                                    child: Center(
                                      child: Text(
                                        state.receiptModel.itemModel[index].itemModel.quantity.toString(),
                                        style:  TextStyle(
                                            color: ColorHelper.darkColor,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*.2,

                                    child: Center(
                                      child: Text(
                                        state.receiptModel.itemModel[index].itemModel.name,
                                        style:  TextStyle(
                                            color: ColorHelper.darkColor,
                                            fontSize: 20.sp,
                                          fontWeight: FontWeight.bold
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      );
                    },
                  ),
                ),
              ),
              Column(
                children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorHelper.mainColor,width: 2)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text("${state.receiptModel.originalPrice}",style: TextStyle(
                                color: ColorHelper.mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp
                            ),textAlign: TextAlign.center,),
                          ),
                        ),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text("السعر الاصلي",style: TextStyle(
                                color: ColorHelper.mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp
                            ),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(

                  decoration: const BoxDecoration(

                      border: Border.symmetric(vertical : BorderSide(color: ColorHelper.mainColor,width: 2))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text("${state.receiptModel.sellPrice}",style: TextStyle(
                                color: ColorHelper.mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp
                            ),textAlign: TextAlign.center,),
                          ),
                        ),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text("سعر البيع",style: TextStyle(
                                color: ColorHelper.mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp
                            ),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: ColorHelper.mainColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),

                      ),
                      border: Border.all(color: ColorHelper.mainColor,width: 2)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          //width: MediaQuery.sizeOf(context).width*.3,
                          decoration: const BoxDecoration(
                              color: ColorHelper.mainColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12)
                              )
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text("${state.receiptModel.netIncome}",style: TextStyle(
                                  color: ColorHelper.darkColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp
                              ),textAlign: TextAlign.center,),
                            ),
                          ),
                        ),

                        Container(
                          // width: MediaQuery.sizeOf(context).width*.3,
                          decoration: const BoxDecoration(
                              color: ColorHelper.mainColor,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(12)
                              )
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text("صافي الربح",style: TextStyle(
                                  color: ColorHelper.darkColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp
                              ),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],),

              // const Spacer(),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //       onPressed: () {
              //         if(_nameFormKey.currentState!.validate() == false){
              //           return;
              //         }else{
              //           try{
              //             receiptsBox.putAt(
              //                 argument,
              //                 ReceiptModel(
              //                     name: nameController.text,
              //                     sellPrice: 5.5,
              //                     originalPrice: 5.5,
              //                     netIncome: 5,
              //                     itemModel: state.receiptModel.itemModel
              //                 ));
              //             GetReceiptDetailsCubit.get(context).getReceiptDetails(receiptIndex: argument);
              //             buildShowToast("تم حفظ التغييرات بنجاح");
              //             //Navigator.pop(context);
              //           }catch(e){
              //             buildShowToast(e.toString());
              //           }
              //         }
              //
              //
              //       },
              //       child: const Padding(
              //         padding: EdgeInsets.all(8.0),
              //         child: Text(
              //           "حفظ التغييرات",
              //           style: TextStyle(
              //               color: Colors.white, fontSize: 20),
              //         ),
              //       )),
              // ),
               SizedBox(height: 10.h,),
            ],
          ),
        ),
      );
    }else if(state is GetReceiptDetailsError){
      return Center(child: Text(state.message,style: const TextStyle(
        color: Colors.white,
        fontSize: 25
      ),),);
    }else{
      return const Center(child: Text("Error : No State Found",style: TextStyle(color: Colors.white,fontSize: 25
      )));
    }

  },
),
    );

  }

   void _showAddItem({
     required BuildContext context,
     required int index,
     required GetReceiptDetailsSuccess state
     //required dynamic key
   }) {
     showModalBottomSheet(
         useSafeArea: true,
         isScrollControlled: true,
         context: context,
         shape: const RoundedRectangleBorder(
           borderRadius: BorderRadius.vertical(
             top: Radius.circular(25.0),
           ),
         ),
         builder: (context) => Padding(
           padding: EdgeInsets.only(
               bottom: MediaQuery.of(context).viewInsets.bottom,
               left: 10,
               right: 10),
           child: SingleChildScrollView(
             child: Form(
               key: _addItemFormKey,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     "اضافه عنصر جديد",
                     style: TextStyle(fontSize: 25.sp, color: Colors.white),
                   ),
                   SizedBox(
                     height: 20.h,
                   ),

                   DropdownSearch(
                     onChanged: (value) {
                       itemFromHive = value;


                     },
                     dropdownButtonProps: const DropdownButtonProps(
                         color: Colors.white
                     ),
                     dropdownDecoratorProps: const DropDownDecoratorProps(
                         textAlign: TextAlign.center,
                         baseStyle: TextStyle(
                             color: Colors.white
                         )
                     ),
                     popupProps:   const PopupProps.menu(
                         searchFieldProps: TextFieldProps(
                             style: TextStyle(
                                 color: Colors.black
                             )
                         ),
                         showSearchBox: true,
                         menuProps: MenuProps(
                           backgroundColor: Colors.white,
                         ),
                         fit: FlexFit.loose
                     ),
                     items: getNonEmptyItems(),
                     itemAsString: (item) {
                       return " الاسم: ${item.itemModel.name} ------ الكميه : ${item.itemModel.quantity}";
                     },
                     validator: (value) {
                       if(value == null){
                         return "قم باختيار الصنف";
                       }else{
                         return null;
                       }
                     },
                   ),
                   SizedBox(
                     height: 10.h,
                   ),
                   CustomFormField(
                     keyboardType: TextInputType.number,
                     hintText: "الكميه",
                     validator: (value) {
                       if (value!.trim().isEmpty) {
                         return "قم باضافه الكميه للعنصر";
                       }else if(value.contains("-")){
                         return "مسموح بادخال ارقام موجبه فقط";
                       } else {
                         return null;
                       }
                     },
                     controller: quantityController,
                   ),

                   SizedBox(
                     height: 40.h,
                   ),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                         onPressed: () {
                           if(_addItemFormKey.currentState!.validate() == false){
                             return;
                           }else{

                             if(int.parse(quantityController.text) >  itemFromHive!.itemModel.quantity){
                               DialogUtilities.showMessage(
                                   context,
                                   "لا يوجد بضاعه كافيه",
                                   posstiveActionName: "حسنا"
                               )
                               ;
                             }else{
                               itemQuantity = int.parse(quantityController.text);
                              // quantityAfterSell = itemFromHive!.itemModel.quantity - itemQuantity;
                              // itemFromHive!.itemModel.quantity = itemQuantity;
                               newOriginalPrice = state.receiptModel.originalPrice + (itemFromHive!.itemModel.originalPrice*itemQuantity);
                               newSellPrice = state.receiptModel.sellPrice + (itemFromHive!.itemModel.sellPrice*itemQuantity);
                               newNetIncome = newSellPrice - newOriginalPrice;
                               // itemFromHive!.itemModel.quantity = int.parse(quantityController.text);
                               try{
                                 // itemsList.add(
                                 //     ItemModel(
                                 //       sellPrice: itemFromHive!.itemModel.sellPrice,
                                 //       originalPrice: itemFromHive!.itemModel.originalPrice,
                                 //       name: itemFromHive!.itemModel.name,
                                 //       quantity: itemQuantity,
                                 //     )
                                 // );


                                 //originalPrice += itemFromHive!.itemModel.originalPrice*int.parse(quantityController.text);
                                 //sellPrice += itemFromHive!.itemModel.sellPrice * int.parse(quantityController.text);
                                 //netIncome =sellPrice - originalPrice;
                                 // receiptsBox.getAt(index)?.itemModel.add(ItemModel(
                                 //   sellPrice: itemFromHive!.itemModel.sellPrice,
                                 //   originalPrice: itemFromHive!.itemModel.originalPrice,
                                 //   name: itemFromHive!.itemModel.name,
                                 //   quantity: itemQuantity,
                                 // ));
                                 state.receiptModel.itemModel.add(
                                   ItemFromHive(itemModel: ItemModel(
                                     sellPrice: itemFromHive!.itemModel.sellPrice,
                                     originalPrice: itemFromHive!.itemModel.originalPrice,
                                     name: itemFromHive!.itemModel.name,
                                     quantity: itemQuantity,
                                   ), key: itemFromHive?.itemModel.key)
                                 );
                                 // state.receiptModel.itemModel.add(ItemModel(
                                 //   sellPrice: itemFromHive!.itemModel.sellPrice,
                                 //   originalPrice: itemFromHive!.itemModel.originalPrice,
                                 //   name: itemFromHive!.itemModel.name,
                                 //   quantity: itemQuantity,
                                 // ));
                                 receiptsBox.putAt(index,
                                     ReceiptModel(
                                       name: GetReceiptDetailsCubit.get(getReceiptsContext).nameController.text,
                                       originalPrice: newOriginalPrice,
                                       sellPrice: newSellPrice,
                                       netIncome: newNetIncome,
                                       itemModel: state.receiptModel.itemModel,

                                     )
                                 );

                                 itemBox.put(
                                     itemFromHive!.key,
                                     ItemModel(
                                         name: itemFromHive!.itemModel.name,
                                         originalPrice: itemFromHive!.itemModel.originalPrice,
                                         sellPrice: itemFromHive!.itemModel.sellPrice,
                                         quantity: itemFromHive!.itemModel.quantity - itemQuantity
                                     )
                                 );
                                 quantityController.clear();
                                 Navigator.pop(context);
                                GetReceiptDetailsCubit.get(getReceiptsContext).getReceiptDetails(receiptIndex: index);
                                 buildShowToast("تم الاضافه بنجاح");

                               }catch(e){
                                 Navigator.pop(context);
                                 buildShowToast(e.toString());
                               }
                             }
                           }

                         },
                         child: const Padding(
                           padding: EdgeInsets.all(8.0),
                           child: Text(
                             "اضافه",
                             style: TextStyle(
                                 color: Colors.white, fontSize: 20),
                           ),
                         )),
                   ),
                   SizedBox(
                     height: 50.h,
                   ),
                 ],
               ),
             ),
           ),
         )).then((value) => quantityController.clear());
   }


   void _showAddExternalItem({
     required BuildContext context,
     required int index,
     required GetReceiptDetailsSuccess state
     //required dynamic key
   }) {
     showModalBottomSheet(
         useSafeArea: true,
         isScrollControlled: true,
         context: context,
         shape: const RoundedRectangleBorder(
           borderRadius: BorderRadius.vertical(
             top: Radius.circular(25.0),
           ),
         ),
         builder: (context) => Padding(
           padding: EdgeInsets.only(
               bottom: MediaQuery.of(context).viewInsets.bottom,
               left: 10,
               right: 10),
           child: SingleChildScrollView(
             child: Form(
               key: _addExternalItemFormKey,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     "اضافه عنصر خارجي جديد",
                     style: TextStyle(fontSize: 25.sp, color: Colors.white),
                   ),
                   SizedBox(
                     height: 20.h,
                   ),
                   CustomFormField(
                     keyboardType: TextInputType.name,
                     hintText: "الاسم",
                     validator: (value) {
                       if (value!.trim().isEmpty) {
                         return "قم باضافه اسم العنصر";
                       } else {
                         return null;
                       }
                     },
                     controller: externalNameItemController,
                   ),
                   SizedBox(
                     height: 10.h,
                   ),
                   CustomFormField(
                     keyboardType: TextInputType.number,
                     hintText: "السعر",
                     validator: (value) {
                       if (value!.trim().isEmpty) {
                         return "قم باضافه سعر العنصر";
                       }else if(value.contains("-")){
                         return "مسموح بادخال ارقام موجبه فقط";
                       }else if(value.contains(",")){
                         return "مسموح بادخال ارقام فقط";
                       } else {
                         return null;
                       }
                     },
                     controller: externalPriceItemController,
                   ),

                   SizedBox(
                     height: 40.h,
                   ),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                         onPressed: () {
                           if(_addExternalItemFormKey.currentState!.validate() == false){
                             return;
                           }else{

                              // itemQuantity = int.parse(quantityController.text);
                               newOriginalPrice = state.receiptModel.originalPrice + int.parse(externalPriceItemController.text);
                               newSellPrice = state.receiptModel.sellPrice + 0;
                               newNetIncome = newSellPrice - newOriginalPrice;
                               try{
                                 state.receiptModel.itemModel.add(
                                     ItemFromHive(itemModel: ItemModel(
                                       sellPrice: 0,
                                       originalPrice: int.parse(externalPriceItemController.text),
                                       name: externalNameItemController.text,
                                       quantity: 1,
                                     ), key: "external key",
                                         type: "External"
                                     )
                                 );
                                 receiptsBox.putAt(index,
                                     ReceiptModel(
                                       name: GetReceiptDetailsCubit.get(getReceiptsContext).nameController.text,
                                       originalPrice: newOriginalPrice,
                                       sellPrice: newSellPrice,
                                       netIncome: newNetIncome,
                                       itemModel: state.receiptModel.itemModel,

                                     )
                                 );

                                 externalPriceItemController.clear();
                                 externalNameItemController.clear();
                                 Navigator.pop(context);
                                 GetReceiptDetailsCubit.get(getReceiptsContext).getReceiptDetails(receiptIndex: index);
                                 buildShowToast("تم الاضافه بنجاح");

                               }catch(e){
                                 Navigator.pop(context);
                                 buildShowToast(e.toString());
                               }
                             }


                         },
                         child: const Padding(
                           padding: EdgeInsets.all(8.0),
                           child: Text(
                             "اضافه",
                             style: TextStyle(
                                 color: Colors.white, fontSize: 20),
                           ),
                         )),
                   ),
                   SizedBox(
                     height: 50.h,
                   ),
                 ],
               ),
             ),
           ),
         )).then((value) => quantityController.clear());
   }


   List<ItemFromHive> getNonEmptyItems(){
     List<ItemFromHive> nonEmptyQuantityList = [];
     for(int i = 0; i < itemBox.length; i++){
       if(itemBox.getAt(i)?.quantity != 0){
         nonEmptyQuantityList.add(ItemFromHive(
             key: itemBox.getAt(i)?.key,
             itemModel: itemBox.getAt(i)!
         ));
       }
     }
     return nonEmptyQuantityList;
   }
}
