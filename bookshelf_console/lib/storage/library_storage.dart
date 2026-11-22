import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/book.dart';
import '../models/book_json.dart';

/// Задание 5. Собственное исключение: номер строки CSV и описание проблемы.
class LibraryFormatException implements Exception {
  LibraryFormatException(this.message, this.line);

  final String message;
  final int line;

  @override
  String toString() => 'Ошибка в строке $line: $message';
}

/// Задания 3-4. Единственное место программы, где происходит работа с диском.
class LibraryStorage {
  const LibraryStorage(this.directory);

  final String directory;

  String get jsonPath => p.join(directory, 'library.json');
  String get csvPath => p.join(directory, 'library.csv');

  static const List<String> _header = <String>[
    'title',
    'author',
    'year',
    'pages',
    'genres',
    'status',
    'rating',
  ];

  Future<void> _ensureDir() async {
    final Directory dir = Directory(directory);
    if (!await dir.exists()) await dir.create(recursive: true);
  }

  /// Повреждённый файл не удаляем, а откладываем в .bak.
  Future<void> _toBak(File file) async {
    final String bak = '$jsonPath.bak';
    final File bakFile = File(bak);
    if (await bakFile.exists()) await bakFile.delete();
    await file.rename(bak);
    stderr.writeln('Повреждённый файл сохранён как $bak');
  }

  /// Чтение JSON. Нет файла -> пустой список.
  /// Битый JSON -> .bak + FormatException наверх, её поймает main.
  Future<List<Book>> load() async {
    final File file = File(jsonPath);
    if (!await file.exists()) {
      await _ensureDir();
      return <Book>[];
    }

    final String text = await file.readAsString(encoding: utf8);
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException catch (e) {
      await _toBak(file);
      throw FormatException('library.json повреждён: ${e.message}');
    }
    if (decoded is! List) {
      await _toBak(file);
      throw const FormatException('ожидался JSON-массив книг');
    }

    final List<Book> books = <Book>[];
    int skipped = 0;
    for (final Object? item in decoded) {
      if (item is! Map<String, dynamic>) {
        skipped++;
        continue;
      }
      try {
        books.add(bookFromJson(item));
      } on TypeError {
        // Данные из файла недоверенные: запись с неверным типом поля пропускаем,
        // но программа продолжает работать (требование задания 2).
        skipped++;
        stderr.writeln('Запись с некорректным типом поля пропущена');
      } on ArgumentError {
        skipped++;
        stderr.writeln('Запись с недопустимым значением поля пропущена');
      }
    }
    if (skipped > 0) stderr.writeln('Пропущено записей: $skipped');
    return books;
  }

  /// Запись с отступами через временный файл.
  Future<void> save(List<Book> books) async {
    await _ensureDir();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String text = encoder.convert(
      books.map((Book b) => b.toJson()).toList(),
    );
    final File tmp = File('$jsonPath.tmp');
    await tmp.writeAsString(text, encoding: utf8, flush: true);
    await tmp.rename(jsonPath);
  }

  /// Задание 4. Выгрузка в CSV.
  Future<void> exportCsv(List<Book> books) async {
    await _ensureDir();
    final StringBuffer buf = StringBuffer()
      ..write('\uFEFF') // BOM: чтобы Excel показал кириллицу
      ..writeln(_header.join(';'));
    for (final Book b in books) {
      buf.writeln(
        <String>[
          b.title,
          b.author,
          b.year.toString(),
          b.pages.toString(),
          b.genres.join(','),
          b.status.name,
          b.rating?.toStringAsFixed(1) ?? '',
        ].map(_escape).join(';'),
      );
    }
    await File(
      csvPath,
    ).writeAsString(buf.toString(), encoding: utf8, flush: true);
  }

