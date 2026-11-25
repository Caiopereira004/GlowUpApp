class RoutineStep {
  final String id;
  final String step;
  final String active;
  final String note;
  bool done;

  RoutineStep({
    required this.id,
    required this.step,
    required this.active,
    required this.note,
    this.done = false,
  });

  RoutineStep copy() => RoutineStep(
        id: id,
        step: step,
        active: active,
        note: note,
        done: done,
      );
}

class WeekDayProgress {
  final String day;
  bool done;

  WeekDayProgress({required this.day, this.done = false});
}
