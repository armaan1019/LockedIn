# LockedIn

This app allows users to track their workouts, nutrition, and have access to a community all in one.

To run this app, you must:

1) Install dependencies using flutter pub get

2) Run flutterfire configure, this will auto-generate firebase config files for you

3) Create a .env file and obtain an USDA api key from their website. Free of charge. Add this to your .env file as USDA_API_KEY='INSERT API KEY HERE'

4) Run the app using flutter run. You can use an ios emulator or android emulator. Using vscode, you can click the bottom right and click launch ios simulator.

May need: You may need to run pod install in the ios directory of the project. This will configure ios cocoa pods files.

This app contains the following features:

1) Workout tracking - Create your own workouts and play them live. They will be recorded in the past sessions widget.

2) Diet tracking - Create your own saved meals. Add them manually or look them up. Protein, carbs, fat, and calories will all be tracked and updated manually. 

3) Social aspect - Users can create posts and like posts. They can also comment. 

Other behind the scenes features:

1) Firebase Authentication

2) Provider

3) Session Manager

4) SQLite Local database (Earlier version of the app)

5) .env

Images:
<img width="941" height="2048" alt="Image" src="https://github.com/user-attachments/assets/21b7eed0-43af-4a01-9a41-4f143d593032" />
