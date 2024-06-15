import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:nwara_store/core/mobile.dart';
import 'package:nwara_store/features/new_receipt_details/get_receipt_details_cubit.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
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
  final TextEditingController externalNameItemController =
      TextEditingController();
  final TextEditingController externalPriceItemController =
      TextEditingController();

  final _nameFormKey = GlobalKey<FormState>();
  final _addItemFormKey = GlobalKey<FormState>();
  final _addExternalItemFormKey = GlobalKey<FormState>();
  BuildContext? getReceiptsContext;
  //final AddItemToReceiptCubit addItemToReceiptCubit = AddItemToReceiptCubit();

  ItemFromHive? itemFromHive;
  int itemQuantity = 0;
  num newOriginalPrice = 0;
  num newSellPrice = 0;
  num newNetIncome = 0;
bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    debugPrint("NewReceiptDetailsScreen Rebuild");
    int argument = ModalRoute.of(context)!.settings.arguments as int;
    return BlocProvider(
      create: (context) =>
          GetReceiptDetailsCubit()..getReceiptDetails(receiptIndex: argument),
      child: BlocBuilder<GetReceiptDetailsCubit, GetReceiptDetailsState>(
        builder: (context, state) {
          getReceiptsContext = context;
          if (state is GetReceiptDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GetReceiptDetailsSuccess) {
            //nameController.text = state.receiptModel.name;
            return Scaffold(
              appBar: AppBar(
                title: const Text("تفاصيل الفاتورة"),
                actions: [
                  IconButton(
                    onPressed: () {
                      createPdf(state.receiptModel.name, state);
                    },
                    icon: const Icon(
                      Icons.print,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      DialogUtilities.showMessage(
                          context, "هل انت متاكد من مسح هذه الفاتورة؟",
                          nigaiveAction: () async {
                        await receiptsBox.deleteAt(argument);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }, nigaiveActionName: "نعم", posstiveActionName: "الغاء");
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
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
                            if (_nameFormKey.currentState!.validate() ==
                                false) {
                              HapticFeedback.heavyImpact();
                              return;
                            } else {
                              try {
                                receiptsBox.putAt(
                                    argument,
                                    ReceiptModel(
                                        name:
                                            GetReceiptDetailsCubit.get(context)
                                                .nameController
                                                .text,
                                        sellPrice: state.receiptModel.sellPrice,
                                        originalPrice:
                                            state.receiptModel.originalPrice,
                                        netIncome: state.receiptModel.netIncome,
                                        itemModel:
                                            state.receiptModel.itemModel));
                                GetReceiptDetailsCubit.get(context)
                                    .getReceiptDetails(receiptIndex: argument);
                                buildShowToast("تم حفظ التغييرات بنجاح");
                                //Navigator.pop(context);
                              } catch (e) {
                                buildShowToast(e.toString());
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.check,
                            color: ColorHelper.mainColor,
                          ),
                        ),
                        hintText: 'اسم الفاتورة',
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "قم باخال اسم الفاتورة";
                          } else {
                            return null;
                          }
                        },
                        controller:
                            GetReceiptDetailsCubit.get(getReceiptsContext)
                                .nameController,
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                              _showAddItem(
                                  index: argument,
                                  context: context,
                                  state: state);
                              // _showAddItem(
                              //     index: argument!.index,
                              //     context: context,
                              //     key: argument!.receiptModel.key
                              // );
                            },
                            icon: const Icon(
                              Icons.add_circle_sharp,
                              color: ColorHelper.mainColor,
                              size: 30,
                            )),
                        IconButton(
                            onPressed: () {
                              _showAddExternalItem(
                                  index: argument,
                                  context: context,
                                  state: state);
                            },
                            icon: const Icon(
                              Icons.mode_edit_sharp,
                              color: ColorHelper.mainColor,
                              size: 30,
                            )),
                        const Spacer(),
                        Container(
                          height: 3.h,
                          width: MediaQuery.of(context).size.width * .1,
                          decoration: const BoxDecoration(
                              color: ColorHelper.mainColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  topLeft: Radius.circular(25))),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Text("البضاعه المباعه",
                            style: TextStyle(
                                color: ColorHelper.mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp),
                            textDirection: TextDirection.rtl),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          border: Border.all(
                              color: ColorHelper.mainColor, width: 2)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * .3,
                            decoration: const BoxDecoration(
                                color: ColorHelper.mainColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  "العدد",
                                  style: TextStyle(
                                      color: ColorHelper.darkColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 20.h,
                            width: 3.w,
                            color: ColorHelper.mainColor,
                          ),
                          Container(
                            width: MediaQuery.sizeOf(context).width * .3,
                            decoration: const BoxDecoration(
                                color: ColorHelper.mainColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  "اسم الصنف",
                                  style: TextStyle(
                                      color: ColorHelper.darkColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp),
                                ),
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
                              bottom: BorderSide(
                                  width: 2, color: ColorHelper.mainColor),
                                start: BorderSide(
                                    width: 2, color: ColorHelper.mainColor),
                                end: BorderSide(
                                    width: 2, color: ColorHelper.mainColor))),
                        // height: 100.h,
                        // width: double.infinity,
                        child: ListView.separated(
                          separatorBuilder: (context, index) => Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width * .3,
                            color: ColorHelper.mainColor,
                          ),
                          itemCount: state.receiptModel.itemModel.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Slidable(
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
                                              try {
                                                num afterDeleteOriginalPrice =
                                                    (state.receiptModel
                                                            .originalPrice) -
                                                        (state
                                                                .receiptModel
                                                                .itemModel[
                                                                    index]
                                                                .itemModel
                                                                .originalPrice *
                                                            state
                                                                .receiptModel
                                                                .itemModel[
                                                                    index]
                                                                .itemModel
                                                                .quantity);
                                                num afterDeleteSellPrice =
                                                    (state.receiptModel
                                                            .sellPrice) -
                                                        (state
                                                                .receiptModel
                                                                .itemModel[
                                                                    index]
                                                                .itemModel
                                                                .sellPrice *
                                                            state
                                                                .receiptModel
                                                                .itemModel[
                                                                    index]
                                                                .itemModel
                                                                .quantity);

                                                num afterDeleteNetIncome =
                                                    afterDeleteSellPrice -
                                                        afterDeleteOriginalPrice;

                                                receiptsBox.putAt(
                                                    argument,
                                                    ReceiptModel(
                                                        name: state
                                                            .receiptModel.name,
                                                        itemModel: state
                                                            .receiptModel
                                                            .itemModel,
                                                        originalPrice:
                                                            afterDeleteOriginalPrice,
                                                        sellPrice:
                                                            afterDeleteSellPrice,
                                                        netIncome:
                                                            afterDeleteNetIncome));
                                                state.receiptModel.itemModel
                                                    .removeAt(index);

                                                //await itemBox.deleteAt(index);

                                                GetReceiptDetailsCubit.get(
                                                        context)
                                                    .getReceiptDetails(
                                                        receiptIndex: argument);

                                                buildShowToast(
                                                    "تم المسح بنجاح");
                                              } catch (e) {
                                                buildShowToast(e.toString());
                                                debugPrint(e.toString());
                                              }
                                            },
                                            posstiveActionName: "الغاء",
                                          );
                                        },
                                        //icon: Icons.delete,
                                        backgroundColor:
                                            const Color(0xffDA0037),
                                        label: 'مسح',
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5)),
                                      )
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: const ButtonStyle(
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))))),
                                    onPressed: () {
                                      DialogUtilities.showMessage(
                                          context,
                                          "${state.receiptModel.itemModel[index].itemModel.name}\n\n"
                                          " السعر الاصلي :  ${state.receiptModel.itemModel[index].itemModel.originalPrice * state.receiptModel.itemModel[index].itemModel.quantity} \n "
                                          " سعر البيع : ${state.receiptModel.itemModel[index].itemModel.sellPrice * state.receiptModel.itemModel[index].itemModel.quantity} \n "
                                          " صافي الربح : ${(state.receiptModel.itemModel[index].itemModel.sellPrice* state.receiptModel.itemModel[index].itemModel.quantity) - (state.receiptModel.itemModel[index].itemModel.originalPrice* state.receiptModel.itemModel[index].itemModel.quantity)} ",
                                      posstiveActionName: "حسنا"
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Center(
                                            child: Text(
                                              state
                                                  .receiptModel
                                                  .itemModel[index]
                                                  .itemModel
                                                  .quantity
                                                  .toString(),
                                              style: TextStyle(
                                                  color: ColorHelper.darkColor,
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Center(
                                            child: Text(
                                              state
                                                  .receiptModel
                                                  .itemModel[index]
                                                  .itemModel
                                                  .name,
                                              textDirection: TextDirection.rtl,
                                              style: TextStyle(
                                                  color: ColorHelper.darkColor,
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )).animate().shimmer(
                              delay: 200.ms
                            );
                          },
                        ),
                      ),
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return ExpansionTile(
                          maintainState: false,
                          initiallyExpanded: false,
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: ColorHelper.mainColor, width: 2),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25)
                              )),
                          collapsedIconColor: ColorHelper.mainColor,
                          collapsedShape: const RoundedRectangleBorder(
                              side: BorderSide(color: ColorHelper.mainColor, width: 2),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25)
                              )),
                          iconColor: ColorHelper.mainColor,
                          //controller: expansionTileController,
                          onExpansionChanged: (value) {
                            setState((){
                              isExpanded = value;
                            });

                          },
                          title: Text(!isExpanded ? "عرض التفاصيل" : "اخفاء التفاصيل",
                            style: TextStyle(
                                color: ColorHelper.mainColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold
                            ),),
                          children: [
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: ColorHelper.mainColor, width: 2)),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              "${state.receiptModel.originalPrice}",
                                              style: TextStyle(
                                                  color: ColorHelper.mainColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.sp),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              "السعر الاصلي",
                                              style: TextStyle(
                                                  color: ColorHelper.mainColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.sp),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border.symmetric(
                                          vertical: BorderSide(
                                              color: ColorHelper.mainColor, width: 2))),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              "${state.receiptModel.sellPrice}",
                                              style: TextStyle(
                                                  color: ColorHelper.mainColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.sp),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              "سعر البيع",
                                              style: TextStyle(
                                                  color: ColorHelper.mainColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.sp),
                                            ),
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
                                      border: Border.all(
                                          color: ColorHelper.mainColor, width: 2)),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          //width: MediaQuery.sizeOf(context).width*.3,
                                          decoration: const BoxDecoration(
                                              color: ColorHelper.mainColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(12))),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Text(
                                                "${state.receiptModel.netIncome}",
                                                style: TextStyle(
                                                    color: ColorHelper.darkColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.sp),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          // width: MediaQuery.sizeOf(context).width*.3,
                                          decoration: const BoxDecoration(
                                              color: ColorHelper.mainColor,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(12))),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Text(
                                                "صافي الربح",
                                                style: TextStyle(
                                                    color: ColorHelper.darkColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.sp),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                ),
              ),
            );
          } else if (state is GetReceiptDetailsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white, fontSize: 25),
              ),
            );
          } else {
            return const Center(
                child: Text("Error : No State Found",
                    style: TextStyle(color: Colors.white, fontSize: 25)));
          }
        },
      ),
    );
  }

  Future<List<int>> _readFontData() async {
    final ByteData bytes = await rootBundle.load('assets/font/arial.ttf');
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  Future<void> createPdf(String pdfName, GetReceiptDetailsSuccess state) async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    PdfFont font = PdfTrueTypeFont(await _readFontData(), 15);
    // PdfFont font =  PdfTrueTypeFont(File('assets/font/arial.ttf').readAsBytesSync(), 12);
    page.graphics.drawString(
      "Nwara Store",
      PdfStandardFont(PdfFontFamily.helvetica, 30),
      //bounds: const Rect.fromLTWH(0, 0, 0, 0)
    );
    page.graphics.drawString(
      "فاتوره  ${state.receiptModel.name}",
      font,
      bounds: const Rect.fromLTRB(0, 0, 850, 20),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
          textDirection: PdfTextDirection.rightToLeft),
    );

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);
    PdfGridRow header = grid.headers[0];
    header.cells[4].value = "اسم الصنف";
    header.cells[4].style = PdfGridCellStyle(
        font: font,
        backgroundBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
        textBrush: PdfSolidBrush(PdfColor(255, 255, 255)));
    header.cells[0].stringFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[3].value = "العدد";
    header.cells[3].style = PdfGridCellStyle(
        font: font,
        backgroundBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
        textBrush: PdfSolidBrush(PdfColor(255, 255, 255)));
    header.cells[1].stringFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[2].value = "السعر الاصلي";
    header.cells[2].style = PdfGridCellStyle(
        font: font,
        backgroundBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
        textBrush: PdfSolidBrush(PdfColor(255, 255, 255)));
    header.cells[2].stringFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[1].value = "سعر البيع";
    header.cells[1].style = PdfGridCellStyle(
        font: font,
        backgroundBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
        textBrush: PdfSolidBrush(PdfColor(255, 255, 255)));
    header.cells[3].style = PdfGridCellStyle(
        font: font,
        backgroundBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
        textBrush: PdfSolidBrush(PdfColor(255, 255, 255)));
    header.cells[3].stringFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[0].value = "صافي الربح";
    header.cells[0].style = PdfGridCellStyle(
        font: font,
        backgroundBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
        textBrush: PdfSolidBrush(PdfColor(255, 255, 255)));
    header.cells[4].stringFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );

    header.style = PdfGridCellStyle(
        font: font,
        format: PdfStringFormat(textDirection: PdfTextDirection.rightToLeft));
    PdfGridRow row = grid.rows.add();
