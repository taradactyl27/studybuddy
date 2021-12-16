# StudyBuddy

Transcribe lectures, generate notes, and finally be able to search for exactly which class the professor mentioned that one thing...


## Requirements

- Flutter >= 2.8
- Android: Android >= 30
- iOS: iOS >= 12

## Installation

1. Download/clone the repository and navigate to it

      `git clone git@github.com:taradactyl27/studybuddy.git`
      
      `cd studybuddy`

2. Install flutter libraries

      `cd client`
      
      `flutter pub get`

3. (Optional) Setting up a Firebase Project

## Developing Locally

- Set up devices (default is chrome web)
- `flutter run`

## Project File Layout / Architecture 

Using a 'serverless' microservice design.

- `client/` : flutter app (frontend)
  - `lib/`: main app source code
    - `routes/`: navigation
    - `screens/`: pages 
    - `services/`: business logic & utils
    - `widgets/`: general components
  - `main.dart`: entry point 
- `functions/src/`: cloud functions (backend)
  - `algolia.ts`: firestore triggers to keep indexed algolia records up to date
  - `config.ts`: common firebase configuration and objects
  - `storage.ts`: cloud storage trigger, file conversion & transcript file reading logic
  - `transcription.ts`: transcript generation
