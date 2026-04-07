
class UndoRedoManager<T> {
  final List<T> _undoStack = [];
  final List<T> _redoStack = [];
  final int? maxItems;

  UndoRedoManager({this.maxItems});

  void store(T state) {
    _undoStack.add(state);
    _redoStack.clear();

    // limit size
    if (maxItems != null && _undoStack.length > maxItems!) {
      _undoStack.removeAt(0);
    }
  }

  void dispose() {
    _undoStack.clear();
    _redoStack.clear();
  }

  bool canUndo() => _undoStack.length > 1;
  bool canRedo() => _redoStack.isNotEmpty;

  T? undo() {
    if (canUndo()) {
      final undoneState = _undoStack.removeLast();
      _redoStack.add(undoneState);
      return _undoStack.isEmpty ? null : _undoStack.last;
    }
    return null;
  }

  T? redo() {
    if (canRedo()) {
      final redoneState = _redoStack.removeLast();
      _undoStack.add(redoneState);
      return redoneState;
    }
    return null;
  }
}