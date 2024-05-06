import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:nwara_store/core/general_components/color_helper.dart';
import 'package:nwara_store/core/general_components/build_show_toast.dart';
import 'package:nwara_store/core/general_components/dialog.dart';
import 'package:nwara_store/core/models/receipt_model.dart';
import 'package:nwara_store/features/home_screen/viewmodel/get_receipts/get_receipts_cubit.dart';
import 'package:nwara_store/features/new_receipt_details/view/pages/new_receipt_details_screen.dart';

import '../../../../core/general_components/custom_form_field.dart';
import '../../viewmodel/add_receipt_viewmodel/add_receipt_cubit.dart';

//ignore: must_be_immutable
class ReceiptTab extends StatelessWidget {
  ReceiptTab({super.key});
  final _formKey = GlobalKey<FormState>();
  final GetReceiptsCubit getReceiptsCubit = GetReceiptsCubit();
  final AddReceiptCubit addReceiptsCubit = AddReceiptCubit();
  final itemBox = Hive.box<ReceiptModel>("receipts");
  late BuildContext? getReceiptContext ;

  //GetAllItemsCubit getAllItemsCubit = GetAllItemsCubit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "اضافه عنصر جديد",
        backgroundColor: ColorHelper.mainColor,
        child: const Icon(
          Icons.add,
          color: ColorHelper.darkColor,
        ),
        onPressed: () {
          // GetAllItemsCubit.get(contextttttt).getAllItems();
          _showAddItem(context);
        },
      ),
      body: Padding(

        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: BlocProvider(
          create: (context) => GetReceiptsCubit()..getReceipts(),
          child: BlocBuilder<GetReceiptsCubit, GetReceiptsState>(
          //  bloc: getAllItemsCubit,
            builder: (context, state) {
              if (state is GetReceiptsSuccess) {
                getReceiptContext = context;
                if(state.receipts.isEmpty){
                  return Center(
                    child: Text("لا يوجد فواتير لعرضها",style: TextStyle(
                      fontSize: 25.sp,
                      color: Colors.white
                    ),),
                  );
                }else{
                  return ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 5.h,),
                    itemCount: state.receipts.length,
                    itemBuilder: (context, index) {
                      return Slidable(
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
                                        await itemBox.deleteAt(index);
                                        if(context.mounted){
                                          GetReceiptsCubit.get(context).getReceipts();
                                        }
                                        buildShowToast("تم المسح بنجاح");
                                      }catch(e){
                                        buildShowToast(e.toString());
                                      }

                                  },
                                  posstiveActionName: "الغاء",
                                );
                              },
                              icon: Icons.delete,
                              backgroundColor: const Color(0xffDA0037),
                              label: 'مسح',
                              borderRadius: const BorderRadius.all(Radius.circular(13)),

                            )
                          ],
                        ),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(13)))
                              )
                          ),
                          onPressed: (){
                            Navigator.pushNamed(context,
                                NewReceiptDetailsScreen.routeName,
                                arguments: index
                            ).then((value) => GetReceiptsCubit.get(context).getReceipts());
                            // Navigator.pushNamed(
                            //     context,
                            //     ReceiptDetailsScreen.routeName,
                            //     arguments:ReceiptArgument(receiptModel: state.receipts[index], index: index)
                            // ).then((value) => GetReceiptsCubit.get(context).getReceipts());
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: 60.h,
                            child: Center(
                              child: Text(state.receipts[index].name,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: ColorHelper.darkColor,
                                  fontSize: 20.sp,
                                  //fontWeight: FontWeight.w500
                                ),
                                textAlign: TextAlign.center,
                              ) ,
                            ),
                          ),


                          // Container(
                          //     padding: const EdgeInsets.all(8),
                          //
                          //     child: Column(
                          //       children: [
                          //         Text(state.receipts[index].name,
                          //           textDirection: TextDirection.rtl,
                          //           style: TextStyle(
                          //             overflow: TextOverflow.ellipsis,
                          //             color: ColorHelper.darkColor,
                          //             fontSize: 20.sp,
                          //             //fontWeight: FontWeight.w500
                          //           ),
                          //         ),
                          //         SizedBox(height: 5.h,),
                          //         Row(
                          //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //           children: [
                          //             Text("سعر البيع : ${state.receipts[index].sellPrice}",
                          //               textDirection: TextDirection.rtl,
                          //               style: TextStyle(
                          //                 overflow: TextOverflow.ellipsis,
                          //                 color: ColorHelper.darkColor,
                          //                 fontSize: 17.sp,
                          //                 //fontWeight: FontWeight.w500
                          //               ),
                          //             ),
                          //             Text("السعر الاصلي : ${state.receipts[index].originalPrice}",
                          //               textDirection: TextDirection.rtl,
                          //               style: TextStyle(
                          //                 overflow: TextOverflow.ellipsis,
                          //                 color: ColorHelper.darkColor,
                          //                 fontSize: 17.sp,
                          //                 //fontWeight: FontWeight.w500
                          //               ),
                          //             ),
                          //           ],
                          //         )
                          //       ],
                          //     )),
                        ),
                      ).animate().shimmer();
                    },
                  );
                }

              } else if (state is GetReceiptsFailed) {
                return Center(child: Text(state.message),);
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }


  void _showAddItem(BuildContext context) {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) => Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 10,
                right: 10),
            child: SingleChildScrollView(
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
                  CustomFormField(
                    hintText: "الاسم",
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return "قم باضافه اسم العنصر";
                      } else {
                        return null;
                      }
                    },
                    controller: addReceiptsCubit.nameController,
                  ),


                  SizedBox(
                    height: 40.h,
                  ),
                  BlocConsumer<AddReceiptCubit, AddReceiptState>(
                    bloc: addReceiptsCubit,
                    listener: (context, state) {
                      if (state is AddReceiptFailed) {
                        buildShowToast(state.message);
                      } else if (state is AddReceiptSuccess) {
                        addReceiptsCubit.nameController.clear();
                        buildShowToast(state.message);
                        Navigator.pop(context);
                      }
                    },
                    builder: (context, state) {
                      if (state is GetReceiptsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ColorHelper.mainColor,
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                addItem(
                                   ReceiptModel(
                                       name: addReceiptsCubit.nameController.text,
                                       itemModel: [],
                                       originalPrice: 0,
                                       sellPrice: 0,
                                       netIncome: 0
                                   ),
                                    context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "اضافه",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              )),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                ],
              ),
            ),
          ),
        )).then(
            (value) {
              GetReceiptsCubit.get(getReceiptContext).getReceipts();
              addReceiptsCubit.nameController.clear();
            });
  }
  addItem(ReceiptModel receiptModel, BuildContext context) {
    if (_formKey.currentState!.validate() == false) {
      return;
    } else {
      addReceiptsCubit.addReceipt(receiptModel);
    }
  }
}
class ReceiptArgument{
 // ItemModel itemModel;
    ReceiptModel receiptModel;
    int index;
    ReceiptArgument({required this.receiptModel,required this.index});
}
