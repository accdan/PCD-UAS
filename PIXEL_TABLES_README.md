# 📊 EXPORT PIXEL TABLES - Documentation

## 🎯 Tujuan
Script `export_pixel_tables.m` digunakan untuk mengekspor nilai pixel 9x9 (pojok kiri atas) dari semua tahap pemrosesan citra ke format CSV untuk keperluan analisis dan dokumentasi.

---

## 📁 Struktur Output

```
Pixel-Tables/
├── 1_hasil_mse/                    # Hasil dari proses MSE
│   ├── 01_citra_asli/              # Citra asli (grayscale)
│   │   ├── plat_nomor_01_original.csv
│   │   ├── plat_nomor_02_original.csv
│   │   └── ... (15 files)
│   │
│   ├── 02_brightness/              # Hasil Brightness +40
│   │   ├── plat_nomor_01_brightness.csv
│   │   └── ... (15 files)
│   │
│   ├── 03_contrast/                # Hasil Contrast 15
│   │   └── ... (15 files)
│   │
│   ├── 04_combination/             # Hasil Combination
│   │   └── ... (15 files)
│   │
│   ├── 05_nonlinear/               # Hasil Nonlinear Mapping
│   │   └── ... (15 files)
│   │
│   └── 06_improve/                 # Hasil Histogram Equalization
│       └── ... (15 files)
│
└── 2_hasil_terbaik/                # Hasil dari proses Akurasi
    ├── 01_citra_asli/              # Citra asli (copy)
    │   └── ... (15 files)
    │
    ├── 02_ground_truth/            # Ground Truth (GT terbaik)
    │   ├── plat_nomor_01_gt.csv
    │   └── ... (15 files)
    │
    ├── 03_sobel_gt/                # Segmentasi Sobel
    │   └── ... (15 files)
    │
    ├── 04_prewitt_gt/              # Segmentasi Prewitt
    │   └── ... (15 files)
    │
    └── 05_log_gt/                  # Segmentasi LoG
        └── ... (15 files)
```

**Total Files**: 15 gambar × 11 stages = **165 CSV files**

---

## 🚀 Cara Menjalankan

### Prasyarat
1. **Sudah menjalankan** `hitung_mse.m` (untuk generate hasil MSE)
2. **Sudah menjalankan** `hitung_akurasi.m` (untuk generate hasil GT)
3. Folder berikut harus ada:
   - `2_plat-image/` (citra asli)
   - `image-hasil-mse/` (hasil perbaikan)
   - `image-hasil-terbaik/` (hasil segmentasi)

### Langkah Eksekusi

```matlab
>> cd 'C:\Users\Dan\Desktop\MATKUL5\PCD-UAS'
>> export_pixel_tables
```

**Output:**
```
========================================================================
              EXPORT PIXEL VALUES TO CSV
              9x9 Pixels (Top-Left Corner)
========================================================================

Creating folder structure...
✓ Folder structure created!

Found 15 images to process

[1/15] Processing: plat_nomor_01_clear.png
  ✓ Exported all pixel tables for plat_nomor_01_clear.png

[2/15] Processing: plat_nomor_02_blur.png
  ✓ Exported all pixel tables for plat_nomor_02_blur.png

...

========================================================================
EXPORT COMPLETED!
========================================================================
Total CSV files generated: 165
Output folder: Pixel-Tables
========================================================================
```

---

## 📊 Format CSV

### Contoh: `plat_nomor_01_original.csv`

```csv
120,125,130,135,140,145,150,155,160
122,127,132,137,142,147,152,157,162
124,129,134,139,144,149,154,159,164
126,131,136,141,146,151,156,161,166
128,133,138,143,148,153,158,163,168
130,135,140,145,150,155,160,165,170
132,137,142,147,152,157,162,167,172
134,139,144,149,154,159,164,169,174
136,141,146,151,156,161,166,171,176
```

**Keterangan:**
- **9 baris** × **9 kolom**
- Nilai pixel dari **pojok kiri atas** gambar
- Rentang nilai:
  - **0-255**: untuk citra grayscale
  - **0 atau 1**: untuk citra binary (Ground Truth)

---

## 📖 Cara Membaca CSV

