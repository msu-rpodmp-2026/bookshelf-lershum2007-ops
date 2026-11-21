import 'dart:convert';
import 'dart:io';

import 'package:bookshelf_console/models/audio_book.dart';
import 'package:bookshelf_console/models/book.dart';
import 'package:bookshelf_console/models/ebook.dart';
import 'package:bookshelf_console/models/library.dart';
import 'package:bookshelf_console/models/paper_book.dart';
import 'package:bookshelf_console/models/reading_status.dart';
import 'package:bookshelf_console/storage/library_storage.dart';
import 'package:path/path.dart' as p;
import 'package:bookshelf_console/models/book_json.dart';

// ===== Вспомогательные функции вывода в UTF-8 (из ЛР №1-2) =====

void out(Object? s) {
  stdout.add(utf8.encode('$s\n'));
}

void outWrite(String s) {
  stdout.add(utf8.encode(s));
}

void printHeader(String text) {
  out('\n────────────────────────────────────');
  out('  $text');
  out('────────────────────────────────────');
}

Future<void> main(List<String> args) async {
  final Library<Book> lib = Library<Book>();

  // Стартовое наполнение каталога (используется только при первом запуске).
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

  // ===== Задание 6: аргументы командной строки =====
  String directory = 'data';
  bool exportOnly = false;
  bool importOnly = false;
  bool statsOnly = false;
  for (final String arg in args) {
    switch (arg) {
      case '--help':
        out(
          'Использование: dart run [каталог] '
          '[--export-csv] [--import-csv] [--stats] [--help]',
        );
        return;
      case '--export-csv':
        exportOnly = true;
        break;
      case '--import-csv':
        importOnly = true;
        break;
      case '--stats':
        statsOnly = true;
        break;
      default:
        if (arg.startsWith('--')) {
          out('Неизвестный ключ: $arg');
          return;
        }
        directory = arg;
    }
  }

  final LibraryStorage storage = LibraryStorage(directory);

  // ===== Задание 1: функции пакета path =====
  out('Каталог данных: ${p.absolute(directory)}');
  out('join:      ${p.join(directory, 'library.json')}');
  out('basename:  ${p.basename(storage.jsonPath)}');
  out('extension: ${p.extension(storage.jsonPath)}');
  out('dirname:   ${p.dirname(storage.jsonPath)}');

  // ===== Задание 5: загрузка с раздельными ветвями ошибок =====
  try {
    final bool fileExisted = await File(storage.jsonPath).exists();
    final List<Book> loaded = await storage.load();
    if (!fileExisted) {
      await storage.save(
        lib.items,
      ); // первый запуск: сохраняем стартовый каталог
      out('Файл не найден — создан каталог (${lib.count} записей).');
    } else {
      lib.replaceAll(loaded);
      out('Загружено записей: ${lib.count}');
    }
  } on PathNotFoundException {
    out('Файл каталога не найден — создан новый пустой каталог.');
  } on FormatException catch (e) {
    out('Файл повреждён: ${e.message}');
  } on FileSystemException catch (e) {
    out('Ошибка файловой системы: ${e.message} (код ${e.osError?.errorCode})');
    rethrow;
  } finally {
    out('Загрузка завершена.');
  }

  if (statsOnly) {
    printFileStats(lib.items);
    return;
  }
  if (exportOnly) {
    await storage.exportCsv(lib.items);
    out('Экспортировано в ${p.absolute(storage.csvPath)}');
    return;
  }
  if (importOnly) {
    try {
      lib.replaceAll(await storage.importCsv(strict: true));
      await storage.save(lib.items);
      out('Импортировано записей: ${lib.count}');
    } on PathNotFoundException {
      out('Файл library.csv не найден. Сначала сделай экспорт.');
    } on LibraryFormatException catch (e) {
      out(e.toString());
    }
    return;
  }

  // ===== Задание 7: меню с автосохранением =====
  bool running = true;
  while (running) {
    out('\n=== Каталог BookShelf ===');
    out('1.  Показать весь каталог');
    out('2.  Поиск (название/автор/жанр)');
    out('3.  Показать только прочитанные');
    out('4.  Сортировка по названию');
    out('5.  Статистика по жанрам');
    out('6.  Выдать бумажную книгу');
    out('7.  Добавить книгу');
    out('8.  Удалить книгу');
    out('9.  Изменить статус и оценку');
    out('10. Экспорт в CSV');
    out('11. Импорт из CSV');
    out('12. Резервная копия');
    out('13. Проверка == и copyWith');
    out('0.  Выход');
    outWrite('Выберите действие > ');

    final String command = (stdin.readLineSync(encoding: utf8) ?? '').trim();

    switch (command) {
      case '1':
        printHeader('Весь каталог (${lib.count} шт.)');
        printBooks(lib.items);
        break;

      case '2':
        outWrite('\nВведите запрос для поиска: ');
        final String q = stdin.readLineSync(encoding: utf8) ?? '';
        final List<Book> results = lib.search(q).toList();
        if (results.isEmpty) {
          out('\n[!] По запросу «$q» ничего не найдено.');
        } else {
          printHeader('Результаты поиска по «$q» (${results.length} шт.)');
          printBooks(results);
        }
        break;

      case '3':
        final List<Book> readBooks = lib
            .where((Book b) => b.status == ReadingStatus.finished)
            .toList();
        printHeader('Прочитанные книги (${readBooks.length} шт.)');
        printBooks(readBooks);
        break;

      case '4':
        printHeader('Сортировка по названию');
        final List<Book> sorted = lib.items.toList()..sort();
        printBooks(sorted);
        break;

      case '5':
        printHeader('Статистика по жанрам');
        final Map<String, int> stats = lib.countByGenre();
        if (stats.isEmpty) {
          out(' Жанры не указаны.');
        } else {
          stats.forEach((String genre, int count) {
            out(' Жанр «$genre»: $count кн.');
          });
        }
        break;

      case '6':
        printHeader('Выдача бумажной книги');
        bool issued = false;
        for (final Book b in lib.items) {
          if (b is PaperBook && !b.isBorrowed) {
            b.borrow(14);
            issued = true;
            break;
          }
        }
        if (!issued) {
          out(' Нет доступных бумажных книг.');
        }
        break;

      case '7':
        printHeader('Добавление книги');
        outWrite('Название: ');
        final String title = (stdin.readLineSync(encoding: utf8) ?? '').trim();
        if (title.isEmpty) {
          out('Ошибка: название не может быть пустым.');
          break;
        }
        outWrite('Автор: ');
        final String author = (stdin.readLineSync(encoding: utf8) ?? '').trim();
        final int year = askInt('Год издания', min: 1000, max: 2100);
        final int pages = askInt('Количество страниц', min: 1);
        outWrite('Жанры через запятую: ');
        final Set<String> genres = (stdin.readLineSync(encoding: utf8) ?? '')
            .split(',')
            .map((String g) => g.trim())
            .where((String g) => g.isNotEmpty)
            .toSet();
        lib.add(
          Book(
            title: title,
            author: author.isEmpty ? 'Автор неизвестен' : author,
            year: year,
            pages: pages,
            genres: genres,
          ),
        );
        await saveLibrary(storage, lib); // автосохранение
        break;

      case '8':
        printHeader('Удаление книги');
        printBooks(lib.items);
        if (lib.count == 0) {
          break;
        }
        final int n = askInt('Номер книги', min: 1, max: lib.count);
        final Book target = lib.items[n - 1];
        out(
          lib.remove(target)
              ? 'Удалена: «${target.title}»'
              : 'Не удалось удалить книгу.',
        );
        await saveLibrary(storage, lib); // автосохранение
        break;

      case '9':
        printHeader('Изменение статуса и оценки');
        printBooks(lib.items);
        if (lib.count == 0) {
          break;
        }
        final int n = askInt('Номер книги', min: 1, max: lib.count);
        out('Статусы: planned / reading / finished / abandoned');
        outWrite('Новый статус (Enter — оставить прежний): ');
        final String statusInput = (stdin.readLineSync(encoding: utf8) ?? '')
            .trim();
        outWrite('Новая оценка 0–5 (Enter — оставить прежнюю): ');
        final String ratingInput = (stdin.readLineSync(encoding: utf8) ?? '')
            .trim();
        final double? newRating = double.tryParse(ratingInput);
        if (ratingInput.isNotEmpty &&
            (newRating == null || newRating < 0 || newRating > 5)) {
          out('Ошибка: оценка должна быть числом от 0 до 5.');
          break;
        }
        // Поля Book — final, поэтому меняем через copyWith и кладём копию обратно.
        final List<Book> items = lib.items.toList();
        // Копия через JSON сохраняет тип книги (PaperBook/EBook/AudioBook).
        final Map<String, dynamic> json = items[n - 1].toJson();
        if (statusInput.isNotEmpty) {
          json['status'] = ReadingStatus.fromName(statusInput).name;
        }
        if (newRating != null) {
          json['rating'] = newRating;
        }
        items[n - 1] = bookFromJson(json);
        lib.replaceAll(items);
        out('Обновлено: ${items[n - 1].describe()}');
        await saveLibrary(storage, lib); // автосохранение
        break;

      case '10':
        await storage.exportCsv(lib.items);
        out('Экспортировано в ${p.absolute(storage.csvPath)}');
        break;

            case '11':
        printHeader('Импорт из CSV');
        try {
          // Строгий режим: при любой некорректной строке исключение прилетает
          // ДО замены каталога, поэтому текущие книги не теряются.
          final List<Book> imported = await storage.importCsv(strict: true);
          // Каталог заменяется только после успешного разбора ВСЕГО файла.
          lib.replaceAll(imported);
          await saveLibrary(storage, lib);
          out('Импортировано записей: ${lib.count}');
        } on PathNotFoundException {
          out('Файл library.csv не найден. Сначала выполните экспорт (пункт 10).');
          out('Каталог не изменён.');
        } on LibraryFormatException catch (e) {
          out('Импорт отменён: $e');
          out('Каталог не изменён и не перезаписан.');
        }
        break;
      case '12':
        final bool ok = await storage.backup();
        out(
          ok
              ? 'Резервная копия создана в ${p.absolute(directory)}'
              : 'Нечего копировать: library.json ещё не создан.',
        );
        break;

      case '13':
        printHeader('Проверка == и copyWith (ЛР №3)');
        final Book book1 = Book(title: 'Азбука', author: 'Тест', year: 2020);
        final Book book2 = Book(title: 'Азбука', author: 'Тест', year: 2020);
        out('book1 == book2: ${book1 == book2}');
        out('hashCode равны: ${book1.hashCode == book2.hashCode}');
        final Set<Book> setTest = <Book>{book1, book2};
        out('Размер Set (должен быть 1): ${setTest.length}');
        final Book copy = book1.copyWith(newYear: 2025);
        out('Оригинал: ${book1.year}, копия: ${copy.year}');
        break;

      case '0':
        running = false;
        await saveLibrary(storage, lib);
        out(
          'Сохранено записей: ${lib.count}. '
          'Файл: ${p.absolute(storage.jsonPath)}',
        );
        out('Работа программы завершена. До свидания!');
        break;

      default:
        out('\n[!] Неизвестная команда. Попробуйте снова.');
    }
  }
}

