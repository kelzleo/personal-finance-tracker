# Personal Finance Tracker

A Flutter mobile app backed by a REST API built with Node.js and Express. Users can log transactions, view a summary, and manage their records.

## Project Structure
```
personal-finance-tracker/
├── finance_tracker/   # Flutter app
└── backend/           # Express REST API
```

## Backend Setup

### Requirements
- Node.js v18 or higher
- npm

### Installation
```bash
cd backend
npm install
```

### Running the Server
```bash
node server.js
```

Server runs on `http://localhost:3000`

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /transactions | Return all transactions |
| POST | /transactions | Create a new transaction |
| GET | /transactions/:id | Get a single transaction |
| PATCH | /transactions/:id | Update any field |
| DELETE | /transactions/:id | Delete a transaction |
| GET | /summary | Total income, expenses, net balance |

### Transaction Schema
```json
{
  "id": 1,
  "title": "Salary",
  "amount": 5000,
  "type": "income",
  "category": "Salary",
  "date": "2026-02-19T00:00:00.000Z",
  "note": "February salary"
}
```

### Validation Rules
- `title` — required, non-empty string
- `amount` — required, positive number
- `type` — required, must be `income` or `expense`
- `category` — required, non-empty string
- `date` — required, valid ISO date string
- `note` — optional

> Note: Storage is in-memory. Data resets when the server restarts.

## Flutter App Setup

### Requirements
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android device or emulator running Android API 30+ (tested on Android 11)

### Installation
```bash
cd finance_tracker
flutter pub get
```

### Configuration

The app connects to the backend via:
- **Genymotion emulator**: `http://10.0.3.2:3000`
- **Standard Android emulator**: `http://10.0.2.2:3000`
- **Physical device**: replace with your machine's local IP e.g. `http://192.168.1.x:3000`

To change the base URL, edit `lib/services/api_service.dart`:
```dart
baseUrl: 'http://10.0.3.2:3000',
```

### Running the App

Make sure the backend server is running first, then:
```bash
flutter run
```

### Screens

1. **Transactions Screen** — lists all transactions newest first with a summary bar showing net balance, total income and total expenses. Filter by All, Income or Expense. Pull down to refresh.
2. **Add Transaction Screen** — form to log a new transaction with validation on all fields.
3. **Transaction Detail Screen** — shows all fields for a transaction with a delete option and confirmation dialog.

### Tech Stack

| Layer | Technology |
|-------|------------|
| State Management | Riverpod |
| Navigation | GoRouter |
| HTTP Client | Dio |
| Date Formatting | intl |

### Design Decisions

- **Riverpod** was chosen for state management because it is compile-safe, testable, and handles async states cleanly with `FutureProvider` and `autoDispose`.
- **GoRouter** was chosen for navigation because it provides a declarative, URL-based routing system that scales well and integrates cleanly with Riverpod.
- **Dio** was chosen over the default `http` package because it provides interceptors, better error handling, and timeout configuration out of the box.
## Assumptions

- The base URL is configured for Genymotion emulator (`10.0.3.2`). This needs to be changed depending on the device used — instructions are in the Configuration section above.
- Transaction amounts are always stored as positive numbers. The `type` field (income or expense) determines whether it is money coming in or going out.
- The edit screen was added beyond the three required screens since the PATCH endpoint was required by the API spec but had no corresponding UI.
- Categories are predefined (Food, Transport, Shopping, Entertainment, Health, Salary, Freelance, Other) rather than user-defined for simplicity.


## Future Improvements

Given more time, the following improvements would be made:

### Backend
- **Persistent Database** — replace in-memory storage with SQLite or PostgreSQL so transaction data survives server restarts
- **Authentication** — add JWT-based auth so each user has their own private transaction data
- **Pagination** — add limit/offset pagination to `GET /transactions` to handle large datasets efficiently

### Flutter App
- **Spending Charts** — add pie or bar charts to visualize spending breakdown by category using a library like fl_chart
- **Date Range Filtering** — allow users to filter transactions by a custom date range, not just by type
- **Search** — add a search bar to find transactions by title or category
- **Offline Support** — cache transactions locally using shared_preferences or Hive so the app works without a server connection
- **Dark Mode** — add a dark theme toggle for better usability in low light
- **CSV Export** — allow users to export their transaction history as a CSV file for use in spreadsheets

### Code Quality
- **Unit Tests** — add tests for all Express API endpoints using Jest or Mocha
- **Widget Tests** — add Flutter widget tests for all three screens
- **CI/CD Pipeline** — add GitHub Actions to run tests automatically on every push