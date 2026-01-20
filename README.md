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
├── 📄 hitung_mse.m              # Kode utama untuk menghitung MSE
├── 📄 hitung_akurasi.m          # Kode utama untuk menghitung Akurasi
├── 📄 export_pixel_tables.m     # Export pixel values 9x9 ke CSV
├── 📄 README.md                 # Dokumentasi utama (file ini)
│
├── 📁 1_apple-image/            # Folder input (15 gambar apel)
├── 📁 2_plat-image/             # Folder input (15 gambar plat nomor)
│
├── 📁 image-hasil-mse/          # Output hasil perbaikan (75 gambar)
├── 📁 image-hasil-terbaik/      # Output hasil akurasi
│   ├── citra-asli/
│   ├── citra-asli-groundtruth/
│   ├── sobel-groundtruth/
│   ├── prewitt-groundtruth/
│   └── log-groundtruth/
│
├── 📁 Table-Mse/                # Tabel hasil MSE
├── 📁 Table-Accuration/         # Tabel hasil Akurasi
└── 📁 Pixel-Tables/             # Pixel values 9x9 (CSV)
```

---

## ⏱️ ESTIMASI WAKTU PENGERJAAN

| Script | Estimasi Waktu | Keterangan |
|--------|----------------|------------|
| `hitung_mse.m` | **3-5 menit** | 15 gambar × 5 filter × 3 metode edge |
| `hitung_akurasi.m` | **2-4 menit** | 15 gambar × 3 metode segmentasi |
| `export_pixel_tables.m` | **1-2 menit** | Export 165 file CSV |
| **TOTAL** | **~10 menit** | Untuk satu kali run lengkap |

---

## 🚀 CARA MENJALANKAN PROGRAM

### Langkah 1: Buka MATLAB
```matlab
>> cd 'C:\Users\Dan\Desktop\MATKUL5\PCD-UAS'
```

### Langkah 2: Jalankan `hitung_mse.m`
```matlab
>> hitung_mse
```

**Menu yang muncul:**
```
==========================================================
        PILIH FOLDER INPUT GAMBAR
==========================================================
1. 1_apple-image (Gambar Apel)
2. 2_plat-image (Gambar Plat Nomor)
==========================================================
Pilih folder (1/2): _

----------------------------------------------------------
  DITEMUKAN HASIL PENGOLAHAN SEBELUMNYA!
----------------------------------------------------------
1. Hapus hasil lama & proses ulang dari awal
2. Lanjutkan tanpa hapus (timpa file lama)
----------------------------------------------------------
Pilih (1/2): _
```

### Langkah 3: Jalankan `hitung_akurasi.m`
```matlab
>> hitung_akurasi
```

### Langkah 4: (Opsional) Export Pixel Tables
```matlab
>> export_pixel_tables
```

---

## 🔄 ALUR KERJA PROGRAM

### TAHAP 1: HITUNG_MSE.M

```
┌────────────────────────────────────────────────────────────┐
│                    HITUNG_MSE.M                            │
└────────────────────────────────────────────────────────────┘

[1] PILIH FOLDER INPUT
    └── 1_apple-image atau 2_plat-image

[2] CEK HASIL LAMA
    └── Pilih: Hapus atau Lanjutkan

[3] UNTUK SETIAP GAMBAR (15 gambar):
    │
    ├── [3.1] Baca gambar → Convert grayscale
    │
    ├── [3.2] TERAPKAN 5 FILTER:
    │   ├── Brightness +40
    │   ├── Contrast 15
    │   ├── Combination
    │   ├── Nonlinear (gamma=0.7)
    │   └── Histogram Equalization
    │
    ├── [3.3] EDGE DETECTION (3 metode × 6 gambar):
    │   ├── Sobel pada asli & 5 hasil filter
    │   ├── Prewitt pada asli & 5 hasil filter
    │   └── LoG pada asli & 5 hasil filter
    │
    └── [3.4] HITUNG MSE:
        └── MSE = Σ(edge_asli - edge_filter)² / (M×N)

[4] IDENTIFIKASI METODE TERBAIK
    ├── Hitung rata-rata MSE per kombinasi
    ├── Cari MSE terendah → Metode terbaik
    └── Cari gambar dengan MSE terendah → Gambar referensi

[5] SIMPAN HASIL:
    ├── 75 gambar → image-hasil-mse/
    ├── mse_table.txt → Table-Mse/
    └── best_method_info.mat → Table-Mse/
```

### TAHAP 2: HITUNG_AKURASI.M

```
┌────────────────────────────────────────────────────────────┐
│                  HITUNG_AKURASI.M                          │
└────────────────────────────────────────────────────────────┘

[1] LOAD METODE TERBAIK dari MSE
    └── bestMethodIdx, bestTechniqueIdx, bestImageName

[2] BUAT GROUND TRUTH REFERENSI (sekali saja):
    ├── Baca gambar terbaik dari MSE
    ├── Edge detection (metode terbaik)
    ├── Otsu thresholding
    └── Morfologi (Opening + Closing)

