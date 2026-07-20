import 'package:flutter/material.dart';

class SelectionToolbar {
  static Widget buildContextMenu({
    required BuildContext context,
    required SelectableRegionState selectableRegionState,
    required String selectedText,
    required VoidCallback onHighlight,
    required VoidCallback onAddNote,
    required VoidCallback onAskAi,
  }) {
    // Obtain the endpoints of the selection to position the toolbar
    final selectionAnchors = selectableRegionState.contextMenuAnchors;
    final buttonItems = [
      ContextMenuButtonItem(
        label: 'Highlight',
        onPressed: () {
          selectableRegionState.hideToolbar();
          onHighlight();
        },
      ),
      ContextMenuButtonItem(
        label: 'Note',
        onPressed: () {
          selectableRegionState.hideToolbar();
          onAddNote();
        },
      ),
      ContextMenuButtonItem(
        label: 'Ask AI',
        onPressed: () {
          selectableRegionState.hideToolbar();
          onAskAi();
        },
      ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectionAnchors,
      buttonItems: buttonItems,
    );
  }
}
