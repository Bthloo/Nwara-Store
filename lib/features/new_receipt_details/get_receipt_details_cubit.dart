import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:nwara_store/core/models/receipt_model.dart';

part 'get_receipt_details_state.dart';

class GetReceiptDetailsCubit extends Cubit<GetReceiptDetailsState> {
  GetReceiptDetailsCubit() : super(GetReceiptDetailsInitial());
  final TextEditingController nameController = TextEditingController();

  static GetReceiptDetailsCubit get(context) => BlocProvider.of(context);
  final receiptsBox = Hive.box<ReceiptModel>("receipts");
getReceiptDetails({required int receiptIndex}){
  emit(GetReceiptDetailsLoading());
  try{
    ReceiptModel? receiptModel = receiptsBox.getAt(receiptIndex);
    nameController.text = receiptModel!.name;
    emit(GetReceiptDetailsSuccess(receiptModel));
  }catch(e){
    emit(GetReceiptDetailsError(e.toString()));
  }
}
}
