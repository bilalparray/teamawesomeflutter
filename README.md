# Team Awesome Sozeith — Flutter app

**Package:** `teamawesomesozeith` (see `pubspec.yaml`)

This directory is the **Flutter** client for Team Awesome Sozeith: local cricket team stats, players, batting order, fixtures, and leaderboards. It talks to the **Node.js + Express + MongoDB** API in the sibling folder [`../TeamAwesomeBackend/`](../TeamAwesomeBackend/).

Full monorepo documentation (same detail, repo-root paths): **[../README.md](../README.md)**

---

## Repository layout (monorepo)

| Path | Description |
|------|-------------|
| **`teamawesomeflutter/`** (this folder) | Flutter app. Android-focused; iOS launcher icons disabled in `pubspec.yaml`. |
| **`TeamAwesomeBackend/`** | REST API, Mongoose models, admin HTML under `public/`, scorecard PDF pipeline. |

---

## Features (Flutter)

- **Onboarding** — first launch flag in `SharedPreferences` (`isFirstTime`).
- **Connectivity** — blocks main experience when offline; retry available.
- **Home** — man of the match (client-side from latest runs/wickets), featured players, management cards, top run scorer / wicket taker (season arrays), recent matches.
- **Players** — list from API with ranking; profile with tabs (profile, recent, year, career, runs, wickets).
- **Batting order** — order from API with last four innings per name.
- **Stats leaderboard** — `POST /api/stats/top` with metric (50s, 100s, wickets, runs) and scope (career, year).
- **Settings** — share app, Play Store link, privacy policy, contact, version from `package_info_plus`.
- **Error UX** — API error and no-internet screens include **Retry** and **Check app update** (opens Play Store listing).

### Backend (sibling project) — summary

- CRUD-style **players** with nested `scores` (season + `career`, `lastfour`).
- **Batting order** document (single `order: string[]`).
- **Next matches** — fixtures with optional series metadata.
- **App info** — minimum version / flags for update flows.
- **PDF scorecard** — extract names, parse stats, apply bulk updates (`/api/scorecard/*`).
- **Static admin UIs** — HTML/JS in `public/` (e.g. update scores, batting order, scorecard upload).

---

## Prerequisites

- **Flutter** SDK `^3.6.2` (see `pubspec.yaml`).
- **Node.js** (LTS recommended) and **MongoDB** if you run the API locally.

---

## Flutter setup (this project)

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Point the app at your API

Configuration lives in:

```text
lib/environment/environemnt.dart
```

Update **`Environment.baseUrl`** to your deployed API (include `https://`). The same host is used for players, matches, batting order, and stats.

Also set **`playstoreUrl`** and **`privacyPolicy`** there as needed.

### 3. Run

```bash
flutter run
```

For release builds, use Flutter’s Android signing and Play Console workflow.

### 4. Analyze

```bash
flutter analyze
```

---

## Backend setup (sibling folder)

### 1. Install dependencies

```bash
cd ../TeamAwesomeBackend
npm install
```

### 2. Environment variables

The server loads Dotenv from **`process.env`** in the backend folder (not `.env`):

```text
../TeamAwesomeBackend/process.env
```

| Variable | Purpose |
|----------|---------|
| `MONGODB_URI` | Required — MongoDB connection string |
| `PORT` | Optional — HTTP port (default **3000**) |

Example:

```env
MONGODB_URI=mongodb+srv://user:pass@cluster.example/dbname
PORT=3000
```

### 3. Run the API

```bash
npm start
```

### 4. Score migration (optional)

If legacy score arrays use strings:

```bash
npm run migrate:scores:number:dry
npm run migrate:scores:number
```

---

## API overview (non-exhaustive)

Base URL = value of `Environment.baseUrl`.

| Method | Path | Notes |
|--------|------|--------|
| GET | `/api/players` | All players; server may recompute career ranking. |
| GET | `/api/data/:playerId` | Single player. |
| POST | `/api/data` | Create player. |
| PUT | `/api/data/:playerId` | Append match stats (`runs`, `balls`, `wickets` as arrays). |
| PUT | `/api/update/:playerId` | Profile / image. |
| GET | `/api/batting-order` | Current batting order. |
| PUT | `/api/batting-order` | Body: `{ "reqData": { "order": ["Name1", ...] } }`. |
| GET/POST/PUT/DELETE | `/api/nextmatch` … | Fixtures. |
| GET | `/api/updateapp` | App update document. |
| GET | `/api/mom` | Server-side MOTM. |
| POST | `/api/stats/top` | Body: `metric` (50s, 100s, wickets, runs), `scope` (career, year). |
| POST | `/api/scorecard/extract-players` | Multipart `pdf`. |
| POST | `/api/scorecard/process` | Multipart `pdf`; optional `latePlayers`. |
| POST | `/api/scorecard/apply-to-db` | Bulk apply parsed stats. |

More routes: `../TeamAwesomeBackend/Routes/routes.js`.

---

## App architecture (Flutter)

| Area | Path |
|------|------|
| Entry / theme / shell | `lib/main.dart` |
| Environment | `lib/environment/environemnt.dart` |
| HTTP services | `lib/services/player_service.dart`, `match_service.dart`, `batting_order_service.dart` |
| Screens | `lib/pages/` |
| Widgets | `lib/widgets/` |
| Models | `lib/models/` |

The client tolerates **numeric or string** score entries where parsing is used (`PlayerService`, `PlayerDataProcessor`).

---

## Data model (players — API)

See `../TeamAwesomeBackend/models/PlayerSchema.js`:

- Profile fields + `image` (often base64).
- `scores.runs`, `scores.balls`, `scores.wickets`, `scores.lastfour`.
- `scores.career.*` including `ranking` for list ordering.

---

## Syncing API URL with web admin

Update both:

- `lib/environment/environemnt.dart` — **`baseUrl`**
- `../TeamAwesomeBackend/public/appconstants.js` — same API origin for admin pages.

---

## Troubleshooting

| Symptom | Things to check |
|---------|------------------|
| API / load errors | `Environment.baseUrl`, device network, TLS. |
| Stats empty / wrong | JSON score types (int vs string); migration on DB. |
| Leaderboard avatars | API may return base64; UI may expect URLs. |
| Slow `/api/players` | Backend recomputes rankings on each GET. |

---

## Versioning

App version: **`pubspec.yaml`** (`version: x.y.z+build`).

---

## Contributing

Keep API and `Environment.baseUrl` in sync when endpoints or payloads change. Run `flutter analyze` before submitting changes.

---

## Flutter resources (templates)

If you are new to Flutter:

- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
