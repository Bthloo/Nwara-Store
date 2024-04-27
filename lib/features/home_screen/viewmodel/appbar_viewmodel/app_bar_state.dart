part of 'app_bar_cubit.dart';

@immutable
sealed class BottomAppBarState {}

final class BottomAppBarInitial extends BottomAppBarState {}
final class ChangeBottomAppbarState extends BottomAppBarState {}
