# Caecilia

Aplikasi Android asisten penulis novel, dikembangkan bertahap melalui slice.
Targetnya mencakup chat AI streaming, story bible lokal, dan proxy tipis ke API
model. Fitur-fitur tersebut belum seluruhnya diimplementasikan.

## Status

Fase 0 (S00–S04) selesai: skeleton repo, aplikasi Flutter placeholder, Worker
health lokal, kontrak API v0 yang disetujui, dan script verifikasi.
Endpoint `/chat` masih berupa kontrak, belum tersedia pada Worker.
Lihat [ROADMAP](docs/ROADMAP.md) dan [aturan kontribusi agent](AGENT.md).

## Struktur

- `apps/mobile/` — aplikasi Flutter Android.
- `apps/proxy/` — Cloudflare Worker dengan TypeScript strict.
- `packages/contracts/` — kontrak API dan event SSE.
- `scripts/` — verifikasi mobile/proxy dan test script.
- `docs/` — roadmap proyek.

## Prasyarat

- Flutter stable dan Dart pada PATH; baseline teruji: Flutter 3.47.7 / Dart 3.13.5.
- Android SDK, Java yang kompatibel, dan emulator/perangkat Android.
- Node.js dan npm; baseline teruji: Node 24.15.0 / npm 11.12.1.
- Bash; pada Windows gunakan Git Bash, bukan WSL.

Flutter pada lingkungan pengembangan awal terpasang di
`C:\Users\Christian\development\flutter`. Lokasi ini bukan persyaratan proyek;
SDK dapat dipasang di lokasi lain asalkan `flutter` dan `dart` tersedia pada PATH.

## Menjalankan mobile

Dari root repo:

```bash
cd apps/mobile
flutter pub get
flutter devices
flutter run -d <id-perangkat>
```

Saat ini aplikasi menampilkan halaman placeholder Caecilia, bukan beranda final.

## Menjalankan proxy lokal

Dari root repo:

```bash
cd apps/proxy
npm ci
npm run dev
```

Dari terminal lain:

```bash
curl -i http://127.0.0.1:8787/health
```

Hasil: HTTP 200 dengan `{"status":"ok"}`. Method selain GET pada `/health`
menghasilkan 405; path lain menghasilkan 404. Tidak perlu credential Cloudflare
untuk mode lokal. Belum ada deployment produksi.

## Verifikasi

Setelah dependency mobile dan proxy tersedia, jalankan dari root repo:

```bash
bash scripts/verify.test.sh
bash scripts/verify.sh
```

Script utama menjalankan format Dart, Flutter analyze/test, build APK debug,
serta lint/typecheck/test proxy. Semua gerbang tetap dijalankan meskipun salah satu
gagal. Exit code 0 berarti seluruh tujuh gerbang lulus; selain itu verifikasi gagal.
Flutter/Gradle dapat mengunduh artifact build yang belum tersedia.

Contoh PowerShell pada Windows dengan lokasi SDK pengembangan awal:

```powershell
$env:Path = "C:\Users\Christian\development\flutter\bin;$env:Path"
& "C:\Program Files\Git\bin\bash.exe" scripts/verify.test.sh
$LASTEXITCODE
& "C:\Program Files\Git\bin\bash.exe" scripts/verify.sh
$LASTEXITCODE
```

APK debug dihasilkan pada
`apps/mobile/build/app/outputs/flutter-apk/app-debug.apk` dan tidak masuk Git.

## Keamanan dan alur kerja

Jangan commit secret. `.env.example` hanya memuat nama variabel; environment lokal
seperti `.env` dan `.dev.vars` diabaikan Git. API key model kelak hanya disimpan di
proxy, bukan aplikasi Android. Jangan mencatat prompt atau teks novel ke log.

Kerjakan satu slice sesuai roadmap pada branch tersendiri. Publikasi finalisasi
ke `main` hanya dilakukan dengan izin eksplisit pemilik; izin satu finalisasi
tidak berlaku otomatis untuk finalisasi berikutnya.
