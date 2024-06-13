import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:nwara_store/core/general_components/color_helper.dart';
import 'package:nwara_store/core/general_components/build_show_toast.dart';
import 'package:nwara_store/core/general_components/custom_form_field.dart';
import 'package:nwara_store/core/models/item_model.dart';

import '../../../../core/general_components/dialog.dart';
import '../../../../core/models/item_from_hive_model.dart';
import '../../../item_details_screen/view/pages/item_details_screen.dart';
import '../../viewmodel/add_item_viewmodel/add_item_cubit.dart';
import '../../viewmodel/get_all_items/get_all_items_cubit.dart';

//ignore: must_be_immutable
class ItemsTab extends StatelessWidget {
  ItemsTab({super.key});
  final _formKey = GlobalKey<FormState>();
  final AddItemCubit addItemCubit = AddItemCubit();
  //GetAllItemsCubit getAllItems = GetAllItemsCubit();
  final itemBox = Hive.box<ItemModel>("items");
  late BuildContext? getAllItemsContext ;
final TextEditingController searchController = TextEditingController();
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
            create: (context) => GetAllItemsCubit()..getAllItems(),
            child: BlocBuilder<GetAllItemsCubit, GetAllItemsState>(

              // bloc: getAllItems,
              builder: (context, state) {
                var cubit = GetAllItemsCubit.get(context);
                getAllItemsContext = context;
                if (state is GetAllItemsSuccess) {
                  if (state.items.isEmpty) {
                    return Center(
                      child: Text(
                        "لا يوجد عناصر لعرضها",
                        style: TextStyle(fontSize: 25.sp, color: Colors.white),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  showAdaptiveDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("الاحصائيات", style: TextStyle(
                                            fontFamily: "Cairo",
                                          ),
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                    "عدد العناصر : ${cubit.totalItems}\n"
                                                        "عدد العناصر الفارغه : ${cubit.allEmptyItems}\n"
                                                    "عدد العناصر الموجوده : ${cubit.totalItemsInStock}\n"

                                                    "اجمالي السعر الاصلي : ${cubit.buyPrice}\n"
                                                    "اجمالي سعر البيع : ${cubit.sellPrice}\n"
                                                    "اجمالي الربح : ${cubit.totalIncome}",
                                                style: const TextStyle(
                                                  fontFamily: "Cairo",
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("حسنا",
                                                    style: TextStyle(
                                                      color: ColorHelper.darkColor,
                                                    ),
                                                  )
                                              )
                                            ],
                                          )
                                        );
                                      },
                                  );
                                  // DialogUtilities.showMessage(
                                  //     context,
                                  //     "الاحصائيات\n\n"
                                  //         "عدد العناصر : ${cubit.totalItems}\n"
                                  //         "عدد العناصر الموجوده : ${cubit.totalItemsInStock}\n"
                                  //         "عدد العناصر الفارغه : ${cubit.allEmptyItems}\n"
                                  //     "اجمالي السعر الاصلي : ${cubit.buyPrice}\n"
                                  //         "احمالي سعر البيع : ${cubit.sellPrice}\n"
                                  // "اجمالي الربح : ${cubit.totalIncome}"
                                  //
                                  //
                                  //
                                  // );
                                },
                                icon: const Icon(Icons.calculate_outlined,color: ColorHelper.mainColor,)
                            ),
                            IconButton(
                                onPressed: (){
                                  cubit.searchItem = [];
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        child:
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: StatefulBuilder(
                                              builder: (context, setState) {
                                                return Column(
                                                  children: [
                                                    TextButton.icon(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        },
                                                       label: const Text("اغلاق"),
                                                      icon: const Icon(Icons.close),
                                                    ),
                                                    SizedBox(height: 10.h,),
                                                    CustomFormField(
                                                      focus : true,
                                                        onChange: (value) {
                                                          cubit.searchController.text = value!;
                                                          setState((){
                                                            cubit.getSearchItem(value);
                                                          });
                                                        },
                                                        hintText: "بحث",
                                                        validator: (p0) {
                                                          return null;
                                                        },
                                                        controller: cubit.searchController
                                                    ),
                                                    SizedBox(height: 10.h,),
                                                    cubit.searchItem.isEmpty ?
                                                    const SizedBox(
                                                      height: 50,
                                                      child: Text("لا يوجد نتائج",style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.white
                                                      ),),
                                                    ) :
                                                    Expanded(
                                                      child: ListView.separated(
                                                        itemCount: cubit.searchItem.length,
                                                        separatorBuilder: (context, index) => SizedBox(
                                                          height: 5.h,
                                                        ),
                                                        itemBuilder: (context, index) {
                                                          return Stack(
                                                            alignment: Alignment.topRight,
                                                            children:[
                                                              ElevatedButton(
                                                              style: const ButtonStyle(
                                                                  shape: WidgetStatePropertyAll(
                                                                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(13)))
                                                                  )
                                                              ),
                                                              onPressed: (){
                                                               // Navigator.pop(context);
                                                                Navigator.pushNamed(
                                                                    context,
                                                                    ItemDetailsScreen.routeName,
                                                                    arguments: Argument(
                                                                        index: index,
                                                                        itemFromHive: cubit.searchItem[index]))
                                                                    .then((value){
                                                                  GetAllItemsCubit.get(getAllItemsContext)
                                                                      .getAllItems();
                                                                  if(Navigator.canPop(context)){
                                                                    Navigator.pop(context);
                                                                  }

                                                                });
                                                              },
                                                              child: Container(
                                                                  padding: const EdgeInsets.all(8),
                                                                  // decoration: BoxDecoration(
                                                                  //     color: ColorHelper.mainColor,
                                                                  //     borderRadius: BorderRadius.circular(12),
                                                                  //     border: Border.all(
                                                                  //         color: ColorHelper.mainColor)),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        cubit.searchItem[index].itemModel.name,
                                                                        textDirection: TextDirection.rtl,
                                                                        style: TextStyle(
                                                                          overflow: TextOverflow.ellipsis,
                                                                          color: ColorHelper.darkColor,
                                                                          fontSize: 15.sp,
                                                                          //fontWeight: FontWeight.w500
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5.h,
                                                                      ),
                                                                      Text(
                                                                        "الكميه : ${cubit.searchItem[index].itemModel.quantity}",
                                                                        textDirection: TextDirection.rtl,
                                                                        style: TextStyle(
                                                                          overflow: TextOverflow.ellipsis,
                                                                          color: cubit.searchItem[index].itemModel.quantity == 0 ?
                                                                          Colors.red : ColorHelper.darkColor,
                                                                          fontSize: 13.sp,
                                                                          //fontWeight: FontWeight.w500
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5.h,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment.spaceAround,
                                                                        children: [
                                                                          Text(
                                                                            "سعر البيع : ${cubit.searchItem[index].itemModel.sellPrice}",
                                                                            textDirection: TextDirection.rtl,
                                                                            style: TextStyle(
                                                                              overflow: TextOverflow.ellipsis,
                                                                              color: ColorHelper.darkColor,
                                                                              fontSize: 13.sp,
                                                                              //fontWeight: FontWeight.w500
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            "السعر الاصلي : ${cubit.searchItem[index].itemModel.originalPrice}",
                                                                            textDirection: TextDirection.rtl,
                                                                            style: TextStyle(
                                                                              overflow: TextOverflow.ellipsis,
                                                                              color: ColorHelper.darkColor,
                                                                              fontSize: 13.sp,
                                                                              //fontWeight: FontWeight.w500
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                              Icon(Icons.error_outline,
                                                                size: 25.sp,
                                                                color: cubit.searchItem[index].itemModel.quantity == 0 ?
                                                                Colors.red : Colors.transparent,
                                                              ),
                                                            ]
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),



                                      );
                                    },).then( (value) {
                                    cubit.searchController.clear();
                                    cubit.searchItem= [];
                                    });
                                },
                                icon: const Icon(Icons.search,color: ColorHelper.mainColor),
                               // label: const Text("بحث")
                            ),
                          ],
                        ),

                        Expanded(
                          child: ListView.separated(
                            separatorBuilder: (context, index) => SizedBox(
                              height: 5.h,
                            ),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              return Slidable(
                                endActionPane: ActionPane(
                                  extentRatio: .25,
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (buildContext) {
                                        DialogUtilities.showMessage(
                                          context,
                                          "هل انت متاكد من مسح هذا العنصر؟",
                                          nigaiveActionName: "مسح",
                                          nigaiveAction: () async {
                                            HapticFeedback.heavyImpact();
                                            try {
                                              await itemBox.deleteAt(index);
                                              if (context.mounted) {
                                                GetAllItemsCubit.get(context)
                                                    .getAllItems();
                                              }
                                              buildShowToast("تم المسح بنجاح");
                                            } catch (e) {
                                              buildShowToast(e.toString());
                                            }
                                          },
                                          posstiveActionName: "الغاء",
                                        );
                                      },
                                      icon: Icons.delete,
                                      backgroundColor: const Color(0xffDA0037),
                                      label: 'مسح',
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(13)),
                                    )
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ElevatedButton(
                                    style: const ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(13)))
                                      )
                                    ),
                                    onPressed: (){
                                      Navigator.pushNamed(
                                          context, ItemDetailsScreen.routeName,
                                          arguments: Argument(
                                              index: index,
                                              itemFromHive: state.items[index]))
                                          .then((value) => GetAllItemsCubit.get(context)
                                          .getAllItems());
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            state.items[index].itemModel.name,
                                            textDirection: TextDirection.rtl,
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: ColorHelper.darkColor,
                                              fontSize: 20.sp,
                                              //fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Text(
                                            " الكميه : ${state.items[index].itemModel.quantity}",
                                            textDirection: TextDirection.rtl,
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color:state.items[index].itemModel.quantity == 0 ? Colors.red :
                                              ColorHelper.darkColor,
                                              fontSize: 13.sp,
                                              //fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                "سعر البيع : ${state.items[index].itemModel.sellPrice}",
                                                textDirection: TextDirection.rtl,
                                                style: TextStyle(
                                                  overflow: TextOverflow.ellipsis,
                                                  color: ColorHelper.darkColor,
                                                  fontSize: 17.sp,
                                                  //fontWeight: FontWeight.w500
                                                ),
                                              ),
                                              Text(
                                                "السعر الاصلي : ${state.items[index].itemModel.originalPrice}",
                                                textDirection: TextDirection.rtl,
                                                style: TextStyle(
                                                  overflow: TextOverflow.ellipsis,
                                                  color: ColorHelper.darkColor,
                                                  fontSize: 17.sp,
                                                  //fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                    IconButton(
                                      onPressed: () {
                                        DialogUtilities.showMessage(
                                            context,
                                            "\nانتهت الكميه لهذا العنص\n",
                                         // nigaiveActionName: "تعديل",
                                        );
                                      },
                                      icon: Icon (
                                        Icons.error_outline,
                                        size: 30.sp,
                                        color: state.items[index].itemModel.quantity == 0 ?
                                        Colors.red : Colors.transparent,),

                                    )
                                  ],
                                ),
                              ).animate().shimmer();
                            },
                          ),
                        ),
                      ],
                    );
                  }
                } else if (state is GetAllItemsFailure) {
                  return Center(
                    child: Text(state.message),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ));
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
        builder: (context) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 10,
              right: 10),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                    controller: addItemCubit.nameController,
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
                      }else if(value.contains(",")){
                        return "غير مسموح بادخال الفاصله";
                      }else if(value.contains(".")){
                        return "غير مسموح بالارقام العشريه";
                      } else {
                        return null;
                      }
                    },
                    controller: addItemCubit.quantityController,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  CustomFormField(
                    keyboardType: TextInputType.number,
                    hintText: "السعر الاساسي",
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return "قم باضافه السعر الاساسي للعنصر";
                      }else if(value.contains("-")){
                        return "مسموح بادخال ارقام موجبه فقط";
                      }else if(value.contains(",")){
                        return "غير مسموح بادخال الفاصله";
                      }
                      else {
                        return null;
                      }
                    },
                    controller: addItemCubit.originalPriceController,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  CustomFormField(
                    keyboardType: TextInputType.number,
                    hintText: "سعر البيع",
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return "قم باضافه سعر البيع للعنصر";
                      }else if(value.contains("-")){
                        return "مسموح بادخال ارقام موجبه فقط";
                      }else if(value.contains(",")){
                        return "غير مسموح بادخال الفاصله";
                      } else {
                        return null;
                      }
                    },
                    controller: addItemCubit.sellPriceController,
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  BlocConsumer<AddItemCubit, AddItemState>(
                    bloc: addItemCubit,
                    listener: (context, state) {
                      if (state is AddItemFailed) {
                        HapticFeedback.heavyImpact();
                        buildShowToast(state.message);
                      } else if (state is AddItemSuccess) {
                        addItemCubit.sellPriceController.clear();
                        addItemCubit.nameController.clear();
                        addItemCubit.originalPriceController.clear();
                        buildShowToast(state.message);
                        Navigator.pop(context);
                      }
                    },
                    builder: (context, state) {
                      if (state is AddItemLoading) {
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
                                addItemm(context);
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
          GetAllItemsCubit.get(getAllItemsContext).getAllItems();
          addItemCubit.quantityController.clear();
          addItemCubit.sellPriceController.clear();
          addItemCubit.nameController.clear();
          addItemCubit.originalPriceController.clear();

        });
  }

  addItemm( BuildContext context) {
    if (_formKey.currentState!.validate() == false) {
      HapticFeedback.heavyImpact();
      return;
    } else {
      addItemCubit.addItem(ItemModel(
          name: addItemCubit
              .nameController.text,
          originalPrice:num.parse(addItemCubit.originalPriceController.text.trim()),
          sellPrice: num.parse(addItemCubit.sellPriceController.text.trim()),
          quantity: int.parse(addItemCubit.quantityController.text.trim())
      ));
    }
  }
}
class Argument {
  ItemFromHive itemFromHive;
  int index ;
  Argument({required this.itemFromHive,required this.index});
}
