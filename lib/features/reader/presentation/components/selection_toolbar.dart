import 'package:flutter/material.dart';

class SelectionToolbar {
  static Widget buildContextMenu({
    required BuildContext context,
    required EditableTextState editableTextState,
    required void Function(String selectedText, int occurrenceIndex) onHighlight,
    required void Function(String selectedText) onAddNote,
    required void Function(String selectedText) onAskAi,
  }) {
    final selectionAnchors = editableTextState.contextMenuAnchors;
    final textEditingValue = editableTextState.textEditingValue;
    final selectedText = textEditingValue.selection.textInside(textEditingValue.text);

    if (selectedText.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate the occurrence index of the selected text
    final plainText = textEditingValue.text;
    final selectionStart = textEditingValue.selection.start;

    int occurrenceIndex = 0;
    int searchIndex = 0;
    while (true) {
      final found = plainText.indexOf(selectedText, searchIndex);
      if (found == -1 || found >= selectionStart) break;
      occurrenceIndex++;
      searchIndex = found + selectedText.length;
    }

    final buttonItems = [
      ContextMenuButtonItem(
        label: 'Highlight',
        onPressed: () {
          editableTextState.hideToolbar();
          onHighlight(selectedText, occurrenceIndex);
        },
      ),
      ContextMenuButtonItem(
        label: 'Note',
        onPressed: () {
          editableTextState.hideToolbar();
          onAddNote(selectedText);
        },
      ),
      ContextMenuButtonItem(
        label: 'Ask AI',
        onPressed: () {
          editableTextState.hideToolbar();
          onAskAi(selectedText);
        },
      ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectionAnchors,
      buttonItems: buttonItems,
    );
  }
}
