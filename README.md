# 🖼️ PCD-UAS: Pengolahan Citra Digital - Ujian Akhir Semester

## 📋 Deskripsi Proyek

Proyek ini merupakan implementasi **Pengolahan Citra Digital** untuk melakukan:
1. **Perbaikan Citra** menggunakan berbagai teknik enhancement
2. **Deteksi Tepi** menggunakan metode Sobel, Prewitt, dan LoG
3. **Segmentasi Citra** menggunakan Otsu Thresholding
4. **Operasi Morfologi** (Opening dan Closing)
5. **Evaluasi Performa** dengan menghitung MSE, Akurasi, Sensitivitas, dan Spesifisitas

---

## 📁 Struktur Folder

```
PCD-UAS/
│
├── 📄 hitung_mse.m              # Kode utama untuk menghitung MSE (dengan pilih folder)
├── 📄 hitung_akurasi.m          # Kode utama untuk menghitung Akurasi
├── 📄 export_pixel_tables.m     # Export pixel values 9x9 ke CSV
├── 📄 README.md                 # Dokumentasi utama
├── 📄 ALUR_KERJA_PROGRAM.md     # Dokumentasi alur kerja lengkap
├── 📄 PIXEL_TABLES_README.md    # Dokumentasi export pixel tables
│
├── 📁 1_apple-image/            # Folder input (gambar apel)
│   └── ... (gambar apel)
│
├── 📁 2_plat-image/             # Folder input (gambar plat nomor)
│   ├── plat_nomor_01_clear.png
│   ├── plat_nomor_02_blur.png
│   ├── plat_nomor_03_noisy.png
│   ├── ... (15 gambar)
│   └── plat_nomor_15_shadow.png
│
├── 📁 image-hasil-mse/          # Output hasil perbaikan citra (dari MSE)
│   ├── plat_nomor_01_brightness40.png
│   ├── plat_nomor_01_contrast15.png
│   ├── plat_nomor_01_combination.png
│   ├── plat_nomor_01_nonlinear.png
│   ├── plat_nomor_01_improve.png
│   └── ... (75 gambar total: 15 × 5 teknik)
│
├── 📁 image-hasil-terbaik/      # Output hasil akurasi
│   ├── 📁 citra-asli/           # Citra asli (copy dari folder input)
│   ├── 📁 citra-asli-groundtruth/  # Ground Truth (dari hasil MSE terbaik)
│   ├── 📁 sobel-groundtruth/    # Hasil segmentasi Sobel
│   ├── 📁 prewitt-groundtruth/  # Hasil segmentasi Prewitt
│   └── 📁 log-groundtruth/      # Hasil segmentasi LoG
│
├── 📁 Table-Mse/                # Tabel hasil MSE
│   ├── mse_table.txt
│   └── best_method_info.mat
│
├── 📁 Table-Accuration/         # Tabel hasil Akurasi
│   └── akurasi_table.txt
│
└── 📁 Pixel-Tables/             # Pixel values 9x9 dalam format CSV
    ├── 1_hasil_mse/             # Pixel dari proses MSE
    └── 2_hasil_terbaik/         # Pixel dari proses akurasi
```

---

## 🔬 Proses Penghitungan

### **TAHAP 1: Perbaikan Citra & Perhitungan MSE** (`hitung_mse.m`)

#### 1.1 Teknik Perbaikan Citra (5 Metode)

| No | Teknik | Deskripsi | Formula |
|----|--------|-----------|---------|
| 1 | **Brightness +40** | Menambahkan nilai 40 ke setiap piksel | `I' = I + 40` |
| 2 | **Contrast 15** | Meningkatkan kontras dengan faktor 15% | `I' = (I - mean) × 1.15 + mean` |
| 3 | **Combination** | Kombinasi Brightness + Contrast | Brightness kemudian Contrast |
| 4 | **Nonlinear Mapping** | Power Law Transformation (Gamma = 0.7) | `I' = c × I^γ` |
| 5 | **Improve Brightness** | Histogram Equalization | `I' = CDF(I) × 255` |

#### 1.2 Metode Edge Detection (3 Metode)

