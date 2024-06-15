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
  num totalIncome = 0;
  num sellPrice = 0;
  num buyPrice = 0;
  int allEmptyItems = 0;
  num totalItems = 0;
  num totalItemsInStock = 0;
  num existItems = 0;
  getAllItems()async{
    emit(GetAllItemsLoading());
    items = [];
    itemsFromHive = [];
     totalIncome = 0;
     sellPrice = 0;
     buyPrice = 0;
    allEmptyItems = 0;
     totalItems = 0;
     totalItemsInStock = 0;
    existItems = 0;
    try{
       for(int i = 0; i < itemBox.length; i++){
         //itemBox.getAt(i);

        debugPrint("${itemBox.getAt(i)?.key}");
        itemsFromHive.add(
            ItemFromHive(itemModel:  itemBox.getAt(i)!, key: itemBox.getAt(i)!.key)
        );
        sellPrice += itemBox.getAt(i)!.quantity * itemBox.getAt(i)!.sellPrice;
        buyPrice += itemBox.getAt(i)!.quantity * itemBox.getAt(i)!.originalPrice;
        totalItemsInStock += itemBox.getAt(i)!.quantity;
        if(itemBox.getAt(i)!.quantity == 0){
          allEmptyItems ++;
        }else{
          existItems ++;
        }

         // items.add(
         //     itemBox.getAt(i)!
         // );
       }
       totalItems = itemBox.length;
        totalIncome = sellPrice - buyPrice;
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

