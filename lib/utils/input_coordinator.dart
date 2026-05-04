class InputCoordinator {
  bool _isProcessing = false;
  final Duration _inputCooldown = const Duration(milliseconds: 100);

  Future<bool> tryProcessInput(Future<void> Function() action) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    try {
      await action();
      await Future.delayed(_inputCooldown);
    } finally {
      _isProcessing = false;
    }

    return true;
  }

  bool get isProcessing => _isProcessing;
}
