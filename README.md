<div align="center">

# CODAH MUSIC

**A feature-rich Flutter music player for Windows**

[![Platform](https://img.shields.io/badge/platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://codahmusic.onrender.com)
[![Built with Flutter](https://img.shields.io/badge/built%20with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)

### [Official Website](https://codahmusic.onrender.com)

</div>

---

## Features

- **YouTube Music Streaming** - Search and stream any song from YouTube Music
- **Lyrics** - Real-time synced lyrics with multiple provider support (LRCLib, Lyrica)
- **Spotify Import** - Import your Spotify playlists directly
- **Billboard Charts** - Browse Billboard Hot 100, Billboard 200, and genre charts
- **Spotify Charts** - View trending charts from Spotify
- **Local Library** - Play and manage your local audio files
- **Audio Streaming Server** - Built-in HTTP server for efficient audio streaming
- **Auto Updates** - Stay up to date with automatic update notifications
- **Beautiful UI** - Modern Material 3 design with dynamic theming and blur effects

---

## Screenshots

> Screenshots coming soon

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.4.1)
- Windows desktop support enabled

### Build from Source

```bash
# Clone the repository
git clone https://github.com/coder-nishanth/codah-music.git
cd codah-music

# Install dependencies
flutter pub get

# Build the release executable
flutter build windows --release
```

The compiled app will be available under `build/windows/x64/runner/Release/`.

### Create Installer

The project includes an Inno Setup script (`windows/installer.iss`) for building a Windows installer:

1. Build the release executable first
2. Open `windows/installer.iss` in [Inno Setup](https://jrsoftware.org/isinfo.php)
3. Click Build > Compile

---

## Download

Prefer not to build it yourself? Grab the latest release:

**[Download CODAH MUSIC](https://codahmusic.onrender.com)**

---

## Support

If you enjoy CODAH MUSIC, consider supporting development:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/coder.nishanth)

**UPI ID:** `coder-nishanth@airtel`

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with Flutter

</div>
