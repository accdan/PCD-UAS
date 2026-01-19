# ✅ PERUBAHAN SISTEM GROUND TRUTH

## 📊 KONSEP BARU: GROUND TRUTH REFERENSI

Berdasarkan permintaan, saya telah mengubah sistem Ground Truth dari **per-gambar** menjadi **menggunakan 1 gambar referensi terbaik** dari hasil MSE.

---

## 🔄 APA YANG BERUBAH?

### **SEBELUM (Ground Truth Per-Gambar)**

```
Untuk SETIAP GAMBAR:
├── Hasil perbaikan terbaik MSE
├── Edge detection (metode terbaik)
├── Otsu thresholding  
├── Morfologi
└── → Ground Truth UNIK untuk gambar tersebut

Perbandingan: GT gambar 1 vs Segmentasi gambar 1
              GT gambar 2 vs Segmentasi gambar 2
              ... dst
```

### **SESUDAH (Ground Truth Referensi Universal)** ✅

```
1. Identifikasi GAMBAR TERBAIK (MSE terendah)
2. Buat Ground Truth REFERENSI dari gambar terbaik:
   ├── Hasil perbaikan terbaik MSE
   ├── Edge detection (metode terbaik)
   ├── Otsu thresholding
   └── Morfologi

3. Untuk SETIAP GAMBAR:
   ├── Segmentasi dengan 3 metode (Sobel, Prewitt, LoG)
   └── Bandingkan dengan GT REFERENSI yang sama

Perbandingan: GT Referensi vs Segmentasi gambar 1
              GT Referensi vs Segmentasi gambar 2
              ... dst (semua dibandingkan dengan GT yang SAMA)
```

---

## 🎯 KEUNTUNGAN SISTEM BARU

| Aspek | Per-Gambar (Lama) | Referensi (Baru) |
|-------|-------------------|------------------|
| **Konsistensi** | Berbeda untuk tiap gambar | Sama untuk semua gambar |
| **Benchmark** | Tidak ada standar universal | Ada standar referensi tetap |
| **Interpretasi** | Relatif terhadap diri sendiri | Absolut terhadap referensi terbaik |
| **Perbandingan** | Sulit membandingkan antar gambar | Mudah membandingkan performance |

---

## 📝 PERUBAHAN KODE

### **File 1: `hitung_mse.m`**

#### **Penambahan (Setelah Line 222):**

```matlab
%% Tentukan Gambar Referensi Terbaik (MSE Terendah)
mseValues = MSE_Results(bestMethodIdx, bestTechniqueIdx, :);
[minMSE_image, bestImageIdx] = min(mseValues);
bestImageName = imageNamesList{bestImageIdx};

% Tambahkan ke mse_table.txt
fprintf(fid, '\n===========================================\n');
fprintf(fid, '     GAMBAR REFERENSI TERBAIK\n');
fprintf(fid, '===========================================\n');
fprintf(fid, '  - Nama Gambar  : %s\n', bestImageName);
fprintf(fid, '  - Index        : %d\n', bestImageIdx);
fprintf(fid, '  - MSE Value    : %.4f\n', minMSE_image);
fprintf(fid, '*** GAMBAR INI AKAN DIGUNAKAN SEBAGAI GT REFERENSI ***\n');

% Simpan ke .mat
save(fullfile(tableFolder, 'best_method_info.mat'), ...
     'bestMethodIdx', 'bestTechniqueIdx', ...
     'bestImageIdx', 'bestImageName', ...  ← BARU
     'methodNames', 'techniqueNames');
```

**Output:** `Table-Mse/mse_table.txt` sekarang berisi informasi gambar referensi

---

### **File 2: `hitung_akurasi.m`**

#### **Perubahan 1: Load Gambar Referensi**

```matlab
% Load dari .mat
load(fullfile(mseTableFolder, 'best_method_info.mat'));

% Sekarang ada: bestImageIdx, bestImageName
fprintf('  - Gambar Referensi: %s\n', bestImageName);
fprintf('  - Index Referensi: %d\n', bestImageIdx);
```

#### **Perubahan 2: Buat Ground Truth Referensi (SEKALI SAJA)**

```matlab
%% Buat Ground Truth dari Gambar Referensi Terbaik
% Baca gambar referensi yang sudah diproses
refEnhancedFile = fullfile(mseResultFolder, [refBaseName selectedSuffix '.png']);
imgRef = imread(refEnhancedFile);

% Edge detection dengan metode terbaik
edgeRef = edge_detection(imgRef);  % sobel/prewitt/log

% Otsu + Morfologi
[groundTruthReference, threshold] = otsu_threshold_manual(edgeRef);
groundTruthReference = morfologi(groundTruthReference);  % Opening + Closing

% Simpan Ground Truth Referensi
imwrite(groundTruthReference, 'ground_truth_reference.png');
```

#### **Perubahan 3: Loop untuk Setiap Gambar**

```matlab
for idx = 1:numImages
    % Baca citra asli
    imgOriginal = imread(fullfile(inputFolder, imageName));
    
    % Segmentasi dengan 3 metode (Sobel, Prewitt, LoG)
    sobelGT = segmentasi_sobel(imgOriginal);
    prewittGT = segmentasi_prewitt(imgOriginal);
    logGT = segmentasi_log(imgOriginal);
    
    % Hitung akurasi (dibandingkan dengan GT REFERENSI)
    for m = 1:3
        [acc, sens, spec] = hitung_metrik_segmentasi(
            groundTruthReference,  ← SAMA untuk semua gambar!
            segmentedResults{m}
        );
        results(m, :, idx) = [acc, sens, spec];
    end
end
```

