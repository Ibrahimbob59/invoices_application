# Invoice History App

## Overview

A Flutter mobile application for managing and tracking invoice history with a focus on local data storage and document management. The app allows users to maintain company records, create invoices with attachments, and perform OCR scanning of physical receipts. Built with Material 3 design principles and supports both light/dark themes with RTL language support for Arabic users.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture
- **Framework**: Flutter (Dart) with Material 3 design system
- **State Management**: Riverpod for reactive state management across the application
- **Architecture Pattern**: Clean Architecture with distinct layers (presentation, application, data, domain)
- **UI Design**: Material 3 components with responsive layout for phones and tablets
- **Theming**: Light/dark theme support with RTL layout for Arabic language support
- **Navigation**: Drawer/Sidebar navigation pattern with main sections (Home, Invoices, Insert New Company, Export/Import)

### Data Layer
- **Local Database**: SQLite via sqflite package for persistent local storage
- **Storage Strategy**: File paths stored in database rather than actual files to optimize storage
- **Data Models**: Company and Invoice entities with relationships
- **Database Operations**: CRUD operations for companies and invoices with search capabilities

### Document Processing
- **Camera Integration**: Camera package for capturing invoice photos
- **OCR Processing**: Google ML Kit Text Recognition for extracting text from scanned documents
- **Document Scanner**: Mobile scanner package for optimized document scanning
- **File Management**: File picker integration for attaching existing documents (images/PDFs)
- **Storage Approach**: Store file paths in database, actual files remain in device storage

### Business Logic
- **Company Management**: Create, search, and select companies with real-time filtering
- **Invoice Creation**: Form-based invoice entry with validation and attachment support
- **Search Functionality**: Real-time search-as-you-type for company selection
- **Data Export/Import**: Database backup and restore functionality for data portability

## External Dependencies

### Core Flutter Packages
- **sqflite**: Local SQLite database management
- **flutter_riverpod**: State management and dependency injection
- **riverpod_annotation** & **riverpod_generator**: Code generation for Riverpod providers
- **path_provider**: Access to device file system directories
- **path**: File path manipulation utilities

### Camera and Document Processing
- **camera**: Camera access for photo capture
- **mobile_scanner**: Optimized document scanning capabilities
- **google_mlkit_text_recognition**: OCR text extraction from images
- **file_picker**: File selection from device storage
- **permission_handler**: Runtime permission management for camera and storage

### Utility Packages
- **intl**: Internationalization and date formatting
- **share_plus**: Sharing functionality for export features
- **cupertino_icons**: iOS-style icons for cross-platform consistency

### Development Tools
- **build_runner**: Code generation tool for Riverpod
- **flutter_lints**: Dart/Flutter linting rules
- **flutter_test**: Testing framework for unit and widget tests

### Platform Support
- **Multi-platform**: Configured for Android, iOS, Linux, Windows, macOS, and Web
- **Build System**: CMake configuration for desktop platforms (Linux, Windows)
- **Asset Management**: Icon and launch screen assets for iOS and macOS platforms