//PdfGridRow(PdfGrid(), style: PdfGridCellStyle(font: font))
    for (int i = 0; i < state.receiptModel.itemModel.length; i++) {
      row.cells[3].value = "${state.receiptModel.itemModel[i].itemModel.quantity}";
      row.cells[3].style = PdfGridCellStyle(font: PdfStandardFont(PdfFontFamily.helvetica, 15));
      row.cells[3].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      row.cells[2].value =
      "${state.receiptModel.itemModel[i].itemModel.originalPrice*
         state.receiptModel.itemModel[i].itemModel.quantity
      }";
      row.cells[2].style = PdfGridCellStyle(font: PdfStandardFont(PdfFontFamily.helvetica, 15));
      row.cells[2].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      row.cells[1].value =
      "${state.receiptModel.itemModel[i].itemModel.sellPrice*
          state.receiptModel.itemModel[i].itemModel.quantity
      }";
      row.cells[1].style =
          PdfGridCellStyle(
              font: PdfStandardFont(PdfFontFamily.helvetica, 15));
      row.cells[1].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      row.cells[0].value =
      "${(state.receiptModel.itemModel[i].itemModel.sellPrice*  state.receiptModel.itemModel[i].itemModel.quantity) -
          (state.receiptModel.itemModel[i].itemModel.originalPrice*  state.receiptModel.itemModel[i].itemModel.quantity)}";
      row.cells[0].style = PdfGridCellStyle(
          font: PdfStandardFont(PdfFontFamily.helvetica, 15));
      row.cells[0].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      row.cells[4].value = state.receiptModel.itemModel[i].itemModel.name;
      row.cells[4].style = PdfGridCellStyle(font: font);

      row.cells[4].stringFormat = PdfStringFormat(
        textDirection: PdfTextDirection.rightToLeft,
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      row = grid.rows.add();
    }
    row.cells[3].value = "${state.receiptModel.itemModel.length}";
    row.cells[3].style =
        PdfGridCellStyle(font: PdfStandardFont(PdfFontFamily.helvetica, 15));
    row.cells[3].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    row.cells[2].value = "${state.receiptModel.originalPrice}";
    row.cells[2].style =
        PdfGridCellStyle(font: PdfStandardFont(PdfFontFamily.helvetica, 15));
    row.cells[2].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );

    row.cells[1].value = "${state.receiptModel.sellPrice}";
    row.cells[1].style =
        PdfGridCellStyle(font: PdfStandardFont(PdfFontFamily.helvetica, 15));
    row.cells[1].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    row.cells[0].value = "${state.receiptModel.netIncome}";
    row.cells[0].style =
        PdfGridCellStyle(font: PdfStandardFont(PdfFontFamily.helvetica, 15));
    row.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    row.cells[4].value = "المجموع";
    row.cells[4].style = PdfGridCellStyle(
        font: font,
        backgroundBrush: PdfSolidBrush(PdfColor(0, 0, 0)),
        textBrush: PdfSolidBrush(PdfColor(255, 255, 255)));
    row.cells[4].stringFormat = PdfStringFormat(
      textDirection: PdfTextDirection.rightToLeft,
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    row = grid.rows.add();
    try {
      grid.draw(
          page: document.pages[0], bounds: const Rect.fromLTRB(0, 100, 0, 0));
    } catch (e) {
      buildShowToast(e.toString());
    }

    List<int> bytes = await document.save();
    document.dispose();

    saveAndLunchFile(bytes, "$pdfName.pdf");
  }

  void _showAddItem(
      {required BuildContext context,
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
                        dropdownButtonProps:
                            const DropdownButtonProps(color: Colors.white),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                            textAlign: TextAlign.center,
                            baseStyle: TextStyle(color: Colors.white)),
                        popupProps: const PopupProps.menu(
                            searchFieldProps: TextFieldProps(
                                style: TextStyle(color: Colors.black)),
                            showSearchBox: true,
                            menuProps: MenuProps(
                              backgroundColor: Colors.white,
                            ),
                            fit: FlexFit.loose),
                        items: getNonEmptyItems(),

                        itemAsString: (item) {
                          return " ${item.itemModel.name} : الاسم  "
                              "\n ${item.itemModel.quantity} : الكميه  "
                              "---------------------------------------";
                        },
                        validator: (value) {
                          if (value == null) {
                            return "قم باختيار الصنف";
                          } else {
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
                          } else if (value.contains("-")) {
                            return "مسموح بادخال ارقام موجبه فقط";
                          } else if (value.contains(",")) {
                            return "غير مسموح بادخال الفاصله";
                          }else if(value.contains(".")){
                            return "غير مسموح بالارقام العشريه";
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
                              if (_addItemFormKey.currentState!.validate() ==
                                  false) {
                                HapticFeedback.heavyImpact();

                                return;
                              } else {
                                if (int.parse(quantityController.text) >
                                    itemFromHive!.itemModel.quantity) {
                                  DialogUtilities.showMessage(
                                      context, "لا يوجد بضاعه كافيه",
                                      posstiveActionName: "حسنا");
                                } else {
                                  itemQuantity =
                                      int.parse(quantityController.text);
                                  // quantityAfterSell = itemFromHive!.itemModel.quantity - itemQuantity;
                                  // itemFromHive!.itemModel.quantity = itemQuantity;
                                  newOriginalPrice = state
                                          .receiptModel.originalPrice +
                                      (itemFromHive!.itemModel.originalPrice *
                                          itemQuantity);
                                  newSellPrice = state.receiptModel.sellPrice +
                                      (itemFromHive!.itemModel.sellPrice *
                                          itemQuantity);
                                  newNetIncome =
                                      newSellPrice - newOriginalPrice;
                                  // itemFromHive!.itemModel.quantity = int.parse(quantityController.text);
                                  try {
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
                                    state.receiptModel.itemModel
                                        .add(ItemFromHive(
                                            itemModel: ItemModel(
                                              sellPrice: itemFromHive!
                                                  .itemModel.sellPrice,
                                              originalPrice: itemFromHive!
                                                  .itemModel.originalPrice,
                                              name:
                                                  itemFromHive!.itemModel.name,
                                              quantity: itemQuantity,
                                            ),
                                            key: itemFromHive?.itemModel.key));
                                    // state.receiptModel.itemModel.add(ItemModel(
                                    //   sellPrice: itemFromHive!.itemModel.sellPrice,
                                    //   originalPrice: itemFromHive!.itemModel.originalPrice,
                                    //   name: itemFromHive!.itemModel.name,
                                    //   quantity: itemQuantity,
                                    // ));
                                    receiptsBox.putAt(
                                        index,
                                        ReceiptModel(
                                          name: GetReceiptDetailsCubit.get(
                                                  getReceiptsContext)
                                              .nameController
                                              .text,
                                          originalPrice: newOriginalPrice,
                                          sellPrice: newSellPrice,
                                          netIncome: newNetIncome,
                                          itemModel:
                                              state.receiptModel.itemModel,
                                        ));

                                    itemBox.put(
                                        itemFromHive!.key,
                                        ItemModel(
                                            name: itemFromHive!.itemModel.name,
                                            originalPrice: itemFromHive!
                                                .itemModel.originalPrice,
                                            sellPrice: itemFromHive!
                                                .itemModel.sellPrice,
                                            quantity: itemFromHive!
                                                    .itemModel.quantity -
                                                itemQuantity));
                                    quantityController.clear();
                                    Navigator.pop(context);
                                    GetReceiptDetailsCubit.get(
                                            getReceiptsContext)
                                        .getReceiptDetails(receiptIndex: index);
                                    buildShowToast("تم الاضافه بنجاح");
                                  } catch (e) {
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

  void _showAddExternalItem(
      {required BuildContext context,
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
                          } else if (value.contains("-")) {
                            return "مسموح بادخال ارقام موجبه فقط";
                          } else if (value.contains(",")) {
                            return "غير مسموح بادخال الفاصله";
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
                              if (_addExternalItemFormKey.currentState!
                                      .validate() ==
                                  false) {
                                HapticFeedback.heavyImpact();

                                return;
                              } else {
                                // itemQuantity = int.parse(quantityController.text);
                                newOriginalPrice = state
                                        .receiptModel.originalPrice +
                                    num.parse(externalPriceItemController.text);
                                newSellPrice = state.receiptModel.sellPrice + 0;
                                newNetIncome = newSellPrice - newOriginalPrice;
                                try {
                                  state.receiptModel.itemModel.add(ItemFromHive(
                                      itemModel: ItemModel(
                                        sellPrice: 0,
                                        originalPrice: num.parse(
                                            externalPriceItemController.text),
                                        name: externalNameItemController.text,
                                        quantity: 1,
                                      ),
                                      key: "external key",
                                      type: "External"));
                                  receiptsBox.putAt(
                                      index,
                                      ReceiptModel(
                                        name: GetReceiptDetailsCubit.get(
                                                getReceiptsContext)
                                            .nameController
                                            .text,
                                        originalPrice: newOriginalPrice,
                                        sellPrice: newSellPrice,
                                        netIncome: newNetIncome,
                                        itemModel: state.receiptModel.itemModel,
                                      ));

                                  externalPriceItemController.clear();
                                  externalNameItemController.clear();
                                  Navigator.pop(context);
                                  GetReceiptDetailsCubit.get(getReceiptsContext)
                                      .getReceiptDetails(receiptIndex: index);
                                  buildShowToast("تم الاضافه بنجاح");
                                } catch (e) {
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

  List<ItemFromHive> getNonEmptyItems() {
    List<ItemFromHive> nonEmptyQuantityList = [];
    for (int i = 0; i < itemBox.length; i++) {
      if (itemBox.getAt(i)?.quantity != 0) {
        nonEmptyQuantityList.add(ItemFromHive(
            key: itemBox.getAt(i)?.key, itemModel: itemBox.getAt(i)!));
      }
    }
    return nonEmptyQuantityList;
  }
}