// ===== Вспомогательные функции =====

/// Нумерованный вывод книг.
void printBooks(List<Book> books) {
  if (books.isEmpty) {
    out(' Каталог пуст.');
    return;
  }
  for (int i = 0; i < books.length; i++) {
    out(' ${i + 1}. ${books[i].describe()}');
  }
}

/// Безопасный ввод целого числа в диапазоне (цикл do-while из ЛР №2).
int askInt(String prompt, {int min = 0, int? max}) {
  int? value;
  do {
    outWrite('$prompt: ');
    value = int.tryParse((stdin.readLineSync(encoding: utf8) ?? '').trim());
    if (value == null || value < min || (max != null && value > max)) {
      out(
        'Нужно целое число '
        '${max == null ? 'не меньше $min' : 'от $min до $max'}.',
      );
      value = null;
    }
  } while (value == null);
  return value;
}

/// Задание 7. Автосохранение после каждого изменения каталога.
Future<void> saveLibrary(LibraryStorage storage, Library<Book> lib) async {
  try {
    await storage.save(lib.items);
    out('Каталог сохранён (${lib.count} записей).');
  } on FileSystemException catch (e) {
    out('Не удалось сохранить: ${e.message} (код ${e.osError?.errorCode})');
  }
}

/// Статистика для ключа --stats.
void printFileStats(List<Book> books) {
  out('Всего книг: ${books.length}');
  if (books.isEmpty) {
    return;
  }
  final int totalPages = books.fold<int>(0, (int s, Book b) => s + b.pages);
  out('Всего страниц: $totalPages');
  out('В среднем: ${(totalPages / books.length).toStringAsFixed(1)} стр.');
  out('Прочитано: ${books.where((Book b) => b.status.isDone).length}');
}
