class DrawingOperationException {
  final String message;

  const DrawingOperationException({required this.message});

  @override
  String toString() => message;
}