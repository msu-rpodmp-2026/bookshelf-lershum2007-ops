import 'book.dart';

class EBook extends Book {
  final String format;
  final double sizeMb;

  EBook({
    required super.title,
    required super.author,
    required this.format,
    required this.sizeMb,
    super.year,
    super.pages,
    super.genres,
    super.status,
  });

  @override
  String describe() => '${super.describe()} [EBook, $format, $sizeMb МБ]';
}
