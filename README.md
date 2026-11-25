# Health Keeper

Flutter app for keeping health records for yourself and your family: visits, medicines,
vaccines, vitals and more, with trends over time.

The app is a thin online client. Sign-in, family members and all records live on the
Health Keeper API ([healthkeeper-backend](https://github.com/sandeshbhujbal/healthkeeper-backend),
Python/FastAPI + PostgreSQL). Nothing health-related is stored on the phone.

## Run everything locally

You need the backend running on your machine; the app in a debug build talks to it.

### 1. Install the tools (macOS, once)

```bash
brew install postgresql@16 uv
```

```bash
brew services start postgresql@16
```

Plus Flutter and the Android SDK with an emulator (Android Studio → Device Manager).

### 2. Set up the backend (once)

```bash
git clone git@github.com:sandeshbhujbal/healthkeeper-backend.git
```

```bash
cd healthkeeper-backend
```

Create the two databases and the role the API connects as. The API deliberately uses an
ordinary (non-superuser) role so that row-level security keeps every account's data apart:

```bash
createdb healthkeeper && createdb healthkeeper_test
```

```bash
psql -d postgres -c "CREATE ROLE healthkeeper_app LOGIN PASSWORD 'healthkeeper_app' NOSUPERUSER NOBYPASSRLS"
```

Create your local settings file, then set `HK_JWT_SECRET` in it to a long random value
(for example the output of `openssl rand -base64 48`):

```bash
cp .env.example .env
```

Install the Python packages and create the tables:

```bash
uv sync
```

```bash
uv run alembic upgrade head
```

Check that it works (all tests should pass):

```bash
uv run pytest
```

### 3. Start the backend (every time)

From the `healthkeeper-backend` folder:

```bash
uv run uvicorn healthkeeper.main:app --host 0.0.0.0 --port 8000 --reload --reload-dir src
```

- Health check: http://localhost:8000/v1/health should return `{"status":"ok"}`
- API docs: http://localhost:8000/docs
- `--host 0.0.0.0` is needed so the Android emulator can reach it.

### 4. Run the app

From this repository, with the emulator running:

```bash
flutter pub get
```

```bash
flutter run
```

A debug build talks to `http://10.0.2.2:8000`, which is how the Android emulator reaches
your Mac's `localhost:8000`. To point at another server:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

If the Gradle build stops on a dependency validation error, build with:

```bash
flutter build apk --debug --android-skip-build-dependency-validation
```

### 5. Sign in

Google sign-in isn't set up yet (it needs OAuth client IDs from Google Cloud). On the
Sign-in screen use **Developer sign-in (local server)** and enter any email. Each email is
a separate test account. This sign-in only exists in debug builds and only works against a
backend running with `HK_ENV=local` (the default).

First sign-in walks you through consent and creating your own profile, then the family list.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| App shows "Can't reach Health Keeper" | Is the backend running with `--host 0.0.0.0`? Does http://localhost:8000/v1/health answer? |
| Backend: `connection refused` to Postgres | `brew services start postgresql@16` |
| Backend: `permission denied` or `role "healthkeeper_app" does not exist` | Run the `CREATE ROLE` command in step 2, then `uv run alembic upgrade head` again |
| Backend won't start: `HK_JWT_SECRET must be at least 32 characters` | Set a longer `HK_JWT_SECRET` in `.env` |
| Developer sign-in says "Not Found" | The backend isn't running with `HK_ENV=local` |
| Start from an empty database | `uv run alembic downgrade base && uv run alembic upgrade head` |

## Development

```bash
flutter analyze
```

```bash
flutter test
```

See [CLAUDE.md](CLAUDE.md) for how the code is organised.
