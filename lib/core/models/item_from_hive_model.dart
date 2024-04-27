import 'package:hive/hive.dart';

import 'item_model.dart';
part 'item_from_hive_model.g.dart';


@HiveType(typeId: 4)
class ItemFromHive {
  @HiveField(0)
  ItemModel itemModel;

  @HiveField(1)
  dynamic key;

  @HiveField(2)
  String? type;

  ItemFromHive({required this.itemModel, required this.key,this.type});
}