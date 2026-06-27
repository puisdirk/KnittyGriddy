class ChartOperationException {
  final String message;

  const ChartOperationException({required this.message});

  @override
  String toString() => message;
}