| No | Metode | Kernel Gx | Kernel Gy |
|----|--------|-----------|-----------|
| 1 | **Sobel** | `[-1 0 1; -2 0 2; -1 0 1]` | `[-1 -2 -1; 0 0 0; 1 2 1]` |
| 2 | **Prewitt** | `[-1 0 1; -1 0 1; -1 0 1]` | `[-1 -1 -1; 0 0 0; 1 1 1]` |
| 3 | **LoG** | Gaussian smoothing + Laplacian | σ = 1.4, kernel 5×5 |

#### 1.3 Perhitungan MSE (Mean Square Error)

```
MSE = (1/MN) × Σ Σ [f(i,j) - g(i,j)]²
```

Dimana:
- `f(i,j)` = Edge detection dari citra asli
- `g(i,j)` = Edge detection dari citra hasil perbaikan
- `M × N` = Ukuran citra

**Interpretasi**: MSE yang **lebih rendah** menunjukkan hasil perbaikan yang **lebih baik**.

---

### **TAHAP 2: Segmentasi, Morfologi & Akurasi** (`hitung_akurasi.m`)

#### 2.1 Membuat Ground Truth
1. Menggunakan hasil perbaikan **terbaik dari MSE** (teknik + metode edge detection terbaik)
2. Terapkan **Otsu Thresholding**
3. Terapkan **Morfologi** (Opening + Closing)
4. Simpan sebagai **Ground Truth** di folder `citra-asli-groundtruth/`

#### 2.2 Proses Segmentasi untuk Setiap Gambar

```
Citra Asli → 3 Metode Edge Detection → Otsu Threshold → Morfologi → Hasil GT
```

**3 Metode Segmentasi:**
1. **Sobel** → threshold → morfologi → simpan di `sobel-groundtruth/`
2. **Prewitt** → threshold → morfologi → simpan di `prewitt-groundtruth/`
3. **LoG** → threshold → morfologi → simpan di `log-groundtruth/`

#### 2.3 Operasi Morfologi

| Operasi | Deskripsi | Urutan |
|---------|-----------|--------|
| **Opening** | Menghilangkan noise kecil | Erosi → Dilasi |
| **Closing** | Menutup lubang-lubang kecil | Dilasi → Erosi |

Structuring Element: **3×3** (semua bernilai 1)

#### 2.4 Perhitungan Metrik Evaluasi

**Perbandingan:**
- Ground Truth (dari MSE terbaik) **VS** Sobel GT → Akurasi, Sensitivitas, Spesifisitas
- Ground Truth (dari MSE terbaik) **VS** Prewitt GT → Akurasi, Sensitivitas, Spesifisitas
- Ground Truth (dari MSE terbaik) **VS** LoG GT → Akurasi, Sensitivitas, Spesifisitas

| Metrik | Formula | Deskripsi |
|--------|---------|-----------|
| **Akurasi** | `(TP + TN) / (TP + TN + FP + FN) × 100%` | Persentase piksel yang terklasifikasi dengan benar |
| **Sensitivitas** | `TP / (TP + FN) × 100%` | Kemampuan mendeteksi objek positif (True Positive Rate) |
| **Spesifisitas** | `TN / (TN + FP) × 100%` | Kemampuan mendeteksi latar belakang (True Negative Rate) |

Dimana:
- **TP (True Positive)**: Ground Truth = 1 DAN Prediksi = 1
- **TN (True Negative)**: Ground Truth = 0 DAN Prediksi = 0
- **FP (False Positive)**: Ground Truth = 0 DAN Prediksi = 1
- **FN (False Negative)**: Ground Truth = 1 DAN Prediksi = 0

---

## 🚀 Cara Menjalankan Program

### **Prasyarat**
- MATLAB R2018a atau lebih baru
- Image Processing Toolbox (untuk fungsi `padarray`)

### **Langkah-langkah Eksekusi**

#### **Langkah 1: Buka MATLAB**
Buka MATLAB dan navigasi ke folder proyek:
```matlab
cd 'C:\Users\Dan\Desktop\MATKUL5\PCD-UAS'
```

#### **Langkah 2: Jalankan `hitung_mse.m`** ⚠️ WAJIB DULUAN!
```matlab
>> hitung_mse
```

