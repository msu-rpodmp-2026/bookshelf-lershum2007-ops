import 'book.dart';

class PaperBook extends Book with Borrowable, Loggable {
  final String shelfLocation;

  PaperBook({
    required super.title,
    required super.author,
    this.shelfLocation = 'A1',
    super.year,
    super.pages,
    super.genres,
    super.status,
  });

  @override
  String describe() => '${super.describe()} [Бумажная, полка: $shelfLocation]';
}
