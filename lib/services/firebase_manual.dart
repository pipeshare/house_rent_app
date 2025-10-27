import 'package:firebase_core/firebase_core.dart';

class FirebaseManualConfig {
  static FirebaseOptions get androidOptions {
    return const FirebaseOptions(
      apiKey:
          "AIzaSyDrjIricovs67aVsn27ZjvcGcRB-_pDJFA", // You'll need to get this from google-services.json
      appId: "1:976586555991:android:e58345a49bc5081cbd1912", // From your file
      messagingSenderId: "976586555991", // project_number from your file
      projectId: "house-rent-app-46729", // From your file
      storageBucket:
          "house-rent-app-46729.firebasestorage.app", // From your file
    );
  }
}
