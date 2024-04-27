import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view/pages/items_tab.dart';
import '../../view/pages/receipt_tab.dart';
part 'app_bar_state.dart';
class BottomAppBarCubit extends Cubit<BottomAppBarState> {
  BottomAppBarCubit() : super(BottomAppBarInitial());
  static BottomAppBarCubit get(context) => BlocProvider.of(context);
  int currentTapIndex = 0;
  List<Widget> tabs = [
    ReceiptTab(),
    ItemsTab(),
  ];
  void changeIndex(int index) {
    currentTapIndex = index;
    emit(ChangeBottomAppbarState());
  }
}
