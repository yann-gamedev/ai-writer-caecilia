# Kontrak API v0 — S03

Status: kontrak v0 disetujui pemilik pada 14 Oktober 2026. Dokumen ini tidak mengimplementasikan `/chat`.

- `openapi.json`: sumber skema request/response, autentikasi, dan pemetaan error HTTP.
- `sse.schema.json`: skema envelope event SSE setelah parsing, bukan format JSON wire.
- Tidak mengubah `/health` S02. Tidak ada dependency atau kode aplikasi dalam slice ini.

## Request dan batas

`POST /chat`, `Content-Type: application/json`, autentikasi HTTP Bearer.
Token aplikasi diverifikasi di proxy; API key model tidak pernah dikirim oleh app.
Model dipilih proxy melalui `MODEL_NAME`. Akses publik wajib HTTPS; HTTP hanya
untuk loopback pengembangan. Tidak ada nilai credential dalam contoh.

`messages` wajib berisi 1–100 pesan, dengan role `system`, `user`, atau `assistant`.
`content` berisi 1–16.000 Unicode code point. Tidak ada pemangkasan otomatis;
string kosong ditolak, whitespace tidak di-trim oleh kontrak v0.
Urutan pesan dipertahankan; v0 tidak mewajibkan role bergantian.
`stream` default `false`; `max_tokens` default 1.024, rentang 1–4.096.
Default diterapkan oleh implementasi ketika field tidak ada, bukan oleh validator.
Field tambahan ditolak. Konteks story bible kelak dapat disisipkan sebagai pesan;
tidak ada skema database atau context assembler pada S03.

| Batas | Nilai | Pengukuran |
|---|---:|---|
| Body request | 262.144 byte (256 KiB) | JSON UTF-8 sebelum parsing |
| Respons | 1.048.576 byte (1 MiB) | Body UTF-8; termasuk framing untuk SSE |
| Event SSE | 65.536 byte (64 KiB) | Seluruh frame UTF-8 termasuk pemisah baris kosong |

Panjang string pada JSON Schema bukan batas byte. Implementasi wajib memeriksa
keduanya. Batas respons berlaku juga pada error. Tidak ada truncation JSON/frame.
Respons non-stream yang melampaui batas menghasilkan `502 UPSTREAM_ERROR`.
Untuk streaming, pecah delta pada batas Unicode yang valid dan sisakan ruang
untuk event terminal; jika batas total akan terlampaui, akhiri dengan
`error` berkode `UPSTREAM_ERROR`, bukan `done`.

## Streaming

`stream=false` menghasilkan JSON; `stream=true` menghasilkan `text/event-stream`.
Pilihan ini ditentukan body request, bukan header Accept.
SSE dikodekan UTF-8; setiap frame memuat `event: <nama>` dan `data: <JSON>`,
diakhiri baris kosong. JSON di-escape normal, termasuk newline pada teks.
Parser menerima LF maupun CRLF dan menggabungkan beberapa baris `data:` dengan LF
sesuai SSE sebelum parse JSON. Pemisahan chunk jaringan tidak menentukan frame.
Baris komentar SSE diabaikan; tidak merepresentasikan delta atau event terminal.

Contoh wire sukses:

```text
event: delta
data: {"text":"Pagi itu."}

event: done
data: {"finish_reason":"stop"}

```

- Nol atau lebih `delta`, lalu tepat satu terminal `done` atau `error`.
- `delta.text` tidak kosong. Jawaban akhir adalah concatenation delta tanpa separator.
- `done.finish_reason`: `stop` untuk selesai normal; `length` jika batas generasi tercapai.
- `error` hanya menggunakan `INTERNAL_ERROR`, `UPSTREAM_ERROR`, atau `UPSTREAM_TIMEOUT`.
- Setelah terminal, tidak boleh ada event lain; server menutup stream.
- Tidak ada sentinel `[DONE]`, event ID, Last-Event-ID, atau replay/resume pada v0.
- EOF tanpa terminal, JSON/event invalid, atau frame melebihi batas adalah kegagalan
  protokol/stream terputus, bukan jawaban sukses. Teks parsial tidak dianggap final.
- Pembatalan oleh klien dapat menutup koneksi tanpa terminal; tidak dianggap sukses.
- Tidak ada retry otomatis. Percobaan ulang merupakan request baru dan bisa menghasilkan
  jawaban baru serta biaya tambahan.

Skema event memvalidasi envelope hasil parsing seperti berikut (bukan wire):

```json
{"event":"error","data":{"error":{"code":"UPSTREAM_ERROR","message":"Layanan model mengalami gangguan."}}}
```

## Error dan keamanan

Sebelum header streaming dikirim, gunakan HTTP error dan body `ErrorResponse`.
Sesudah header 200 dikirim, gunakan event terminal `error`; status HTTP tetap 200.
Validasi request dan autentikasi diselesaikan sebelum membuka stream.
Pemetaan kode wajib mengikuti deskripsi masing-masing status di `openapi.json`;
skema bersama `ErrorResponse` sendiri tidak menegakkan pasangan status/kode.
`405` pada `/chat` wajib menyertakan `Allow: POST`; `429` wajib menyertakan
`Retry-After` berupa detik nonnegatif. Kuota rate limit ditentukan pada S21.

Pesan error berbahasa Indonesia, tidak memuat secret, prompt, teks novel, atau
respons mentah provider. Dilarang mencatat body request/response novel ke log.
Konten novel memang dapat ada pada respons sukses; larangan kebocoran berlaku
untuk error dan log, bukan untuk jawaban yang diminta pengguna.

## Review dan verifikasi

1. Tinjau request, default, batas byte/karakter, dan response pada `openapi.json`.
2. Cocokkan contoh wire dengan envelope dan skema SSE.
3. Tinjau sukses, error sebelum/sesudah header, EOF tanpa terminal, dan limit output.
4. Berikan persetujuan kontrak v0 sebelum implementasi pada slice berikutnya.

Parsing JSON dan pemeriksaan referensi/contoh dengan tool bawaan bukan validasi
penuh OpenAPI atau JSON Schema. Urutan stream, batas byte, dan status/kode error
memerlukan pemeriksaan semantik di luar JSON Schema. Tidak perlu menjalankan
Flutter/Worker untuk slice dokumen ini; lint/test aplikasi tidak membuktikan
kebenaran kontrak. Persetujuan hasil review pemilik telah diterima untuk penutupan S03.
