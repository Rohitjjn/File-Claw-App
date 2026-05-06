# Developer Diary

## October 25, 2023 - Version 1.0.0+1 Updates

- **Added Permissions on Startup:** Updated `HomeScreen` to request storage permissions when the app first opens.
- **Added Pinch-to-Zoom for Previews:** Added `InteractiveViewer` wrapper to `TextPreview`, `MarkdownPreview`, and `CodePreview` so that users can zoom in and out of the text/code easily.
- **Enhanced Editor Toolbar:** Added Copy, Cut, Paste, and Select All buttons to the `EditorScreen` toolbar for better rich editing functionality.
- **Added Code Auto-formatting:** Added an auto-format button in the `EditorScreen` toolbar. This feature normalizes indentation (tabs/spaces) according to bracket/brace matching, making syntax editing easier.
- **HTML Browser Preview:** Added an option in `FilePreviewScreen`'s AppBar menu to "Preview in Browser" when opening an `.html` file.
- **Enabled Text Selection in Code Viewer:** Enclosed the `HighlightView` in `CodePreview` within a `SelectableRegion` to allow text selection and copying of code blocks.
