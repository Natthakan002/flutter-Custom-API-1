# FlutterCustomAPI

A cross-platform Flutter application connected with a custom backend API for data management.

## Project Structure

### Flutter App

- `android/` - Android platform files  
- `ios/` - iOS platform files  
- `lib/` - Flutter Dart source code  
- `linux/` - Linux platform files  
- `macos/` - macOS platform files  
- `windows/` - Windows platform files  
- `web/` - Web platform files  
- `test/` - Unit and widget tests  
- `pubspec.yaml` - Flutter dependencies and config  
- `.gitignore`, `.metadata`, `analysis_options.yaml` - config and metadata  

### Backend API

- Separate backend repository (if any) or integrated backend code  
- Custom REST API for CRUD operations  
- Connects with Flutter app for data fetching and management  

## Technologies Used

- Flutter & Dart for frontend  
- Node.js + Express.js (or your backend stack) for API  
- MongoDB or other database for data storage  
- Cross-platform support (mobile, web, desktop)  

## Features

- Cross-platform Flutter app with responsive UI  
- Fetch and update data through custom REST API  
- CRUD operations support  
- Support for Android, iOS, Web, Windows, macOS, Linux  
- Testing and debugging support  

## How to Run Locally

### Flutter App

```bash
# 1. Clone the Flutter app repo
git clone https://github.com/Foam-01/FlutterCustomAPI.git
cd FlutterCustomAPI

# 2. Fetch Flutter dependencies
flutter pub get

# 3. Run on preferred platform
flutter run -d android  # Or ios, chrome, windows, macos, linux
```


Backend API (if separate repo)

```bash
# 1. Clone backend repo
git clone https://github.com/Foam-01/Backend-Flutter-Custom-API.git
cd Backend-Flutter-Custom-API

# 2. Install dependencies
npm install

# 3. Configure environment variables (.env)

# 4. Start backend server
npm start
```
![f726ef84-d537-4afb-8f47-989026edab75](https://github.com/user-attachments/assets/a8e8f107-4f11-4ca7-9f01-65fe5e6a9cc8)
![6667de36-f15d-4ac9-8cf5-3c164ad4c9d9](https://github.com/user-attachments/assets/29db5d16-aa70-421f-8ea1-b0e3b936ccda)
![d5a1fa14-f39b-4556-af5e-aee15e2e4bca](https://github.com/user-attachments/assets/8b3dccd8-e791-4db2-8d19-a878acda4b4b)

