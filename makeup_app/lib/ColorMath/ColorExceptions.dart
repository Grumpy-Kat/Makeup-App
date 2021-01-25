// Credit: https://github.com/gtaylor/python-colormath/

class InvalidIlluminantException implements Exception {
  String illuminant;

  InvalidIlluminantException(this.illuminant);

  @override
  String toString() {
    return 'Invalid illuminant specified: $illuminant';
  }
}

class InvalidObserverException implements Exception {
    String observer;

    InvalidObserverException(this.observer);

    @override
    String toString() {
        return 'Invalid observer angle specified: $observer';
    }
}