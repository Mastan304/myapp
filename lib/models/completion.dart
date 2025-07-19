class Completion {
  int? id;
  int habitId;
  int completionDate;

  Completion({
    this.id,
    required this.habitId,
    required this.completionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completionDate': completionDate,
    };
  }

  factory Completion.fromMap(Map<String, dynamic> map) {
    return Completion(
      id: map['id'],
      habitId: map['habitId'],
      completionDate: map['completionDate'],
    );
  }
}