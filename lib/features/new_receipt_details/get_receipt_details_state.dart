part of 'get_receipt_details_cubit.dart';

sealed class GetReceiptDetailsState {}

final class GetReceiptDetailsInitial extends GetReceiptDetailsState {}
final class GetReceiptDetailsSuccess extends GetReceiptDetailsState {
  final ReceiptModel receiptModel;
  GetReceiptDetailsSuccess(this.receiptModel);
}
final class GetReceiptDetailsLoading extends GetReceiptDetailsState {}
final class GetReceiptDetailsError extends GetReceiptDetailsState {
  final String message;
  GetReceiptDetailsError(this.message);
}
