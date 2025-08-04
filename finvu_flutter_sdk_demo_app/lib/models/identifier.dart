class Identifier {
  final String fiType;
  final String type;
  final String category;
  final String? value;

  const Identifier({
    required this.fiType,
    required this.type,
    required this.category,
    this.value,
  });

  Identifier copyWith({
    String? fiType,
    String? type,
    String? category,
    String? value,
  }) {
    return Identifier(
      fiType: fiType ?? this.fiType,
      type: type ?? this.type,
      category: category ?? this.category,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Identifier &&
        other.fiType == fiType &&
        other.type == type &&
        other.category == category &&
        other.value == value;
  }

  @override
  int get hashCode {
    return fiType.hashCode ^ type.hashCode ^ category.hashCode ^ value.hashCode;
  }
}

typedef InputDialogResolver = Function(String value);
