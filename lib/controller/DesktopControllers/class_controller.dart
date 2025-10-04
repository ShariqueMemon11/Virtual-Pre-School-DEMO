// controllers/class_controller.dart
import '../../Model/classmodal.dart';

class ClassController {
  final List<ClassModel> classes = [
    ClassModel(
      name: 'Playgroup A',
      teacher: 'Miss Sana',
      capacity: 20,
      students: 18,
    ),
    ClassModel(
      name: 'Playgroup B',
      teacher: 'Miss Hira',
      capacity: 20,
      students: 19,
    ),
    // add initial classes here
  ];

  void addClass(ClassModel newClass) {
    classes.add(newClass);
  }
}
