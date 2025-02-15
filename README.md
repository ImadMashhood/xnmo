# XNMO - Employee Clock-In System

XNMO is a Flutter-based employee time-tracking app that allows users to clock in, take breaks, and clock out while logging timestamps and GPS coordinates in Firebase Firestore.

---

## 🚀 Features

- ✅ **User Authentication** - Secure login and sign-up using Firebase Authentication
- ✅ **Clock In & Out** - Tracks user check-ins, breaks, and check-outs
- ✅ **GPS Logging** - Stores user location during clock-in/out for verification
- ✅ **Real-Time Status Updates** - Displays latest status with timestamps
- ✅ **Shimmer Loading Effects** - Enhances UI while fetching data
- ✅ **Admin Controls** - Ability to manually set admin users in Firestore
- ✅ **Dynamic UI Animations** - Uses transitions, fades, and a circular reveal effect

---

## 📸 Screenshots

| Login            | Home Screen         |
|------------------|---------------------|
| images/login.png | images/homePage.png |

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

- Users can clock in from the home screen.
- Status updates to "Clocked In" with a timestamp.
- Users can take breaks and end breaks.
- When clocking out, a new entry is stored in Firestore.

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
- 🚀 **Offline Mode** (Sync logs when reconnected)
- 🚀 **Shift Scheduling** (Assign work shifts)

---

## 📜 License

This project is licensed under the MIT License.

---

## 🙌 Contributing

We welcome contributions! Feel free to submit a pull request or open an issue.

---

## 💡 Contact

For inquiries or issues, feel free to reach out via GitHub Issues.

