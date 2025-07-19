class Completion {
  int? id;
  int habitId;
  int completionDate;
  String? notes; // New field for notes

  Completion({
    this.id,
    required this.habitId,
    required this.completionDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completionDate': completionDate,
      'notes': notes,
    };
  }

  factory Completion.fromMap(Map<String, dynamic> map) {
    return Completion(
      id: map['id'],
      habitId: map['habitId'],
      completionDate: map['completionDate'],
      notes: map['notes'],
    );
  }
}