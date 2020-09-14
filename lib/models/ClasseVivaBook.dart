import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaBook.g.dart';

@HiveType(typeId: 14)
class ClasseVivaBook
{
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final List<String> categories;

  @HiveField(3)
  final String publisher;

  @HiveField(4)
  final String isbn;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final bool mustBuy;

  @HiveField(7)
  final bool isInUse;

  @HiveField(8)
  final bool isSuggested;

  ClasseVivaBook({
    @required this.title,
    @required this.description,
    @required this.categories,
    @required this.publisher,
    @required this.isbn,
    @required this.price,
    @required this.mustBuy,
    @required this.isInUse,
    @required this.isSuggested,
  });
}