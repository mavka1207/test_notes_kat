# Secure Notes

A simple and elegant Flutter application for creating, editing, and managing notes with local database storage.

## Features

- ✏️ **Create & Edit Notes** – Easily add new notes or modify existing ones
- 🗑️ **Delete Notes** – Remove individual notes or clear all notes at once
- 📱 **Material Design 3** – Modern UI with smooth navigation
- 💾 **Local Storage** – Notes are stored securely in a local SQLite database
- 📅 **Smart Date Formatting** – Shows time for today's notes and full dates for older ones
- 🎯 **Clean UI** – Minimal, user-friendly interface

## Getting Started

### Prerequisites

- Flutter SDK 3.11.0 or higher
- Dart SDK
- An iOS or Android device/emulator

### Run the app

   ```bash
   flutter run
   ```

## Usage

### Adding a Note

Tap the floating action button (+) in the bottom-right corner to create a new note. Enter a title and body, then tap "Add note".

### Editing a Note

Tap any note in the list to open it for editing. Make your changes and tap "Save changes".

### Deleting Notes

- **Delete one note:** Open the note and tap the delete icon in the app bar
- **Delete all notes:** Tap the delete icon in the main screen's app bar and confirm

## Project Structure

lib/
├── main.dart              # Main app file with all screens and logic
packages/
└── note/                  # Local package for database and data models

## Date Format

Notes display dates in a smart way:

- **Today's notes:** Show only the time (e.g., `14:38`)
- **Older notes:** Show the full date (e.g., `2026-03-04`)

## Dependencies

- **flutter** – UI framework
- **intl** – Date and time formatting
- **note** – Local package for SQLite notes storage (included in this repository)
- **cupertino_icons** – iOS-style icons

## Technical Details

- **Database:** SQLite (via the local note package)
- **State Management:** StatefulWidget
- **Navigation:** Material Design navigation

## Supported Platforms

- ✅ iOS
- ✅ Android
