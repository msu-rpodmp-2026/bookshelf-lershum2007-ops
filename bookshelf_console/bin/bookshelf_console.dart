import 'dart:io';
import 'dart:convert';
import 'package:bookshelf_console/models/book.dart';
import 'package:bookshelf_console/models/audio_book.dart';
import 'package:bookshelf_console/models/ebook.dart';
import 'package:bookshelf_console/models/paper_book.dart';
import 'package:bookshelf_console/models/library.dart';
import 'package:bookshelf_console/models/reading_status.dart';

void out(Object? s) {
  stdout.add(utf8.encode('$s\n'));
}

void outWrite(String s) {
  stdout.add(utf8.encode(s));
}

void printHeader(String text) {
  out('\n------------------------------------');
  out('  $text');
  out('------------------------------------');
}

void printMenu() {
  out('\n=== Каталог BookShelf (ООП) ===');
  out('1. Показать весь каталог');
  out('2. Поиск (название/автор/жанр)');
  out('3. Показать только прочитанные');
  out('4. Сортировка по названию');
  out('5. Статистика по жанрам');
  out('6. Выдать бумажную книгу');
  out('7. Проверка == и copyWith (Задание 6)'); // <-- НОВЫЙ ПУНКТ
  out('0. Выход');
  outWrite('Выберите действие > ');
}

void main() {
  final Library<Book> lib = Library<Book>();

  lib.add(
    PaperBook(
      title: 'Война и мир',
      author: 'Л. Н. Толстой',
      year: 1869,
      pages: 1225,
      genres: {'роман', 'классика'},
      shelfLocation: 'A2',
      status: ReadingStatus.finished,
    ),
  );

  lib.add(
    EBook(
      title: '1984',
      author: 'Дж. Оруэлл',
      year: 1949,
      pages: 320,
      format: 'PDF',
      sizeMb: 5.2,
      genres: {'антиутопия'},
    ),
  );

  lib.add(
    AudioBook(
      title: 'Дюна',
      author: 'Ф. Герберт',
      year: 1965,
      duration: Duration(minutes: 120),
      narrator: 'Иван Иванов',
      genres: {'фантастика'},
    ),
  );

  lib.add(
    Book(
      title: 'Основы Dart',
      author: 'С. Чернышев',
      year: 2024,
      pages: 521,
      genres: {'учебник'},
    ),
  );

  var running = true;
  while (running) {
    printMenu(); // Вызов функции меню

    final command = (stdin.readLineSync(encoding: utf8) ?? '').trim();

    switch (command) {
      case '1':
        printHeader('Весь каталог (${lib.count} шт.)');
        for (final b in lib.items) {
          out(' ${b.describe()}');
        }
        break;

      case '2':
        outWrite('\nВведите запрос для поиска: ');
        final q = stdin.readLineSync(encoding: utf8) ?? '';
        final results = lib.search(q).toList();

        if (results.isEmpty) {
          out('\n[!] По запросу «$q» ничего не найдено.');
        } else {
          printHeader('Результаты поиска по «$q» (${results.length} шт.)');
          for (final b in results) {
            out(' ${b.describe()}');
          }
        }
        break;

      case '3':
        final readBooks = lib
            .where((b) => b.status == ReadingStatus.finished)
            .toList();
        printHeader('Прочитанные книги (${readBooks.length} шт.)');
        if (readBooks.isEmpty) {
          out(' Пока нет прочитанных книг.');
        } else {
          for (final b in readBooks) {
            out(' ${b.describe()}');
          }
        }
        break;

      case '4':
        printHeader('Сортировка по названию');
        final sorted = lib.items.toList()..sort();
        for (final b in sorted) {
          out(' ${b.title} — ${b.author}');
        }
        break;

      case '5':
        printHeader('Статистика по жанрам');
        final stats = lib.countByGenre();
        if (stats.isEmpty) {
          out(' Жанры не указаны.');
        } else {
          stats.forEach((genre, count) {
            out(' Жанр «$genre»: $count кн.');
          });
        }
        break;

      case '6':
        printHeader('Выдача бумажной книги');
        var issued = false;
        for (final b in lib.items) {
          if (b is PaperBook && !b.isBorrowed) {
            b.borrow(14);
            issued = true;
            break;
          }
        }
        if (!issued) out(' Нет доступных бумажных книг.');
        break;

      // НОВЫЙ БЛОК ДЛЯ ПУНКТА 7
      case '7':
        printHeader('Демонстрация Задания 6');

        final book1 = Book(title: 'Азбука', author: 'Тест', year: 2020);
        final book2 = Book(title: 'Азбука', author: 'Тест', year: 2020);

        out('Созданы две одинаковые книги (Азбука).');
        out('book1 == book2: ${book1 == book2}');
        out('hashCode равны: ${book1.hashCode == book2.hashCode}');

        final setTest = {book1, book2};
        out('Размер Set (должен быть 1): ${setTest.length}');

        out('\nПроверка copyWith:');
        final copy = book1.copyWith(newYear: 2025);
        out('Оригинал год: ${book1.year}, Копия год: ${copy.year}');
        break;

      case '0':
        running = false;
        out('\nРабота программы завершена. До свидания!');
        break;

      default:
        out('\n[!] Неизвестная команда. Попробуйте снова.');
    }
  }
}
