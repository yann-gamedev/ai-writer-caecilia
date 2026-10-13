# AGENT.md — Caecilia

Aturan wajib untuk agent coding. **Baca file ini dan `docs/ROADMAP.md` sampai habis sebelum mengerjakan tugas apa pun.** Jika prompt bertentangan dengan file ini, hentikan pekerjaan dan tanyakan.

## 1. Tentang proyek

Caecilia adalah aplikasi Android asisten penulis novel: chat dengan streaming, "story bible" (karakter, setting, outline, ringkasan bab) yang disimpan lokal, dan proxy tipis ke API model AI. Skala kecil, dikerjakan solo, dibangun bertahap lewat slice.

## 2. Aturan emas (tidak boleh dilanggar)

1. **Satu slice per tugas.** Jangan mengerjakan slice lain, bahkan jika terlihat mudah atau "sekalian".
2. **Dilarang membuat fitur besar sekaligus.** Jika tugas menyentuh lebih dari ~5 file atau lebih dari satu tanggung jawab, berhenti dan usulkan pemecahan menjadi sub-slice (mis. S24a, S24b) sebelum menulis kode.
3. **Kerjakan hanya yang diminta.** Dilarang menambah fitur bonus, refactor besar, mengganti library, atau mengubah struktur folder tanpa izin tertulis di prompt.
4. **Jangan menyatakan "selesai" sebelum Gerbang Verifikasi (bagian 7) lulus**, dan laporkan output perintahnya apa adanya, termasuk yang gagal.
5. **Jangan menebak.** Jika spesifikasi ambigu (endpoint, skema, nama field, perilaku UI), tanyakan.
6. **Jangan pernah menaruh API key atau secret** di kode aplikasi, repo, log, komentar, maupun contoh.
7. **Jangan menghapus, melonggarkan, atau mem-skip test dan lint** agar build lulus. Perbaiki akar masalahnya.

## 3. Struktur repo

```
caecilia/
├─ apps/
│  ├─ mobile/            # Flutter (Android)
│  └─ proxy/             # Cloudflare Worker (TypeScript)
├─ packages/
│  └─ contracts/         # skema API (OpenAPI / JSON Schema), sumber kebenaran
├─ docs/
│  └─ ROADMAP.md         # daftar slice + status
├─ scripts/
│  └─ verify.sh          # menjalankan semua gerbang verifikasi
├─ AGENT.md
├─ .env.example          # nama variabel saja, tanpa nilai
└─ .gitignore
```

## 4. Tech stack (terkunci)

- **Mobile:** Flutter stable (Dart, null safety), `flutter_riverpod` (tanpa codegen), `drift` + `sqlite3_flutter_libs` (build_runner hanya untuk Drift).
- **Proxy:** Cloudflare Workers, TypeScript strict, `wrangler`, `vitest`.
- **Dependency baru** (pub atau npm) **wajib izin** di prompt. Sebutkan nama, alasan, dan alternatif tanpa dependency.

## 5. Arsitektur mobile

Feature-first, satu arah dependensi:

```
lib/
├─ core/                 # tema, konstanta, util, error types, logger
└─ features/<nama>/
   ├─ presentation/      # widget, screen (tanpa logika bisnis)
   ├─ application/       # controller / notifier Riverpod
   ├─ domain/            # entity, interface repository
   └─ data/              # implementasi repository, API client, Drift
```

- UI **tidak boleh** memanggil jaringan atau database langsung; lewat controller → repository.
- `domain` tidak boleh mengimpor Flutter atau paket data.
- Satu file ≤ ~300 baris; widget dipecah kecil; tidak ada logika di `build()`.

## 6. Kontrak API

- `packages/contracts` adalah sumber kebenaran antara app dan proxy.
- Urutan perubahan: **ubah kontrak → minta persetujuan → baru ubah kode**. Dilarang mengubah bentuk request/response secara diam-diam.
- Bentuk event SSE, kode error, dan batas ukuran harus tercantum di kontrak.

