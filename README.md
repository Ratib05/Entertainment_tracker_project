````markdown
# 🎬🎮 Entertainment Tracker

An all-in-one entertainment tracking platform that allows users to discover, organize, and track their movies, TV shows, and video games in a single application.

Instead of juggling multiple apps for different types of entertainment, this project provides one unified experience where users can keep track of what they've watched, played, are currently enjoying, and plan to experience next.

---

## Features

### User Accounts
- User registration and authentication
- Secure login/logout
- User profiles
- Personalized recommendations (future)

### Entertainment Library
- Search for:
  - 🎬 Movies
  - 📺 TV Shows
  - 🎮 Video Games
- View detailed information including:
  - Description
  - Genres
  - Release date
  - Ratings
  - Cover art
  - Developers/Studios
  - Cast (movies & TV)

### Tracking
Users can organize titles into categories such as:
- Want to Watch
- Watching
- Completed
- Want to Play
- Playing
- Played
- Dropped
- On Hold

### Ratings & Reviews
- Rate titles
- Write reviews
- Edit or delete reviews
- View community ratings

### Lists
Create custom lists such as:
- Favourite Games
- Best Horror Movies
- Must Watch TV Shows
- 2026 Backlog
- Multiplayer Games

### Social Features (Planned)
- Follow friends
- View activity feed
- Like reviews
- Comment on reviews
- Share lists

### Statistics
Track your entertainment habits with:
- Hours played
- Movies watched
- TV episodes watched
- Completion statistics
- Genre breakdown
- Yearly summaries

### Discover
- Trending titles
- New releases
- Popular this week
- Upcoming releases
- Recommendations

---

## Tech Stack

### Frontend
- Flutter
- Dart

### Backend
- Django
- Django REST Framework

### Database
- PostgreSQL

### APIs
Possible integrations include:
- TMDb API (Movies & TV)
- IGDB API (Video Games)
- RAWG API (Alternative Games API)

---

## Project Structure

```
EntertainmentTracker/
│
├── frontend/          # Flutter application
├── backend/           # Django backend
├── docs/              # Documentation
├── assets/            # Images, icons, fonts
├── database/          # Database scripts
└── README.md
```

---

## Getting Started

### Prerequisites

- Flutter SDK
- Python 3.12+
- PostgreSQL
- Git

### Clone the repository

```bash
git clone https://github.com/yourusername/entertainment-tracker.git
cd entertainment-tracker
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

### Backend

```bash
cd backend

python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS/Linux
source .venv/bin/activate

pip install -r requirements.txt

python manage.py migrate
python manage.py runserver
```

---

## Roadmap

### Phase 1
- [ ] User authentication
- [ ] Search functionality
- [ ] Personal library
- [ ] Ratings
- [ ] Reviews

### Phase 2
- [ ] Custom lists
- [ ] Statistics dashboard
- [ ] Recommendations
- [ ] Better filtering

### Phase 3
- [ ] Friend system
- [ ] Activity feed
- [ ] Comments
- [ ] Notifications

### Phase 4
- [ ] Mobile release
- [ ] Dark/Light themes
- [ ] Offline support
- [ ] Achievement system

---

## Future Ideas

- AI recommendations
- Import from Letterboxd
- Import from Steam
- Import from PlayStation/Xbox
- Import from IMDb
- Barcode scanning for physical media
- Calendar for upcoming releases
- Watch parties
- Achievement badges
- Cross-platform cloud sync

---

## Contributing

Contributions are welcome!

1. Fork the repository
2. Create a feature branch

```bash
git checkout -b feature/my-feature
```

3. Commit your changes

```bash
git commit -m "Add awesome feature"
```

4. Push to your branch

```bash
git push origin feature/my-feature
```

5. Open a Pull Request

---

## Authors

- **Ratib Hoque**
- **Danial Siddique**

---

## License

This project is licensed under the MIT License.

---

## Vision

Our goal is to build a modern entertainment companion that brings together movies, television, and gaming into a single ecosystem. We want users to spend less time managing multiple tracking apps and more time enjoying the media they love.
````
