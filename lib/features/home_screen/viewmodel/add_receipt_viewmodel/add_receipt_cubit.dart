import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:nwara_store/core/models/receipt_model.dart';

part 'add_receipt_state.dart';

class AddReceiptCubit extends Cubit<AddReceiptState> {
  AddReceiptCubit() : super(AddReceiptInitial());
  static AddReceiptCubit get(context) => BlocProvider.of(context);
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController originalPriceController = TextEditingController();
  TextEditingController sellPriceController = TextEditingController();
  TextEditingController netIncomeController = TextEditingController();
  addReceipt(ReceiptModel receiptModel)async{
    emit(AddReceiptInitial());
    try{
      Box<ReceiptModel> itemBox = Hive.box<ReceiptModel>("receipts");
      await itemBox.add(receiptModel);
      emit(AddReceiptSuccess("تم الاضافه بنجاح"));
    }catch(e){
      emit(AddReceiptFailed("Error : ${e.toString()}"));
    }
  }
}
