class CustomException implements Exception {
  String _message = 'CustomException: ';

  CustomException(message) {
    _message += message;
  }

  @override
  String toString() {
    return _message;
  }
}

void main() {
  throwException();
}

throwException() {
  throw new CustomException('Mi error ocurrió');
}