[3] UNTUK SETIAP GAMBAR (15 gambar):
    │
    ├── [3.1] Segmentasi dengan 3 metode:
    │   ├── Sobel → Otsu → Morfologi
    │   ├── Prewitt → Otsu → Morfologi
    │   └── LoG → Otsu → Morfologi
    │
    └── [3.2] HITUNG METRIK (vs GT Referensi):
        ├── Akurasi = (TP+TN) / Total × 100%
        ├── Sensitivitas = TP / (TP+FN) × 100%
        └── Spesifisitas = TN / (TN+FP) × 100%

[4] SIMPAN HASIL:
    ├── 75 gambar → image-hasil-terbaik/
    └── akurasi_table.txt → Table-Accuration/
```

---

## 📊 EXPORT PIXEL TABLES

Script `export_pixel_tables.m` mengekspor nilai pixel 9×9 (pojok kiri atas) ke CSV.

### Output:
```
Pixel-Tables/
├── 1_hasil_mse/
│   ├── 01_citra_asli/     (15 CSV)
│   ├── 02_brightness/     (15 CSV)
│   ├── 03_contrast/       (15 CSV)
│   ├── 04_combination/    (15 CSV)
│   ├── 05_nonlinear/      (15 CSV)
│   └── 06_improve/        (15 CSV)
│
└── 2_hasil_terbaik/
    ├── 01_citra_asli/     (15 CSV)
    ├── 02_ground_truth/   (15 CSV)
    ├── 03_sobel_gt/       (15 CSV)
    ├── 04_prewitt_gt/     (15 CSV)
    └── 05_log_gt/         (15 CSV)
```

**Total: 165 file CSV**

### Cara Membaca CSV:
```matlab
data = csvread('Pixel-Tables/1_hasil_mse/01_citra_asli/gambar1.csv');
disp(data);  % Menampilkan matriks 9x9
```

---

## ✅ VERIFIKASI: TIDAK ADA LIBRARY DEPENDENSI

### Fungsi yang DIPERBOLEHKAN (I/O File):
- `imread`, `imwrite` - Baca/tulis gambar
- `dir`, `exist`, `mkdir` - Operasi folder
- `fopen`, `fprintf`, `fclose` - Tulis file text
- `save`, `load` - Simpan/load .mat
- `csvwrite` - Tulis CSV

### Fungsi Core MATLAB (DIPERBOLEHKAN):
- `size`, `zeros`, `ones`, `double`, `uint8`
- `round`, `floor`, `max`, `min`, `sum`, `mean`, `sqrt`, `abs`
- `for`, `if`, `switch`, `while`

### Fungsi Image Processing: SEMUA MANUAL!

| Library Function | Pengganti Manual |
|------------------|------------------|
| ~~`rgb2gray`~~ | `rgb2gray_manual()` |
| ~~`edge`~~ | `sobel_edge_detection()`, `prewitt_edge_detection()`, `log_edge_detection()` |
| ~~`graythresh`~~ | `otsu_threshold_manual()` |
| ~~`imerode`~~ | `erosi_manual()` |
| ~~`imdilate`~~ | `dilasi_manual()` |
| ~~`imresize`~~ | `imresize_manual()` |
| ~~`histeq`~~ | `histogram_equalization_manual()` |
| ~~`imfilter`~~ | Konvolusi loop manual |

**TOTAL: 15 fungsi diimplementasi manual dari nol!**

---

## 🔬 FORMULA PERHITUNGAN

### 1. MSE (Mean Square Error)
```
MSE = (1/MN) × Σᵢ Σⱼ [f(i,j) - g(i,j)]²
```

### 2. Akurasi
```
Akurasi = (TP + TN) / (TP + TN + FP + FN) × 100%
```

### 3. Sensitivitas (Recall)
```
Sensitivitas = TP / (TP + FN) × 100%
```

### 4. Spesifisitas
```
Spesifisitas = TN / (TN + FP) × 100%
```

Dimana:
- **TP** = True Positive (benar mendeteksi edge)
- **TN** = True Negative (benar mendeteksi background)
- **FP** = False Positive (salah mendeteksi edge)
- **FN** = False Negative (gagal mendeteksi edge)

---

## 📝 CATATAN PENTING

1. **Urutan Eksekusi**: Jalankan `hitung_mse.m` **SEBELUM** `hitung_akurasi.m`
2. **Waktu Proses**: Total ~10 menit untuk 15 gambar
3. **Format Gambar**: Mendukung PNG, JPG, JPEG, BMP
4. **Ground Truth**: Dibuat dari gambar dengan MSE terbaik (referensi universal)
5. **Pilih Folder**: `hitung_mse.m` memiliki menu pilih folder input
6. **Hapus Hasil Lama**: Ada menu untuk menghapus hasil sebelumnya

---

## 👨‍💻 Author

**PCD-UAS Project**  
Pengolahan Citra Digital - Ujian Akhir Semester  
Tanggal: Januari 2026