  /// Задание 4. Импорт. strict: true — пробросить ошибку наверх (задание 5).
  Future<List<Book>> importCsv({bool strict = false}) async {
    final String content = await File(csvPath).readAsString(encoding: utf8);
    final List<String> lines = const LineSplitter().convert(content);
    final List<Book> books = <Book>[];
    int skipped = 0;
    bool headerSeen = false;
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i].replaceFirst('\uFEFF', '').trim();
      if (line.isEmpty) continue;
      if (!headerSeen) {
        headerSeen = true;
        continue;
      }
      try {
        books.add(_bookFromFields(_splitLine(line), i + 1));
      } on LibraryFormatException catch (e) {
        if (strict) rethrow;
        skipped++;
        stderr.writeln(e.toString());
      }
    }
    if (skipped > 0) stderr.writeln('Пропущено строк: $skipped');
    return books;
  }

  /// Копия с меткой времени, храним последние keep копий.
  Future<bool> backup({int keep = 5}) async {
    final File file = File(jsonPath);
    if (!await file.exists()) return false;
    final String stamp = DateTime.now()
        .toIso8601String()
        .split('.')
        .first
        .replaceAll(':', '-');
    await file.copy(p.join(directory, 'library_$stamp.json'));

    final List<String> copies = <String>[];
    await for (final FileSystemEntity e in Directory(directory).list()) {
      final String name = p.basename(e.path);
      if (e is File && name.startsWith('library_') && name.endsWith('.json')) {
        copies.add(name);
      }
    }
    copies.sort();
    while (copies.length > keep) {
      await File(p.join(directory, copies.removeAt(0))).delete();
    }
    return true;
  }

  Book _bookFromFields(List<String> f, int lineNo) {
    if (f.length != _header.length) {
      throw LibraryFormatException(
        'ожидалось ${_header.length} полей, получено ${f.length}',
        lineNo,
      );
    }
    if (f[0].trim().isEmpty) {
      throw LibraryFormatException('пустое название', lineNo);
    }

    // Парсим поля до Book.fromJson, чтобы проверить значения
    final String title = f[0].trim();
    final String author = f[1].trim();
    final int? year = int.tryParse(f[2].trim());
    final int? pages = int.tryParse(f[3].trim());
    final Set<String> genres = f[4]
        .split(',')
        .map((String g) => g.trim())
        .where((String g) => g.isNotEmpty)
        .toSet();
    final String statusStr = f[5].trim();
    final double? rating = f[6].trim().isEmpty
        ? null
        : double.tryParse(f[6].trim());

    // Проверки значений — если не проходят, бросаем LibraryFormatException
    // с номером строки, чтобы строгий импорт отменялся
    if (year == null || year < 1000 || year > 2100) {
      throw LibraryFormatException(
        'год должен быть целым числом от 1000 до 2100',
        lineNo,
      );
    }
    if (pages == null || pages <= 0) {
      throw LibraryFormatException(
        'количество страниц должно быть целым числом больше нуля',
        lineNo,
      );
    }
    if (rating != null && (rating < 0 || rating > 5)) {
      throw LibraryFormatException(
        'оценка должна быть числом от 0 до 5',
        lineNo,
      );
    }

    // Теперь безопасно создаём книгу через Book.fromJson
    return Book.fromJson(<String, dynamic>{
      'title': title,
      'author': author.isEmpty ? null : author,
      'year': year,
      'pages': pages,
      'genres': genres.toList(),
      'status': statusStr,
      'rating': rating,
    });
  }

  static String _escape(String value) {
    final bool need =
        value.contains(';') || value.contains('"') || value.contains('\n');
    return need ? '"${value.replaceAll('"', '""')}"' : value;
  }

  static List<String> _splitLine(String line) {
    final List<String> fields = <String>[];
    final StringBuffer cur = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final String ch = line[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            cur.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          cur.write(ch);
        }
      } else if (ch == '"') {
        inQuotes = true;
      } else if (ch == ';') {
        fields.add(cur.toString());
        cur.clear();
      } else {
        cur.write(ch);
      }
    }
    fields.add(cur.toString());
    return fields;
  }
}
