part of 'get_all_items_cubit.dart';

@immutable
sealed class GetAllItemsState {}

final class GetAllItemsInitial extends GetAllItemsState {}
final class GetAllItemsLoading extends GetAllItemsState {}
final class GetAllItemsSuccess extends GetAllItemsState {
 final List<ItemFromHive> items;
  GetAllItemsSuccess(this.items);
}
final class GetNonEmptyItems extends GetAllItemsState{}
final class GetAllItemsFailure extends GetAllItemsState {
  final String message;
  GetAllItemsFailure(this.message);
}
