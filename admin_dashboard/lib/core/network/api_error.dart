/// Extracts a user-friendly message from Dio or other errors.
String extractApiErrorMessage(Object error) {
  if (error is Exception) {
    final msg = error.toString();
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }
    return msg;
  }
  return error.toString();
}
