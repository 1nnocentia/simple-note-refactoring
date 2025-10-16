class Notes {
  final int id;
  final String title;
  final String body;

  const Notes({
    required this.id,
    required this.title,
    required this.body,
  });

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }

  Notes copyWith({
    int? id,
    String? title,
    String? body,
  }) {
    return Notes(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notes &&
        other.id == id &&
        other.title == title &&
        other.body == body;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ body.hashCode;

  @override
  String toString() => 'Notes(id: $id, title: $title, body: $body)';
}