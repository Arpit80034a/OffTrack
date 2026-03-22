# Intelligent Schedule Manager

AI-powered mobile-first app for smart task scheduling, habit tracking, and productivity management.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Backend | Node.js + Express |
| Database | Firebase Firestore |
| Auth | JWT + bcrypt |
| AI Engine | Python (Flask) |

## Project Structure

```
offtrack/
├── lib/                    # Flutter app
│   ├── main.dart
│   ├── models/             # Data models (User, Task, Habit, Schedule, Notification, Preference)
│   ├── screens/            # 11 app screens
│   ├── services/           # API & Auth services
│   └── theme/              # App dark theme
├── backend/                # Node.js API
│   ├── server.js           # Express server
│   ├── config/             # Firebase config
│   ├── controllers/        # Route handlers
│   ├── middleware/          # JWT auth & validation
│   ├── routes/             # API routes
│   └── .env                # Environment variables
├── ai_engine/              # Python AI scheduler
│   ├── app.py              # Flask server
│   ├── scheduler.py        # Scheduling algorithm
│   └── requirements.txt
```

## Setup & Run

### Prerequisites
- Flutter SDK (3.11+)
- Node.js (18+)
- Python (3.9+)
- Firebase project with Firestore enabled

### 1. Backend

```bash
cd backend
npm install
# Edit .env with your Firebase project ID and a strong JWT_SECRET
npm start
# Server runs on http://localhost:5000
```

### 2. AI Engine

```bash
cd ai_engine
pip install -r requirements.txt
python app.py
# AI Engine runs on http://localhost:5001
```

### 3. Flutter App

```bash
# From project root (offtrack/)
flutter pub get
flutter run
```

> **Note:** For Android emulator, the API uses `10.0.2.2:5000`. For web/iOS, change `baseUrl` in `lib/services/api_service.dart` to `localhost:5000`.

### Environment Variables (backend/.env)

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `5000` |
| `JWT_SECRET` | JWT signing secret | `dev_secret_key` |
| `FIREBASE_PROJECT_ID` | Firebase project ID | `intelligent-schedule-manager` |
| `AI_ENGINE_URL` | AI engine URL | `http://localhost:5001` |

## API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | No | Register user |
| POST | `/auth/login` | No | Login |
| GET | `/tasks` | Yes | List tasks |
| POST | `/tasks` | Yes | Create task |
| PUT | `/tasks/:id` | Yes | Update task |
| DELETE | `/tasks/:id` | Yes | Delete task |
| POST | `/schedule/generate` | Yes | AI-generate schedule |
| GET | `/schedule` | Yes | Get schedule |
| POST | `/habits` | Yes | Create habit |
| PUT | `/habits/:id` | Yes | Update/complete habit |
| DELETE | `/habits/:id` | Yes | Delete habit |
| GET | `/notifications` | Yes | List notifications |
| POST | `/notifications` | Yes | Create notification |
| PUT | `/notifications/:id/mark-read` | Yes | Mark as read |
| DELETE | `/notifications/:id` | Yes | Delete notification |
| POST | `/calendar/sync` | Yes | Sync to Google Calendar |
| GET | `/preferences` | Yes | Get preferences |
| PUT | `/preferences` | Yes | Update preferences |

## Screens (11)

1. **Splash** – Animated loading + auth check
2. **Login** – Email/password auth
3. **Register** – Name, email, password signup
4. **Dashboard** – Today's schedule, tasks, habits, quick actions
5. **Task Management** – CRUD tasks with priority/deadline
6. **Schedule** – AI-generated timeline view
7. **Habit Tracking** – Daily habits with streaks
8. **Calendar Sync** – Google Calendar integration
9. **Notifications** – Reminders management
10. **Help & Support** – FAQ + contact
11. **Settings** – Preferences, logout, about, terms
