# ROADMAP — Caecilia

Simpan sebagai `docs/ROADMAP.md`. Kerjakan **berurutan**. Satu slice per sesi. Slice baru boleh dimulai hanya jika slice sebelumnya berstatus `[x]` dan sudah dites manual oleh pemilik proyek.

**Aturan pemecahan:** jika sebuah slice ternyata butuh lebih dari ~5 file atau lebih dari satu tanggung jawab, pecah menjadi sub-slice (S24a, S24b, ...) dan minta persetujuan sebelum lanjut.

Setiap slice punya **Gerbang**: syarat yang harus terpenuhi sebelum boleh dinyatakan selesai (di luar Gerbang Verifikasi standar di AGENT.md).

---

## Fase 0 — Fondasi (tanpa fitur)

- [x] **S00 — Skeleton repo.** Struktur folder, `.gitignore`, `.env.example`, AGENT.md, ROADMAP.md. *Gerbang:* tidak ada kode fitur; struktur sesuai AGENT.md.
- [ ] **S01 — Flutter kosong.** Proyek di `apps/mobile`, tema dasar, satu halaman placeholder. *Gerbang:* berjalan di emulator; analyze dan test lulus.
- [ ] **S02 — Proxy kosong.** Worker dengan `GET /health`. *Gerbang:* `curl` mengembalikan 200; ada satu test.
- [ ] **S03 — Kontrak API v0.** Skema `/chat` (request, response, event SSE, kode error) di `packages/contracts`. *Gerbang:* hanya dokumen/skema, tanpa kode lain; disetujui pemilik.
- [ ] **S04 — Script verifikasi.** `scripts/verify.sh` menjalankan semua gerbang mobile dan proxy. *Gerbang:* satu perintah, hasil lulus/gagal jelas.

## Fase 1 — UI statis (tanpa jaringan)

- [ ] **S10 — Beranda statis.** Sapaan, logo placeholder di tengah, input bar. Tanpa fungsi. *Gerbang:* tampilan sesuai spek, aman dari keyboard.
- [ ] **S11 — Drawer kanan.** Titik tiga kanan atas membuka drawer dari kanan, isi masih kosong/placeholder. *Gerbang:* buka-tutup lancar, drawer benar-benar dari kanan.
- [ ] **S12 — Layar chat lokal.** Bubble pesan user dan AI (dummy), kirim menambah bubble user. *Gerbang:* scroll otomatis ke bawah; tanpa network.
- [ ] **S13 — Transisi beranda ke chat.** Setelah kirim pertama, beranda berganti ke layar chat. *Gerbang:* tidak ada flicker; state konsisten.

## Fase 2 — Proxy dan streaming

- [ ] **S20 — `/chat` mock non-stream.** Mengembalikan jawaban palsu. *Gerbang:* sesuai kontrak; test lulus.
- [ ] **S21 — Pengaman proxy.** Validasi token, rate limit, batas body dan `max_tokens`. *Gerbang:* test untuk tiap penolakan (401, 429, 413).
- [ ] **S22 — `/chat` SSE mock.** Stream token palsu. *Gerbang:* bisa dites dengan `curl -N`.
- [ ] **S23 — Klien SSE di app.** Hanya lapisan data + unit test, tanpa UI. *Gerbang:* test parsing event, termasuk event putus.
- [ ] **S24 — Hubungkan chat UI ke stream mock.** *Gerbang:* teks muncul bertahap di emulator.
- [ ] **S25 — Proxy ke API model asli (non-stream).** Satu model, key di `wrangler secret`. *Gerbang:* key tidak ada di repo; jawaban asli diterima.
- [ ] **S26 — Streaming asli.** *Gerbang:* stream asli tampil bertahap di app.
- [ ] **S27 — Penanganan error.** Timeout, retry terbatas, tombol Stop, pesan error ramah. *Gerbang:* tes manual: matikan jaringan, tekan Stop.

## Fase 3 — Persistensi

- [ ] **S30 — Skema Drift percakapan dan pesan.** Tanpa UI. *Gerbang:* test repository.
- [ ] **S31 — Simpan pesan saat chat.** *Gerbang:* tutup dan buka app, pesan tetap ada.
- [ ] **S32 — Riwayat di drawer.** Daftar percakapan, buka percakapan lama. *Gerbang:* urutan terbaru di atas.
- [ ] **S33 — Rename dan hapus percakapan.** Dengan konfirmasi hapus. *Gerbang:* data benar-benar terhapus.

## Fase 4 — Story bible

- [ ] **S40 — Skema Drift novel/proyek, karakter, setting.** Tanpa UI. *Gerbang:* migrasi dan test repository.
- [ ] **S41 — CRUD proyek novel.** *Gerbang:* tes manual lengkap (buat, ubah, hapus).
- [ ] **S42 — CRUD karakter dan setting.** *Gerbang:* terikat ke proyek yang benar.
- [ ] **S43 — Outline dan ringkasan bab.** *Gerbang:* urutan bab bisa diubah.
- [ ] **S44 — Context assembler.** Menyusun prompt dari story bible dengan batas token. Tanpa UI. *Gerbang:* unit test: urutan, pemotongan saat melebihi batas, dan hasil deterministik.
- [ ] **S45 — Proyek aktif di chat.** Konteks disisipkan otomatis ke request. *Gerbang:* tes manual: jawaban konsisten dengan data karakter.

## Fase 5 — Penulisan lanjutan

- [ ] **S50 — Ringkasan bergulir otomatis.** *Gerbang:* ringkasan tersimpan dan ikut masuk konteks.
- [ ] **S51 — Simpan hasil AI sebagai draf bab.** *Gerbang:* draf bisa dibuka dan diedit.
- [ ] **S52 — Ekspor teks/docx.** *Gerbang:* file terbuka benar di aplikasi lain.
- [ ] **S53 — Tombol "Periksa konsistensi".** Satu panggilan, bukan pipeline. *Gerbang:* menandai kontradiksi terhadap story bible pada contoh uji.
- [ ] **S54 — Tool-calling (opsional).** Hanya jika S53 terbukti kurang. Perlu persetujuan desain terlebih dulu.

## Fase 6 — Penyelesaian

- [ ] **S60 — Logo asli, ikon, splash.**
- [ ] **S61 — Batas biaya dan penggunaan.** Batas harian di proxy, indikator di app.
- [ ] **S62 — Build release dan signing.**

---

## Template prompt per slice

```
Kerjakan slice SXX dari docs/ROADMAP.md. Ikuti AGENT.md.
Tujuan: <satu kalimat>.
Batasan: hanya slice ini; jangan menyentuh <area yang tidak boleh>.
Mulai dengan rencana (file yang diubah, yang tidak disentuh), tunggu OK saya.
Setelah selesai, jalankan Gerbang Verifikasi dan kirim laporan sesuai format.
```

## Template laporan tes dari pemilik proyek

```
Slice: SXX
Hasil tes manual: lulus / gagal
Langkah yang saya jalankan: ...
Yang terjadi vs yang diharapkan: ...
Log / screenshot: ...
```