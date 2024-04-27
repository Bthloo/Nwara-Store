import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/models/receipt_model.dart';

part 'get_receipts_state.dart';

class GetReceiptsCubit extends Cubit<GetReceiptsState> {
  GetReceiptsCubit() : super(GetReceiptsInitial());
  static GetReceiptsCubit get(context) => BlocProvider.of(context);
  final receiptsBox = Hive.box<ReceiptModel>("receipts");
  List<ReceiptModel> receipts = [];
  getReceipts() {
    receipts = [];
    emit(GetReceiptsLoading());
    try {
      for (int i = 0; i < receiptsBox.length; i++) {
        receipts.add(receiptsBox.getAt(i)!);
      }

      emit(GetReceiptsSuccess(receipts));
    } catch (e) {
      GetReceiptsFailed(e.toString());
    }
  }
}
