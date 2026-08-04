class PatternOperationException {
  final String message;

  const PatternOperationException({required this.message});

  @override
  String toString() => message;
}