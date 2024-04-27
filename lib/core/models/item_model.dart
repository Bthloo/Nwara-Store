import 'package:hive/hive.dart';

part 'item_model.g.dart';

@HiveType(typeId: 0)
class ItemModel extends HiveObject{
  
  @HiveField(0)
  final String name;

  @HiveField(1)
  final num originalPrice;

  @HiveField(2)
  final num sellPrice;

  @HiveField(3)
   int quantity;

  ItemModel({
    required this.name,
    required this.originalPrice,
    required this.sellPrice,
    required this.quantity
  }
      );

}