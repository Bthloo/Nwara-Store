import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:nwara_store/core/models/item_model.dart';

part 'add_item_state.dart';

class AddItemCubit extends Cubit<AddItemState> {
  AddItemCubit() : super(AddItemInitial());
  static AddItemCubit get(context) => BlocProvider.of(context);
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController originalPriceController = TextEditingController();
  TextEditingController sellPriceController = TextEditingController();
  addItem(ItemModel itemModel)async{
    emit(AddItemInitial());
    try{
      Box<ItemModel> itemBox = Hive.box<ItemModel>("items");
      await itemBox.add(itemModel);
      emit(AddItemSuccess("تم الاضافه بنجاح"));
    }catch(e){
      emit(AddItemFailed("Error : ${e.toString()}"));
    }
  }
}
