enum FormulaFunction {
  linelength(insert: 'linelength(', signature: 'linelength(line)'),
  cos(insert: 'cos(', signature: 'cos(angle)'),
  acos(insert: 'acos(', signature: 'acos(angle)'),
  sin(insert: 'sin(', signature: 'sin(angle)'),
  asin(insert: 'asin(', signature: 'asin(angle)'),
  tan(insert: 'tan(', signature: 'tan(angle)'),
  atan(insert: 'atan(', signature: 'atan(angle)'),
  exp(insert: 'exp(', signature: 'exp(num)'),
  log(insert: 'log(', signature: 'log(num)'),
  sqrt(insert: 'sqrt(', signature: 'sqrt(num)'),
  pow(insert: 'pow(', signature: 'pow(num)'),
  abs(insert: 'abs(', signature: 'abs(num)'),
  ceil(insert: 'ceil(', signature: 'ceil(num)'),
  floor(insert: 'floor(', signature: 'floor(num)'),
  round(insert: 'round(', signature: 'round(num)'),
  toRadians(insert: 'toRadians(', signature: 'toRadians(angle)'),
  toDegrees(insert: 'toDegrees(', signature: 'toDegrees(angle)'),

  atan2(insert: 'atan2', signature: 'atan2(num, num)'),
  max(insert: 'max(', signature: 'max(num, num)'),
  min(insert: 'min(', signature: 'min(num, num)'),
  power(insert: 'power(', signature: 'power(num, exp)');

  final String insert;
  final String signature;

  const FormulaFunction({
    required this.insert,
    required this.signature,
  });

}