import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/models/item_from_hive_model.dart';
import '../../../../core/models/item_model.dart';

part 'get_all_items_state.dart';

class GetAllItemsCubit extends Cubit<GetAllItemsState> {
  GetAllItemsCubit() : super(GetAllItemsInitial());
  TextEditingController searchController = TextEditingController();
  static GetAllItemsCubit get(context) => BlocProvider.of(context);

  final itemBox = Hive.box<ItemModel>("items");
  List<ItemModel> items = [];
  List<ItemFromHive> searchItem = [];
  List<ItemFromHive> itemsFromHive = [];
  getAllItems()async{
    emit(GetAllItemsLoading());
    items = [];
    itemsFromHive = [];
    try{
       for(int i = 0; i < itemBox.length; i++){
         //itemBox.getAt(i);
        debugPrint("${itemBox.getAt(i)?.key}");
        itemsFromHive.add(
            ItemFromHive(itemModel:  itemBox.getAt(i)!, key: itemBox.getAt(i)!.key)
        );
         // items.add(
         //     itemBox.getAt(i)!
         // );
       }

       emit(GetAllItemsSuccess(itemsFromHive));
    }catch(e){
      GetAllItemsFailure(e.toString());
    }
  }
  getSearchItem(String query){
    if(query.isNotEmpty||query !=""){
      searchItem = itemsFromHive.where((element){
        final itemName = element.itemModel.name.toLowerCase();
        final searchInput = query.toLowerCase();
        return itemName.contains(searchInput);

      }).toList();
    }

  }
}