**User akan diminta memilih folder:**
```
==========================================================
        PILIH FOLDER INPUT GAMBAR
==========================================================
1. 1_apple-image (Gambar Apel)
2. 2_plat-image (Gambar Plat Nomor)
==========================================================
Pilih folder (1/2): 2  ← Ketik 1 atau 2, lalu Enter
```

**Proses yang terjadi:**
1. Membaca 15 gambar dari folder yang dipilih
2. Menerapkan 5 teknik perbaikan ke setiap gambar
3. Menerapkan 3 metode edge detection
4. Menghitung MSE untuk setiap kombinasi
5. Menentukan metode dan teknik terbaik
6. Menyimpan hasil ke `image-hasil-mse/` dan `Table-Mse/`

**Output:**
- ✅ 75 gambar hasil perbaikan di `image-hasil-mse/`
- ✅ File `Table-Mse/mse_table.txt`
- ✅ File `Table-Mse/best_method_info.mat`

**Estimasi waktu:** ~2-5 menit (tergantung spesifikasi komputer)

#### **Langkah 3: Jalankan `hitung_akurasi.m`**
```matlab
>> hitung_akurasi
```

**Catatan:** Script ini menggunakan folder **`2_plat-image`** secara default (tidak ada pilihan folder).

**Proses yang terjadi:**
1. Membaca informasi metode terbaik dari MSE
2. Membuat Ground Truth dari citra referensi
3. Memproses setiap gambar dengan:
   - Perbaikan citra (teknik terbaik)
   - Edge detection (metode terbaik)
   - Segmentasi Otsu
   - Morfologi (Opening + Closing)
4. Menghitung Akurasi, Sensitivitas, Spesifisitas
5. Menyimpan hasil ke `image-hasil-terbaik/` dan `Table-Accuration/`

**Output:**
- ✅ Gambar hasil akhir di `image-hasil-terbaik/`
- ✅ File `Table-Accuration/akurasi_table.txt`

**Estimasi waktu:** ~2-5 menit

---

## 📊 Membaca Hasil

### **Tabel MSE** (`Table-Mse/mse_table.txt`)

```
========================================================================================
METODE 1: SOBEL
----------------------------------------------------------------------------------------
| No | Image Name                   | Bright40   | Contrast15 | Combi      | Nonlinear  | Improve    |
----------------------------------------------------------------------------------------
|  1 | plat_nomor_01_clear.png      |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |
...
========================================================================================
KESIMPULAN:
- Metode Edge Detection Terbaik : Sobel
- Teknik Perbaikan Terbaik      : Improve_Brightness
- MSE Rata-rata Terendah        : xxxx.xxxx
========================================================================================
```

### **Tabel Akurasi** (`Table-Accuration/akurasi_table.txt`)

```
========================================================================================
| No | Image Name                   | Akurasi (%) | Sensitivitas (%) | Spesifisitas (%) |
----------------------------------------------------------------------------------------
|  1 | plat_nomor_01_clear.png      |       95.50 |            92.30 |            97.80 |
...
----------------------------------------------------------------------------------------
| RATA-RATA                        |       xx.xx |            xx.xx |            xx.xx |
========================================================================================
```

---