### Di Excel / Google Sheets
1. Buka file CSV
2. Data akan muncul dalam format tabel 9×9
3. Kolom = kolom pixel (kiri ke kanan)
4. Baris = baris pixel (atas ke bawah)

### Di MATLAB
```matlab
% Membaca CSV
data = csvread('Pixel-Tables/1_hasil_mse/01_citra_asli/plat_nomor_01_original.csv');

% Menampilkan
disp('Pixel values 9x9:');
disp(data);

% Visualisasi sebagai heatmap
imagesc(data);
colormap(gray);
colorbar;
title('9x9 Pixel Values');
```

### Di Python
```python
import pandas as pd
import numpy as np

# Membaca CSV
data = pd.read_csv('Pixel-Tables/1_hasil_mse/01_citra_asli/plat_nomor_01_original.csv', header=None)

# Tampilkan
print(data)

# Visualisasi
import matplotlib.pyplot as plt
plt.imshow(data, cmap='gray')
plt.colorbar()
plt.title('9x9 Pixel Values')
plt.show()
```

---

## 🔍 Analisis Data

### Perbandingan Antar Filter

```matlab
% Baca semua filter untuk gambar tertentu
baseName = 'plat_nomor_01';
baseFolder = 'Pixel-Tables/1_hasil_mse/';

original = csvread([baseFolder '01_citra_asli/' baseName '_original.csv']);
brightness = csvread([baseFolder '02_brightness/' baseName '_brightness.csv']);
contrast = csvread([baseFolder '03_contrast/' baseName '_contrast.csv']);

% Hitung selisih
diff_bright = brightness - original;
diff_contrast = contrast - original;

fprintf('Mean difference (Brightness): %.2f\n', mean(diff_bright(:)));
fprintf('Mean difference (Contrast): %.2f\n', mean(diff_contrast(:)));
```

### Perbandingan Ground Truth vs Segmentasi

```matlab
% Baca GT dan segmentasi
baseFolder = 'Pixel-Tables/2_hasil_terbaik/';

gt = csvread([baseFolder '02_ground_truth/plat_nomor_01_gt.csv']);
sobel = csvread([baseFolder '03_sobel_gt/plat_nomor_01_sobel_gt.csv']);

% Hitung akurasi untuk 9x9 pixel
matches = gt == sobel;
accuracy_9x9 = sum(matches(:)) / numel(gt) * 100;

fprintf('Akurasi 9x9 pixel: %.2f%%\n', accuracy_9x9);
```

---

## 📝 File Summary

Script ini juga menghasilkan file **`SUMMARY_REPORT.txt`** yang berisi:
- Total gambar yang diproses
- Struktur folder lengkap
- Jumlah file per kategori
- Petunjuk penggunaan

Lokasi: `Pixel-Tables/SUMMARY_REPORT.txt`

---

## ⚠️ Catatan Penting

1. **Ukuran Gambar**: Jika gambar kurang dari 9×9, akan di-pad dengan nilai 0
2. **Format**: Semua nilai disimpan sebagai angka desimal (double precision)
3. **Encoding**: File CSV menggunakan encoding standard (ASCII)
4. **Separator**: Menggunakan koma (,) sebagai delimiter

---

## 🛠️ Troubleshooting

### Error: "File not found"
**Solusi**: Pastikan sudah menjalankan `hitung_mse.m` dan `hitung_akurasi.m` terlebih dahulu

### CSV tidak terbuka dengan benar di Excel
**Solusi**: 
- Gunakan "File → Import Data" di Excel
- Pilih delimiter: Koma
- Data type: Number

### Nilai pixel tidak sesuai
**Solusi**: Periksa apakah gambar sudah di-convert ke grayscale

---

## 📊 Kegunaan Data Pixel

Data CSV ini berguna untuk:
1. ✅ **Validasi proses**: Memastikan filter bekerja dengan benar
2. ✅ **Analisis kuantitatif**: Menghitung statistik pixel
3. ✅ **Dokumentasi**: Lampiran untuk laporan/jurnal
4. ✅ **Debugging**: Memeriksa nilai pixel spesifik
5. ✅ **Perbandingan**: Membandingkan hasil berbagai metode

---

## 👨‍💻 Author
PCD-UAS Project - 2026
