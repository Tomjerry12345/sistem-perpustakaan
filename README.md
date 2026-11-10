# Library Admin Dashboard (Flutter Web)

Admin web dashboard for a regional library, built with Flutter Web and Firebase. Staff manage the book catalog (with cover images and PDF files), members, loans and returns, and use a QR code to confirm member check-ins and loans.

## Features

- **Book catalog:** add, edit and delete books (title, author, publisher, category, shelf, pages, synopsis, stock, barcode). Upload a cover image and a PDF of the book to Firebase Storage, and search by title.
- **Members:** table of registered members with member number, name, email, occupation, address and phone numbers.
- **Loans:** pick a member to see their loans, confirm a loan, set the borrow and due dates, and see a late fee calculated per overdue day.
- **Returns:** mark a loan as returned. It moves to the returns list together with its fine, and each member's returns can be reviewed.
- **QR scan:** the dashboard shows a QR code and listens to a Firestore document in real time. A check-in code verifies that the member account is registered and shows a success or error screen. A loan code opens that member's loan confirmation screen.

## Tech stack

- Flutter Web (Dart SDK `>=2.17.5 <3.0.0`)
- Firebase: Cloud Firestore, Authentication, Storage (`firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`)
- [`qr_flutter`](https://pub.dev/packages/qr_flutter) for the QR code
- [`file_picker`](https://pub.dev/packages/file_picker) and `image_picker_web` for PDF and image uploads
- [`pdf`](https://pub.dev/packages/pdf), [`intl`](https://pub.dev/packages/intl), [`flutter_datetime_picker`](https://pub.dev/packages/flutter_datetime_picker)
- [`fast_snackbar`](https://github.com/Tomjerry12345/fast_snackbar) (my own package) for notifications

## Firestore collections

| Collection    | Purpose                                                                          |
| ------------- | -------------------------------------------------------------------------------- |
| `books`       | Book catalog: title, author, publisher, category, shelf, stock, cover and PDF URLs |
| `users`       | Registered library members                                                       |
| `peminjaman`  | Active loans (borrow date, due date, confirmation, fine)                         |
| `pengembalian`| Returned books with their fines                                                  |
| `barcode`     | A single document `code` that carries the current QR scan code                   |
| `tamu`        | Guest book entries (the screen exists but is hidden from the menu)               |

## Getting started

**Requirements:** Flutter 3.0 to 3.7 (Dart `>=2.17.5 <3.0.0`), Chrome, and a Firebase project with Firestore, Storage and Authentication enabled.

```bash
git clone https://github.com/Tomjerry12345/perpustakaan-app-web.git
cd perpustakaan-app-web
flutter pub get
```

1. Replace the Firebase configuration with your own project in `lib/main.dart` and `web/index.html`.
2. In Firestore, create the collection `barcode` with one document whose ID is `code` and whose field `code` is set to `"default"`.
3. Run the app:

```bash
flutter run -d chrome
```

## Project structure

```
lib/
├── main.dart             # Firebase initialization and app entry
├── screens/              # Dashboard, books, members, loans, returns, scan, guest book, login
├── services/             # FirebaseServices: Firestore queries and Auth
├── model/                # Query model
├── widget/               # Reusable widgets (dialogs, text, buttons, text fields, header)
└── utils/                # Helpers (navigation, time, strings, screen size)
```

## Notes

- A Firebase email/password login screen exists, but the app currently opens directly on the dashboard. Protect your data with Firestore and Storage security rules before deploying.
- Planned but not implemented yet: import and export for books, members, guest book, loans and returns.

## Screenshots

<!-- Add screenshots of the dashboard, book catalog and loan screens here -->
