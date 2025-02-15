# XNMO - Employee Clock-In System

XNMO is a Flutter-based employee time-tracking app that allows users to clock in, take breaks, and clock out while logging timestamps and GPS coordinates in Firebase Firestore.

---

## 🚀 Features
- ✅ Clock In & Out – Tracks clock-ins, breaks, and clock-outs with timestamps.
- ✅ GPS Logging – Stores user location during clock-in/out for verification.
- ✅ Real-Time Status Updates – Displays the latest work status with timestamps.
- ✅ Shimmer Loading Effects – Smooth loading animations while fetching data.
- ✅ Work History & Analytics – Users can view logged hours and break times in an interactive Activity Card.
- ✅ Embedded Maps – Displays clock-in/out locations using OpenStreetMap.
- ✅ Firestore Integration – All work logs are stored & synced in real-time.

---

## 📸 Screenshots

| Login | Home Screen |
|-------|------------|
| ![Login](images/login.png) | ![Home Screen](images/homePage.png) |


---

## 📥 Installation

### 1️⃣ Clone the repository:

```sh
git clone https://github.com/yourusername/xnmoapp.git
cd xnmoapp
```

### 2️⃣ Install dependencies:

```sh
flutter pub get
```

### 3️⃣ Setup Firebase:

- Create a Firebase project in the Firebase Console
- Enable Authentication (Email/Password)
- Setup Cloud Firestore
- Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 4️⃣ Run the app:

```sh
flutter run
```

---

## ⏳ Usage

### Clocking In & Out
- Users tap the Clock In button from the Home Screen.
- Status updates to "Clocked In" with a timestamp and GPS location.
- Users can tap "Take Break" to log a break.
- The system records the timestamp and pauses work tracking.
- Pressing "End Break" resumes tracking.
- Users tap "Clock Out" to finish their work session.
- A new entry is stored in Firestore with:
- Start Time (Clock In)
- End Time (Clock Out)
- Break Duration
- Total Worked Hours (calculated automatically)
- Users can view their work history in the Activity Card.
- Maps display locations of clock-ins and clock-outs.
- Total work hours for the selected day are calculated dynamically.
- 🚀 All data is synced in real-time using Firebase Firestore.

### Admin Features
- Admins can be manually assigned in Firestore (`isAdmin: true`).
- Admins can access advanced reports (feature in progress).

---

## 🛠️ Tech Stack

- **Flutter (Dart)**
- **Firebase Authentication**
- **Cloud Firestore**
- **Geolocator (GPS tracking)**
- **Shimmer (UI loading effects)**
- **Intl (Date formatting)**

---

## 📂 Folder Structure

```bash
/xnmoapp
  ├── lib/
 │   ├── main.dart                   # Entry point of the app
 │
 │   ├── reusable_components/         # Reusable UI components
 │   │   ├── expandable_card.dart     # Expandable card component
 │
 │   ├── screens/                     # Main screens of the app
 │   │   ├── homescreen.dart          # Home screen
 │   │   ├── login.dart               # Login screen
 │   │   ├── signup.dart              # Signup screen
 │   │   ├── splash.dart              # Splash screen
 │
 │   ├── widgets/                      # Reusable widgets
 │   │   ├── activity_card.dart        # Displays work activity logs
 │   │   ├── status.dart               # Displays current clock-in status
 ├── android/   # Android-specific configurations
 ├── ios/       # iOS-specific configurations
 ├── pubspec.yaml # Flutter dependencies
```

---

## 🔮 Roadmap

- 🚀 **Admin Dashboard** (Web-based analytics for managers)

---

## 📜 License

This project is licensed under the MIT License.

---

## 🙌 Contributing

We welcome contributions! Feel free to submit a pull request or open an issue.

---

## 💡 Contact

For inquiries or issues, feel free to reach out via GitHub Issues.

