import 'package:bookshelf_console/models/book.dart';
import 'package:bookshelf_console/models/reading_status.dart';
import 'package:test/test.dart';

void main() {
  test('Book переживает round-trip toJson -> fromJson', () {
    final Book original = Book(
      title: 'Дюна',
      author: 'Ф. Герберт',
      year: 1965,
      pages: 688,
      genres: <String>{'фантастика'},
      status: ReadingStatus.finished,
      rating: 4.5,
    );
    final Book restored = Book.fromJson(original.toJson());
    expect(restored.title, original.title);
    expect(restored.author, original.author);
    expect(restored.year, original.year);
    expect(restored.pages, original.pages);
    expect(restored.genres, original.genres);
    expect(restored.status, original.status);
    expect(restored.rating, original.rating);
  });

  test('fromJson не падает на испорченных полях', () {
    final Book book = Book.fromJson(<String, dynamic>{
      'title': null,
      'author': null,
      'year': 2024.0,
      'pages': null,
      'genres': <String>['роман'],
      'status': 'finished',
    });
    expect(book.title, 'Без названия');
    expect(book.author, 'Автор неизвестен');
    expect(book.year, 2024);
    expect(book.pages, 0);
  });
}
