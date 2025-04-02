class Goal {
  final int? id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String userId;

  Goal({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'userId': userId,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      savedAmount: map['savedAmount'],
      userId: map['userId'],
    );
  }
}