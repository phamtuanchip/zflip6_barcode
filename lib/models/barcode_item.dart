/// A single stored barcode entry.
class BarcodeItem {
  final int? id;
  final String value;
  final String format;
  String label;
  final DateTime createdAt;

  BarcodeItem({
    this.id,
    required this.value,
    required this.format,
    required this.label,
    required this.createdAt,
  });

  // ── Serialisation ────────────────────────────────────────────────────────────

  factory BarcodeItem.fromMap(Map<String, dynamic> map) {
    return BarcodeItem(
      id: map['id'] as int?,
      value: map['value'] as String,
      format: map['format'] as String,
      label: map['label'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'value': value,
      'format': format,
      'label': label,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  BarcodeItem copyWith({
    int? id,
    String? value,
    String? format,
    String? label,
    DateTime? createdAt,
  }) {
    return BarcodeItem(
      id: id ?? this.id,
      value: value ?? this.value,
      format: format ?? this.format,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// A display-friendly short representation of the value (max 40 chars).
  String get shortValue {
    if (value.length <= 40) return value;
    return '${value.substring(0, 37)}…';
  }

  /// Returns the label if non-empty, otherwise [shortValue].
  String get displayName => label.trim().isNotEmpty ? label.trim() : shortValue;

  @override
  String toString() =>
      'BarcodeItem(id: $id, format: $format, label: $label, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
