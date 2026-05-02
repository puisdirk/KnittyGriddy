class CellAddress implements Comparable<CellAddress> {
  final int column;
  final int row;

  const CellAddress({
    required this.column,
    required this.row,
  });

  Map<String, Object> toJson() {
    return {
      'column': column,
      'row': row,
    };
  }

  static CellAddress fromJson(Map<String, dynamic> json) {
    return CellAddress(
      column: json['column'] as int, 
      row: json['row'] as int,
    );
  }

  @override
  int get hashCode => column.hashCode ^ row.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is CellAddress &&
      column == other.column &&
      row == other.row;
      
  @override
  int compareTo(CellAddress other) {
    return column.compareTo(other.column);
  }
}