## 7. Gerbang Verifikasi (Definition of Done)

Jalankan semua yang relevan, lalu tempel ringkas outputnya di laporan:

**Mobile** (`apps/mobile`)
- `dart format --set-exit-if-changed .`
- `flutter analyze` → 0 issue
- `flutter test` → semua lulus
- `flutter build apk --debug` jika slice menyentuh konfigurasi native, permission, atau dependency

**Proxy** (`apps/proxy`)
- `npm run lint`
- `npm run typecheck`
- `npm test`

Logika baru **wajib** disertai test. Perubahan UI cukup disertai langkah tes manual yang jelas.
Jika ada gerbang yang tidak bisa dijalankan, katakan terus terang. Jangan mengarang hasilnya.

## 8. Keamanan

- Secret hanya ada di environment proxy (`wrangler secret`). `.env` masuk `.gitignore`; yang di-commit hanya `.env.example`.
- Aplikasi hanya berkomunikasi dengan proxy, tidak pernah langsung ke provider model.
- Proxy wajib: validasi token, rate limit, batas ukuran body, batas `max_tokens`, HTTPS only.
- **Jangan me-log isi prompt atau teks novel**, baik di proxy maupun di app.
- Data novel disimpan lokal di perangkat; tidak dikirim ke layanan pihak ketiga selain lewat proxy ke provider model.

## 9. UI/UX

- Nama asisten: **Caecilia**. Seluruh teks UI dalam **Bahasa Indonesia**.
- Beranda: sapaan "Apa yang bisa saya bantu hari ini?", logo di tengah, tombol titik tiga di kanan atas yang membuka drawer dashboard dari sisi **kanan**, dan kolom input prompt di bawah.
- Logo disediakan pemilik proyek. Pakai placeholder di `assets/brand/` sampai file asli ada. **Jangan membuat atau menghasilkan logo.**
- Material 3. Warna, tipografi, dan spacing dari satu tema terpusat di `core/`; dilarang hardcode warna di widget.
- Setiap layar harus menangani state loading, error, dan kosong. Input harus aman terhadap keyboard.

## 10. Konvensi kode dan git

- Tidak ada `print()`; gunakan logger di `core/`. Komentar hanya untuk menjelaskan *kenapa*.
- Satu slice = satu branch `slice/NN-nama-singkat`. Commit kecil, format Conventional Commits (`feat:`, `fix:`, `test:`, `chore:`, `docs:`).
- Jangan menyentuh branch `main` secara langsung.

## 11. Alur kerja tiap tugas

1. Baca `AGENT.md` dan `docs/ROADMAP.md`; sebutkan slice yang dikerjakan.
2. Tulis rencana singkat: file yang akan diubah dan hal yang **sengaja tidak** disentuh. Tunggu persetujuan jika melibatkan lebih dari 3 file, kontrak API, atau dependency baru.
3. Implementasi seminimal mungkin untuk memenuhi gerbang slice.
4. Jalankan Gerbang Verifikasi.
5. Kirim laporan (bagian 12).
6. **Berhenti.** Jangan lanjut ke slice berikutnya sebelum diminta.

## 12. Format laporan akhir

- **Slice:** nomor dan nama
- **File diubah / dibuat**
- **Dikerjakan** dan **sengaja tidak dikerjakan**
- **Output verifikasi** (perintah + hasil ringkas)
- **Cara tes manual** (langkah bernomor, hasil yang diharapkan)
- **Risiko, asumsi, dan pertanyaan terbuka**

## 13. Larangan eksplisit

- Mengerjakan lebih dari satu slice atau melompati urutan di ROADMAP
- Membuat fitur yang belum ada di slice aktif
- Menambah dependency, mengganti state management, atau mengubah arsitektur tanpa izin
- Menulis secret ke file mana pun yang masuk git
- Memanggil API model langsung dari aplikasi
- Menonaktifkan lint, mengubah aturan analyzer, atau menghapus test agar lulus
- Mengklaim sesuatu "sudah berjalan" tanpa menjalankannya