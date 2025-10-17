class PendingOperation {
  final String type;
  final Map<String, dynamic> note;

  const PendingOperation({required this.type, required this.note});

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      type: json['type'] as String,
      note: Map<String, dynamic>.from(json['note'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'note': note,
      };
}
