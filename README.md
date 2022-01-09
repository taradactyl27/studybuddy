# StudyBuddy

Transcribe lectures, generate notes, and finally be able to search for exactly which class the professor mentioned that one thing...

# Demo
Login Page                            |  Dark Mode Login Page
:------------------------------------:|:-------------------------:
![Login Page](/screenshots/login.PNG) | ![Login Page Dark](/screenshots/login_dark.PNG)

Home Page                             |  Dark Mode Home Page
:------------------------------------:|:-------------------------:
![Home Page](/screenshots/home_light.gif) | ![Home Page Dark](/screenshots/home_dark.gif)

Selecting File                        |  Uploading File
:------------------------------------:|:-------------------------:
![File Selection](/screenshots/file_upload.PNG) | ![File Upload](/screenshots/selected_file.gif)

Course Page                           |  Lecture Page
:------------------------------------:|:-------------------------:
![Course Page](/screenshots/course_page.PNG) | ![Lecture Page](/screenshots/lecture.gif)

Flashcards                            | Recording Page  
:------------------------------------:|:-------------------------:
![Flashcards](/screenshots/flashcards.gif) | ![Recording Page](/screenshots/recording.PNG)

Web View |
:--------------:|
![Web Page](/screenshots/web.PNG)|



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
