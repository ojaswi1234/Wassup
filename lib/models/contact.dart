

import 'package:hive/hive.dart';

part 'contact.g.dart';



@HiveType(typeId: 0)
class Contact extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phoneNumber;

  Contact({required this.name, required this.phoneNumber});
}
