import 'package:path/path.dart' as p;

void main() {
  // Создаем путь к файлу (как будто мы в папке data)
  final path = p.join('data', 'library.json');

  print('--- Демонстрация работы пакета path ---');
  print('1. p.join:      $path');
  print('2. p.basename:  ${p.basename(path)}');
  print('3. p.extension: ${p.extension(path)}');
  print('4. p.dirname:   ${p.dirname(path)}');
  print('5. p.absolute:  ${p.absolute(path)}');
  print('---------------------------------------');
}
