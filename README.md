# Connex iOS App

A modern social networking app focused on meaningful connections.

## Features

- Guided profile creation
- Interest-based matching
- Real-time chat
- Moments sharing
- Advanced filtering
- Location-based discovery

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+

## Installation

1. Clone the repository
2. Open `Connex.xcodeproj` in Xcode
3. Update signing team in project settings
4. Build and run

## Configuration

Update the following files for your environment:

- `Config/AppConfig.swift`: API endpoints and app settings
- `Config/config.xcconfig`: Build settings and bundle ID
- `Resources/Info.plist`: App permissions and configuration

## Architecture

- MVVM architecture
- SwiftUI for UI
- Combine for reactive programming
- URLSession for networking
- Core Data for local storage

## Dependencies

- None (Pure SwiftUI implementation)

- # Connex

## Professional Networking Mobile Application

### Project Overview
Connex is an iOS professional networking app designed to connect professionals through a modern, intuitive interface.

### Technical Architecture
- **Platform**: iOS
- **Minimum OS Version**: iOS 16+
- **Development Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)

### Backend Integration
- **Authentication**: Firebase Authentication
- **Database**: Firebase Firestore
- **Services**: 
  - User Management
  - Profile Creation
  - Data Persistence

### Key Technical Components
- **Authentication Workflow**
  - Email/Password Authentication
  - Secure Firebase Authentication
  - Input Validation
  - Error Handling

- **Profile Creation**
  - Multi-step Registration Process
  - Dynamic Form Validation
  - Image Upload Capability
  - Interest Selection Mechanism

### Firebase Configuration
- **Authentication Methods**:
  - Email/Password
- **Firestore Collections**:
  - `users`: Store user profiles
  - `connections`: Future networking connections

### SwiftUI Features Utilized
- State Management
- Combine Framework
- View Composition
- Reactive Programming Patterns

### Current Development Status
- [x] User Authentication
- [x] Profile Creation Workflow
- [ ] Networking Features
- [ ] Messaging System

### Development Environment
- Xcode 16
- Swift 5.9
- iOS SDK 18
- Firebase SDK

### Performance Considerations
- Asynchronous Data Handling
- Efficient State Management
- Minimal Network Requests

### Security Implementations
- Secure Firebase Authentication
- Input Sanitization
- Error Logging
- Secure Data Storage

### Future Roadmap
1. Professional Networking Features
2. Real-time Messaging
3. Connection Recommendations
4. Advanced Profile Customization

### Getting Started
1. Clone Repository
2. Install Firebase GoogleService-Info.plist
3. Configure Firebase Project
4. Run in Xcode Simulator

### Dependencies
- Firebase Authentication
- Firebase Firestore
- SwiftUI
- Combine Framework

### Contribution Guidelines
- Follow SwiftLint Rules
- Maintain MVVM Architecture
- Write Comprehensive Unit Tests

## License

Copyright © 2024 Connex. All rights reserved. 
