// Repository to fetch student grades. Replace with Firebase later.

class SubjectGrade {
  final String subjectName;
  final String teacherName;
  final double averageGrade;

  const SubjectGrade({
    required this.subjectName,
    required this.teacherName,
    required this.averageGrade,
  });
}

class GradesRepository {
  // In the future, replace this with a Firebase query and return real data.
  static Future<List<SubjectGrade>> fetchGrades() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const [
      SubjectGrade(
        subjectName: 'Mathematics',
        teacherName: 'Ms. Sarah Johnson',
        averageGrade: 75.5,
      ),
      SubjectGrade(
        subjectName: 'English Language',
        teacherName: 'Mr. David Wilson',
        averageGrade: 71.2,
      ),
      SubjectGrade(
        subjectName: 'Science',
        teacherName: 'Dr. Emily Chen',
        averageGrade: 79.8,
      ),
    ];
  }
}
