# Product Requirements Document (PRD) - Files Claw

## 1. Overview
Files Claw is a local-only Flutter application designed for offline file previewing and editing. It focuses on a clean, Claude-styled user interface and prioritizes privacy and speed by not requiring any network connection.

## 2. Key Features
- **File Preview:** Support for Markdown, Code (with syntax highlighting), Text, Images, PDFs, DOCX, and CSV files.
- **Archive Viewing:** Explore the contents of ZIP, TAR, GZ, and TGZ archives.
- **File Editing:** Edit small to medium-sized text-based files (up to 10MB) with auto-save functionality.
- **History Management:** Keeps track of recently opened files for quick access.
- **Local-Only:** All operations and data persistence happen strictly on the device.
- **Quick Actions:** Android shortcuts for accessing settings, history, and the last opened file.
- **Notifications:** Informative notifications when files are opened or saved.

## 3. UI/UX Principles
- **Claude Aesthetic:** Clean, minimal design using a terracotta orange accent (`#D97757`).
- **Feature-First Navigation:** Sidebar drawer for quick access to history.
- **Accessibility:** Readable typography (Inter and Roboto Mono) with adjustable font scales.

## 4. Technical Constraints
- **Platform:** Android (Initial target).
- **Architecture:** Feature-based slicing with Riverpod for state management.
- **Persistence:** JSON file-based storage for app configuration and history.
- **No Cloud Dependencies:** No Firebase, Supabase, or external APIs.

## 5. Changelog Summary
- **v1.0.0:** Initial release with basic preview and edit support.
- **v1.0.0+1:** UI enhancements, Markdown editing, Quick Actions, and internal optimizations.