---

## 📄 OUTPUT YANG BERUBAH

### **1. `Table-Mse/mse_table.txt`**

**Penambahan bagian akhir:**
```
========================================================================================
                         GAMBAR REFERENSI TERBAIK
========================================================================================
Gambar dengan MSE Terendah:
  - Nama Gambar  : plat_nomor_03_noisy.png
  - Index        : 3
  - MSE Value    : 245.6789
  - Metode       : Sobel
  - Teknik       : Improve_Brightness

*** GAMBAR INI AKAN DIGUNAKAN SEBAGAI GROUND TRUTH REFERENSI ***
========================================================================================
```

### **2. `Table-Accuration/akurasi_table.txt`**

**Header berubah:**
```
========================================================================================
                    TABEL AKURASI SEGMENTASI & MORFOLOGI
         Perbandingan 3 Metode Segmentasi dengan Ground Truth Referensi
========================================================================================

Tanggal              : 19-01-2026 22:00:00
Ground Truth Referensi:
  - Gambar           : plat_nomor_03_noisy.png  ← INFO BARU
  - Metode           : Sobel
  - Teknik           : Improve_Brightness
Metode Segmentasi    : Sobel, Prewitt, LoG
Structuring Element  : 3x3 (Opening + Closing)
```

### **3. `image-hasil-terbaik/citra-asli-groundtruth/`**

**File yang tersimpan:**
- `ground_truth_reference.png` ← Ground Truth referensi universal

(TIDAK ada lagi file `plat_nomor_XX_gt.png` per gambar)

---

## 🔍 VALIDASI KONSEP

### **Mengapa Menggunakan GT Referensi?**

1. **Konsistensi Benchmark**: Semua metode segmentasi diuji terhadap standar yang sama
2. **Kualitas Terjamin**: GT dibuat dari gambar dengan hasil MSE terbaik
3. **Interpretasi Mudah**: Akurasi mencerminkan seberapa baik metode mendekati hasil terbaik
4. **Standar Absolut**: Ada referensi tetap untuk evaluasi

### **Interpretasi Hasil Akurasi:**

```
Akurasi 95% = Metode segmentasi menghasilkan 95% pixel yang sama
               dengan Ground Truth referensi (gambar terbaik)

Semakin TINGGI akurasi → Semakin DEKAT dengan hasil terbaik
```

---

## ✅ CHECKLIST PERUBAHAN

- [x] `hitung_mse.m`: Identifikasi gambar dengan MSE terendah
- [x] `hitung_mse.m`: Simpan informasi gambar referensi ke .mat
- [x] `hitung_mse.m`: Tambah info gambar referensi di mse_table.txt
- [x] `hitung_akurasi.m`: Load informasi gambar referensi
- [x] `hitung_akurasi.m`: Buat GT referensi SEKALI di awal
- [x] `hitung_akurasi.m`: Hapus pembuatan GT per-gambar
- [x] `hitung_akurasi.m`: Update perhitungan akurasi menggunakan GT referensi
- [x] `hitung_akurasi.m`: Update header tabel akurasi

---

## 🚀 CARA MENJALANKAN

```matlab
% Step 1: Identifikasi gambar terbaik
>> hitung_mse
% Output: Gambar dengan MSE terendah akan teridentifikasi

% Step 2: Gunakan gambar terbaik sebagai GT referensi
>> hitung_akurasi
% Output: Semua gambar dibandingkan dengan GT referensi
```

---

## 📊 DIAGRAM ALUR BARU

```
                    ┌─────────────────┐
                    │  HITUNG_MSE.M   │
                    └────────┬────────┘
                             │
                             v
              ┌──────────────────────────┐
              │ Identifikasi Gambar      │
              │ dengan MSE Terendah      │
              │ (plat_nomor_03_noisy)    │
              └──────────┬───────────────┘
                         │
                         v
              ┌──────────────────────────┐
              │ Simpan Info ke .mat:     │
              │ - bestImageIdx = 3       │
              │ - bestImageName = ...    │
              └──────────┬───────────────┘
                         │
                         v
              ┌──────────────────────────┐
              │  HITUNG_AKURASI.M        │
              └──────────┬───────────────┘
                         │
                         v
              ┌──────────────────────────┐
              │ Load Gambar Referensi    │
              │ Buat GT Referensi        │
              │ (SEKALI SAJA)            │
              └──────────┬───────────────┘
                         │
                         v
              ┌──────────────────────────┐
              │ LOOP: Setiap Gambar      │
              │ - Segmentasi 3 metode    │
              │ - Compare vs GT REF      │
              │ - Hitung Akurasi         │
              └──────────────────────────┘
```

---

## 📌 CATATAN PENTING

1. **Jalankan ulang `hitung_mse.m`** untuk mendapatkan informasi gambar referensi
2. GT referensi dibuat dari gambar dengan **MSE terendah** pada kombinasi metode+teknik terbaik
3. Semua gambar diuji terhadap **GT referensi yang SAMA**
4. Akurasi mencerminkan seberapa baik metode mendekati **kualitas terbaik**

---

**STATUS: ✅ IMPLEMENTASI SELESAI**

**Tanggal: 19 Januari 2026, 22:00 WIB**