## 📈 Diagram Alur Proses

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              ALUR KERJA PROGRAM                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌─────────────┐
                                    │  15 GAMBAR  │
                                    │  (image/)   │
                                    └──────┬──────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    ▼                      ▼                      ▼
            ┌───────────────┐      ┌───────────────┐      ┌───────────────┐
            │  BRIGHTNESS   │      │   CONTRAST    │      │  COMBINATION  │
            │     +40       │      │      15       │      │  Bright+Cont  │
            └───────┬───────┘      └───────┬───────┘      └───────┬───────┘
                    │                      │                      │
                    └──────────────────────┼──────────────────────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    ▼                      ▼                      ▼
            ┌───────────────┐      ┌───────────────┐      ┌───────────────┐
            │    SOBEL      │      │   PREWITT     │      │     LoG       │
            │ Edge Detect   │      │ Edge Detect   │      │ Edge Detect   │
            └───────┬───────┘      └───────┬───────┘      └───────┬───────┘
                    │                      │                      │
                    └──────────────────────┼──────────────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │ HITUNG MSE  │
                                    │ vs Original │
                                    └──────┬──────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │    TABEL MSE.txt       │
                              │ + best_method_info.mat │
                              └────────────┬───────────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │   METODE TERBAIK       │
                              │ (MSE Terendah)         │
                              └────────────┬───────────┘
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    │                                              │
                    ▼                                              ▼
            ┌───────────────┐                              ┌───────────────┐
            │ GROUND TRUTH  │                              │ GAMBAR HASIL  │
            │ (plat_11_     │                              │  PERBAIKAN    │
            │  sharp.png)   │                              │   TERBAIK     │
            └───────┬───────┘                              └───────┬───────┘
                    │                                              │
                    ▼                                              ▼
            ┌───────────────┐                              ┌───────────────┐
            │    OTSU       │                              │ EDGE DETECT   │
            │ THRESHOLD     │                              │ (Metode Best) │
            └───────┬───────┘                              └───────┬───────┘
                    │                                              │
                    │                                              ▼
                    │                                      ┌───────────────┐
                    │                                      │    OTSU       │
                    │                                      │ SEGMENTASI    │
                    │                                      └───────┬───────┘
                    │                                              │
                    │                                              ▼
                    │                                      ┌───────────────┐
                    │                                      │  MORFOLOGI    │
                    │                                      │ Opening+Close │
                    │                                      └───────┬───────┘
                    │                                              │
                    └──────────────────────┬───────────────────────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │   HITUNG AKURASI       │
                              │ - Akurasi              │
                              │ - Sensitivitas         │
                              │ - Spesifisitas         │
                              └────────────┬───────────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │  TABEL AKURASI.txt     │
                              │ + Gambar Hasil Akhir   │
                              └────────────────────────┘
```

---

## ⚙️ Fungsi-Fungsi yang Diimplementasikan

### Fungsi Perbaikan Citra
| Fungsi | Deskripsi |
|--------|-----------|
| `brightness_adjustment()` | Menambahkan nilai brightness |
| `contrast_adjustment()` | Meningkatkan kontras |
| `power_law_transform()` | Gamma correction |
| `histogram_equalization_manual()` | Histogram equalization |

### Fungsi Edge Detection
| Fungsi | Deskripsi |
|--------|-----------|
| `sobel_edge_detection()` | Deteksi tepi menggunakan Sobel |
| `prewitt_edge_detection()` | Deteksi tepi menggunakan Prewitt |
| `log_edge_detection()` | Deteksi tepi menggunakan LoG |

### Fungsi Segmentasi & Morfologi
| Fungsi | Deskripsi |
|--------|-----------|
| `otsu_threshold_manual()` | Thresholding Otsu |
| `erosi_manual()` | Operasi erosi |
| `dilasi_manual()` | Operasi dilasi |

### Fungsi Evaluasi
| Fungsi | Deskripsi |
|--------|-----------|
| `hitung_mse()` | Menghitung Mean Square Error |
| `hitung_metrik_segmentasi()` | Menghitung Akurasi, Sensitivitas, Spesifisitas |

---

## 📝 Catatan Penting

1. **Urutan Eksekusi**: Selalu jalankan `hitung_mse.m` **SEBELUM** `hitung_akurasi.m`
2. **Waktu Proses**: Total waktu proses sekitar 5-10 menit untuk 15 gambar
3. **Ukuran Gambar**: Format PNG, ukuran bervariasi
4. **Pilih Folder**: `hitung_mse.m` memiliki fitur pilih folder (apple/plat), `hitung_akurasi.m` menggunakan `2_plat-image` secara default
5. **Ground Truth**: Dibuat dari hasil perbaikan terbaik MSE untuk setiap gambar
6. **Export Pixel**: Gunakan `export_pixel_tables.m` untuk mengekspor nilai pixel 9x9 ke CSV

---

## 👨‍💻 Author

**PCD-UAS Project**  
Pengolahan Citra Digital - Ujian Akhir Semester  
Tanggal: 19 Januari 2026

---

## 📜 License

Proyek ini dibuat untuk keperluan akademik.
