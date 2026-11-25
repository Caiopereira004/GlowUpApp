class LessonModel {
  final String module;
  final String title;
  final String desc;
  final String duration;
  final List<int> gradientColors;
  final List<String> tips;
  bool favorite;

  LessonModel({
    required this.module,
    required this.title,
    required this.desc,
    required this.duration,
    required this.gradientColors,
    required this.tips,
    this.favorite = false,
  });
}
