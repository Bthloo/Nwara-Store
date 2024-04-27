import 'package:hive/hive.dart';
import 'package:nwara_store/core/models/item_from_hive_model.dart';



part 'receipt_model.g.dart';
@HiveType(typeId: 1)
class ReceiptModel extends HiveObject{
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<ItemFromHive> itemModel;

  @HiveField(2)
  final num originalPrice;

  @HiveField(3)
  final num sellPrice;

  @HiveField(4)
  final num netIncome;
  ReceiptModel({required this.name,
    required this.itemModel,
    required this.originalPrice,
    required this.sellPrice,
    required this.netIncome});
}