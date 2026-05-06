#import "@atalariq/lab-report:1.0.0": *
#import "@atalariq/code:1.0.0": *

#let metadata = (
  author: "…",
  id: "…",
  class: "…",
  course: "…",
  course-code: "…",
  lecturer: "…",
  meeting: "…",
  title: "…",
)

#show: report.with(
  ..metadata,
  association: (
    program: "Teknologi Rekayasa Perangkat Lunak",
    department: "Teknik Elektro dan Informatika",
    faculty: "Sekolah Vokasi",
    university: "Universitas Gadjah Mada",
    city: "Yogyakarta",
    logo: image("assets/logo.png", width: 6cm),
  ),
  year: 2026,
  use-cover: true,
  bib: bibliography("references.bib", style: "ieee"),
  font: "Times New Roman",
  code-font: "Fira Code",
  font-size: 12pt,
)

#set par(justify: true)
#set par(first-line-indent: (amount: 0.5in, all: true))
#set heading(numbering: "1.")
#set enum(numbering: "a.1.")

#let include-code(path, ..args) = code-from-file(read(path), lang: path.split(".").at(-1), ..args)
#let img(path, ..args) = image-wrapper(read(path, encoding: none), ..args)

#daftar-isi()
// #daftar-gambar()
// #daftar-tabel()

// ── Tujuan Praktikum ────────────────────────────────────────────────────────

= Tujuan Praktikum

#rect[
  TODO: Diisi pada Phase 1 / QUICK MODE.
]

// ── Dasar Teori ─────────────────────────────────────────────────────────────

= Dasar Teori

#rect[
  TODO: Diisi pada Phase 3A.
]

// ── Hasil dan Pembahasan ────────────────────────────────────────────────────

= Hasil dan Pembahasan

#rect[
  TODO: Menunggu kode sumber dari praktikan.
  Bagian ini akan diisi pada Phase 3B.
]

// ── Kesimpulan ───────────────────────────────────────────────────────────────

= Kesimpulan

#rect[
  TODO: Akan diisi setelah Hasil dan Pembahasan selesai (Phase 3B).
]
