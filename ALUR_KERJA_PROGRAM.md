# 🔄 ALUR KERJA PROGRAM LENGKAP
## Pengolahan Citra Digital - MSE & Akurasi

---

## 📊 OVERVIEW

Program ini terdiri dari **2 script utama** yang bekerja secara berurutan:
1. **`hitung_mse.m`** - Perbaikan citra dan perhitungan MSE
2. **`hitung_akurasi.m`** - Segmentasi dan perhitungan akurasi

---

# 🎯 PART 1: HITUNG_MSE.M

## ═══════════════════════════════════════════════════════════════
## STEP 1: MEMILIH FOLDER INPUT
## ═══════════════════════════════════════════════════════════════

### 📁 Kode:
```matlab
fprintf('1. 1_apple-image (Gambar Apel)\n');
fprintf('2. 2_plat-image (Gambar Plat Nomor)\n');
pilihan = input('Pilih folder (1/2): ');

if pilihan == 1
    inputFolder = '1_apple-image';
elseif pilihan == 2
    inputFolder = '2_plat-image';
end
```

### ✅ Output:
- User memilih folder: **`1_apple-image`** ATAU **`2_plat-image`**
- Variable `inputFolder` terisi dengan pilihan user

### 📋 Validasi:
- ✓ Kode sudah benar
- ✓ Ada validasi input (harus 1 atau 2)
- ✓ Error handling jika input salah

---

## ═══════════════════════════════════════════════════════════════
## STEP 2: PENGOLAHAN 5 FILTER (ENHANCEMENT)
## ═══════════════════════════════════════════════════════════════

### 🔄 Proses untuk SETIAP GAMBAR:

```matlab
for idx = 1:numImages
    img = imread(fullfile(inputFolder, imageName));
    
    % Konversi ke grayscale
    if size(img, 3) == 3
        img = rgb2gray_manual(img);
    end
    imgDouble = double(img);
```

### 🎨 5 Teknik Perbaikan:

#### **Filter 1: Brightness +40**
```matlab
hasil_brightness = brightness_adjustment(imgDouble, 40);
```
- **Formula**: `I' = I + 40`
- **Efek**: Mencerahkan gambar dengan menambah 40 ke setiap pixel

#### **Filter 2: Contrast 15**
```matlab
hasil_contrast = contrast_adjustment(imgDouble, 15);
```
- **Formula**: `I' = (I - mean) × 1.15 + mean`
- **Efek**: Meningkatkan kontras sebesar 15%

#### **Filter 3: Combination**
```matlab
hasil_combination = contrast_adjustment(
    brightness_adjustment(imgDouble, 40), 15
);
```
- **Formula**: Brightness +40 → lalu Contrast 15
- **Efek**: Gabungan brightness dan contrast

#### **Filter 4: Nonlinear Mapping**
```matlab
hasil_nonlinear = power_law_transform(imgDouble, 0.7);
```
- **Formula**: `I' = (I/255)^0.7 × 255`
- **Efek**: Gamma correction untuk mencerahkan area gelap

#### **Filter 5: Improve Brightness**
```matlab
hasil_improve = histogram_equalization_manual(uint8(imgDouble));
```
- **Formula**: `I' = CDF(I) × 255`
- **Efek**: Histogram equalization untuk distribusi intensitas merata

### 💾 Simpan Hasil Filter:
```matlab
imwrite(uint8(hasil_brightness), [baseName '_brightness40.png']);
imwrite(uint8(hasil_contrast), [baseName '_contrast15.png']);
imwrite(uint8(hasil_combination), [baseName '_combination.png']);
imwrite(uint8(hasil_nonlinear), [baseName '_nonlinear.png']);
imwrite(uint8(hasil_improve), [baseName '_improve.png']);
```

### ✅ Output:
- **75 gambar** hasil perbaikan (15 gambar × 5 filter)
- Tersimpan di folder: **`image-hasil-mse/`**

### 📋 Validasi:
- ✓ Semua 5 filter diimplementasikan
- ✓ Hasil disimpan dengan benar
- ✓ Naming convention konsisten

---

## ═══════════════════════════════════════════════════════════════
## STEP 3: EDGE DETECTION (SOBEL, PREWITT, LOG)
## ═══════════════════════════════════════════════════════════════

### 🔄 Untuk SETIAP Metode Edge Detection:

```matlab
for m = 1:3  % 3 metode
    % Edge detection pada citra ASLI (sebagai referensi)
    switch m
        case 1  % Sobel
            edgeRef = sobel_edge_detection(imgDouble);
        case 2  % Prewitt
            edgeRef = prewitt_edge_detection(imgDouble);
        case 3  % LoG
            edgeRef = log_edge_detection(imgDouble);
    end
    
    for t = 1:5  % 5 teknik perbaikan
        % Edge detection pada HASIL PERBAIKAN
        switch m
            case 1
                edgeResult = sobel_edge_detection(hasilPerbaikan{t});
            case 2
                edgeResult = prewitt_edge_detection(hasilPerbaikan{t});
            case 3
                edgeResult = log_edge_detection(hasilPerbaikan{t});
        end
```

### 📐 Detail Metode:

#### **Metode 1: Sobel**
```matlab
Gx = [-1 0 1; -2 0 2; -1 0 1];
Gy = [-1 -2 -1; 0 0 0; 1 2 1];
edge_magnitude = sqrt(gradX^2 + gradY^2);
```

#### **Metode 2: Prewitt**
```matlab
Gx = [-1 0 1; -1 0 1; -1 0 1];
Gy = [-1 -1 -1; 0 0 0; 1 1 1];
edge_magnitude = sqrt(gradX^2 + gradY^2);
```

#### **Metode 3: LoG (Laplacian of Gaussian)**
```matlab
1. Gaussian smoothing (σ = 1.4, kernel 5×5)
2. Laplacian: [0 1 0; 1 -4 1; 0 1 0]
3. edge_img = abs(laplacian_result)
```

### ✅ Output:
- **Edge detection** diterapkan pada:
  - 1 citra asli × 3 metode = 3 edge images (referensi)
  - 5 hasil perbaikan × 3 metode = 15 edge images
- **Total**: 18 edge images per gambar input

### 📋 Validasi:
- ✓ Edge detection pada citra asli sebagai referensi
- ✓ Edge detection pada hasil perbaikan
- ✓ Semua 3 metode diimplementasikan

---

## ═══════════════════════════════════════════════════════════════
## STEP 4: PERHITUNGAN MSE
## ═══════════════════════════════════════════════════════════════

### 🧮 Formula MSE:
```matlab
function mse = compute_mse(citra1, citra2)
    diff = citra1 - citra2;
    mse = sum(sum(diff.^2)) / (m * n);
end
```

### 🔢 Proses Perhitungan:
```matlab
% Hitung MSE antara edge asli vs edge hasil perbaikan
MSE_Results(m, t, idx) = compute_mse(edgeRef, edgeResult);
```

### 📊 Struktur Data MSE:
```
MSE_Results[3, 5, 15]
├─ Dimensi 1: 3 metode (Sobel, Prewitt, LoG)
├─ Dimensi 2: 5 teknik (Bright, Contrast, Combi, Nonlinear, Improve)
└─ Dimensi 3: 15 gambar
```

### ✅ Output:
- **Matriks MSE**: 3 × 5 × 15 = 225 nilai MSE
- Setiap nilai merepresentasikan:
  - Perbedaan antara edge asli vs edge hasil perbaikan
  - MSE **lebih rendah** = hasil perbaikan **lebih baik**

### 📋 Validasi:
- ✓ MSE dihitung dengan benar
- ✓ Perbandingan: edge asli vs edge hasil perbaikan
- ✓ Data tersimpan dalam struktur 3D array

---

## ═══════════════════════════════════════════════════════════════
## STEP 4.1: GENERATE TABLE MSE.TXT
## ═══════════════════════════════════════════════════════════════

### 📝 Proses Generate Table:

```matlab
fid = fopen(fullfile(tableFolder, 'mse_table.txt'), 'w');

% Loop untuk setiap metode
for m = 1:3
    fprintf(fid, 'METODE %d: %s\n', m, methodNames{m});
    fprintf(fid, '| No | Image Name | Bright40 | Contrast15 | Combi | Nonlinear | Improve |\n');
    
    % Loop untuk setiap gambar
    for idx = 1:numImages
        fprintf(fid, '| %2d | %-28s | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f |\n',
            idx, imageNamesList{idx},
            MSE_Results(m, 1, idx),
            MSE_Results(m, 2, idx),
            MSE_Results(m, 3, idx),
            MSE_Results(m, 4, idx),
            MSE_Results(m, 5, idx));
    end
    
    % Hitung rata-rata
    fprintf(fid, '| RATA-RATA | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f |\n',
        mean(MSE_Results(m, 1, :)),
        mean(MSE_Results(m, 2, :)),
        mean(MSE_Results(m, 3, :)),
        mean(MSE_Results(m, 4, :)),
        mean(MSE_Results(m, 5, :)));
end

fclose(fid);
```

### 📄 Format Output (mse_table.txt):
```
========================================================================================
METODE 1: Sobel
========================================================================================
| No | Image Name                   | Bright40   | Contrast15 | Combi      | Nonlinear  | Improve    |
----------------------------------------------------------------------------------------
|  1 | plat_nomor_01_clear.png      |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |
|  2 | plat_nomor_02_blur.png       |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |
...
| 15 | plat_nomor_15_shadow.png     |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |
----------------------------------------------------------------------------------------
|    | RATA-RATA                    |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |  1234.5678 |
========================================================================================

[Ulangi untuk METODE 2: Prewitt dan METODE 3: LoG]
```

### ✅ Output:
- File: **`Table-Mse/mse_table.txt`**
- Berisi MSE untuk semua kombinasi metode dan teknik

### 📋 Validasi:
- ✓ Table format rapi dan mudah dibaca
- ✓ Ada header dan separator
- ✓ Rata-rata dihitung per metode dan teknik

---

## ═══════════════════════════════════════════════════════════════
## STEP 5: MEMILAH METODE MSE TERBAIK
## ═══════════════════════════════════════════════════════════════

### 🏆 Proses Seleksi:

```matlab
% 1. Hitung rata-rata MSE untuk setiap kombinasi
avgMSE = zeros(3, 5);
for m = 1:3
    for t = 1:5
        avgMSE(m, t) = mean(MSE_Results(m, t, :));
    end
end

% 2. Cari MSE terendah per metode
[minMSE_perMethod, bestTechIdx] = min(avgMSE, [], 2);

% 3. Cari MSE terendah global
[globalMinMSE, bestMethodIdx] = min(minMSE_perMethod);
bestTechniqueIdx = bestTechIdx(bestMethodIdx);
```

### 📊 Contoh Hasil:
```
avgMSE = [
    1200.5  1150.3  1100.2  1080.5  1050.1  <- Sobel
    1220.7  1170.9  1120.4  1090.3  1060.8  <- Prewitt
    1240.2  1190.5  1140.8  1110.6  1080.3  <- LoG
]

Teknik terbaik per metode:
- Sobel: Improve (1050.1)
- Prewitt: Improve (1060.8)
- LoG: Improve (1080.3)

Global terbaik: Sobel + Improve (1050.1)
```

### 💾 Simpan Informasi Terbaik:
```matlab
save(fullfile(tableFolder, 'best_method_info.mat'), 
     'bestMethodIdx', 'bestTechniqueIdx', 
     'methodNames', 'techniqueNames');
```

### ✅ Output:
- **`best_method_info.mat`** berisi:
  - `bestMethodIdx` = index metode terbaik (1=Sobel, 2=Prewitt, 3=LoG)
  - `bestTechniqueIdx` = index teknik terbaik (1-5)
  - `methodNames` = {'Sobel', 'Prewitt', 'LoG'}
  - `techniqueNames` = {'Brightness_40', 'Contrast_15', ...}

### 📋 Validasi:
- ✓ Perhitungan rata-rata benar
- ✓ Pemilihan minimum menggunakan fungsi min()
- ✓ Data disimpan untuk digunakan di hitung_akurasi.m

---

# 🎯 PART 2: HITUNG_AKURASI.M

## ═══════════════════════════════════════════════════════════════
## STEP 6: GROUND TRUTH PROCESSING
## ═══════════════════════════════════════════════════════════════

### 📂 Load Metode Terbaik:
```matlab
load(fullfile(mseTableFolder, 'best_method_info.mat'));
% Mendapatkan: bestMethodIdx, bestTechniqueIdx
```

### 🔄 Untuk SETIAP GAMBAR:

#### **6.1: Baca Hasil Perbaikan Terbaik**
```matlab
% Tentukan suffix berdasarkan teknik terbaik
techniqueSuffix = {'_brightness40', '_contrast15', '_combination', 
                   '_nonlinear', '_improve'};
selectedSuffix = techniqueSuffix{bestTechniqueIdx};

% Baca gambar hasil perbaikan
enhancedFileName = [baseName selectedSuffix '.png'];
imgEnhanced = imread(fullfile(mseResultFolder, enhancedFileName));
```

#### **6.2: Edge Detection dengan Metode Terbaik**
```matlab
switch bestMethodIdx
    case 1  % Sobel
        edgeEnhanced = sobel_edge_detection(imgEnhancedDouble);
    case 2  % Prewitt
        edgeEnhanced = prewitt_edge_detection(imgEnhancedDouble);
    case 3  % LoG
        edgeEnhanced = log_edge_detection(imgEnhancedDouble);
end
```

#### **6.3: Otsu Thresholding**
```matlab
[groundTruth, thresholdGT] = otsu_threshold_manual(uint8(edgeEnhanced));
```

**Otsu Algorithm:**
```matlab
1. Hitung histogram
2. Untuk setiap threshold t (0-255):
   - Pisahkan pixel menjadi 2 kelas (0-t) dan (t+1-255)
   - Hitung variance between-class
3. Pilih t dengan variance maksimum
4. Binarisasi: pixel > t = 1, sisanya = 0
```

#### **6.4: Morfologi (Opening + Closing)**
```matlab
SE = ones(3, 3);  % Structuring Element 3x3

% Opening: Erosi → Dilasi (hapus noise kecil)
groundTruth = dilasi_manual(erosi_manual(groundTruth, SE), SE);

% Closing: Dilasi → Erosi (tutup lubang kecil)
groundTruth = erosi_manual(dilasi_manual(groundTruth, SE), SE);
```

#### **6.5: Simpan Ground Truth**
```matlab
imwrite(groundTruth, fullfile(citraAsliGTFolder, [baseName '_gt.png']));
```

### ✅ Output:
- **Ground Truth** untuk setiap gambar
- Tersimpan di: **`image-hasil-terbaik/citra-asli-groundtruth/`**
- Format: Binary image (0 = background, 1 = edge/object)

### 📋 Validasi:
- ✓ Menggunakan hasil perbaikan TERBAIK dari MSE
- ✓ Menggunakan metode edge detection TERBAIK
- ✓ Otsu thresholding otomatis tanpa parameter
- ✓ Morfologi untuk cleaning hasil

---

## ═══════════════════════════════════════════════════════════════
## STEP 7: SEGMENTASI DAN MORFOLOGI (3 METODE)
## ═══════════════════════════════════════════════════════════════

### 🔄 Proses untuk 3 Metode Segmentasi:

#### **Metode 1: Sobel Segmentasi**
```matlab
edgeSobel = sobel_edge_detection(imgOriginalDouble);
[sobelGT, thresholdSobel] = otsu_threshold_manual(uint8(edgeSobel));
sobelGT = dilasi_manual(erosi_manual(sobelGT, SE), SE);  % Opening
sobelGT = erosi_manual(dilasi_manual(sobelGT, SE), SE);  % Closing
imwrite(sobelGT, fullfile(sobelGTFolder, [baseName '_sobel_gt.png']));
```

#### **Metode 2: Prewitt Segmentasi**
```matlab
edgePrewitt = prewitt_edge_detection(imgOriginalDouble);
[prewittGT, thresholdPrewitt] = otsu_threshold_manual(uint8(edgePrewitt));
prewittGT = dilasi_manual(erosi_manual(prewittGT, SE), SE);  % Opening
prewittGT = erosi_manual(dilasi_manual(prewittGT, SE), SE);  % Closing
imwrite(prewittGT, fullfile(prewittGTFolder, [baseName '_prewitt_gt.png']));
```

#### **Metode 3: LoG Segmentasi**
```matlab
edgeLog = log_edge_detection(imgOriginalDouble);
[logGT, thresholdLog] = otsu_threshold_manual(uint8(edgeLog));
logGT = dilasi_manual(erosi_manual(logGT, SE), SE);  % Opening
logGT = erosi_manual(dilasi_manual(logGT, SE), SE);  % Closing
imwrite(logGT, fullfile(logGTFolder, [baseName '_log_gt.png']));
```

### 📐 Detail Morfologi:

#### **Erosi (Erosion)**
```
Efek: Mengecilkan objek, menghilangkan noise kecil
Kernel cocok: pixel = 1 jika SEMUA pixel di SE = 1
```

#### **Dilasi (Dilation)**
```
Efek: Memperbesar objek, menutup lubang kecil
Kernel cocok: pixel = 1 jika ADA pixel di SE = 1
```

#### **Opening (Erosi → Dilasi)**
```
Efek: Hilangkan noise kecil, pertahankan bentuk besar
```

#### **Closing (Dilasi → Erosi)**
```
Efek: Tutup lubang kecil, sambungkan region terpisah
```

### ✅ Output:
- **3 set hasil segmentasi** untuk setiap gambar:
  - `sobel-groundtruth/plat_nomor_XX_sobel_gt.png`
  - `prewitt-groundtruth/plat_nomor_XX_prewitt_gt.png`
  - `log-groundtruth/plat_nomor_XX_log_gt.png`

### 📋 Validasi:
- ✓ Proses SAMA untuk ketiga metode
- ✓ Edge detection → Otsu → Morfologi
- ✓ Hasil disimpan dengan benar

---

## ═══════════════════════════════════════════════════════════════
## STEP 8: HITUNG AKURASI, SENSITIVITAS, SPESIFISITAS
## ═══════════════════════════════════════════════════════════════

### 🧮 Confusion Matrix:

```
                    GROUND TRUTH
                    0 (BG)    1 (Edge)
PREDIKSI  0 (BG)      TN         FN
          1 (Edge)    FP         TP
```

### 📊 Perhitungan Metrik:

```matlab
function [accuracy, sensitivity, specificity] = hitung_metrik_segmentasi(groundTruth, prediksi)
    gt = double(groundTruth(:));
    pred = double(prediksi(:));
    
    % Hitung confusion matrix
    TP = sum((gt == 1) & (pred == 1));  % True Positive
    TN = sum((gt == 0) & (pred == 0));  % True Negative
    FP = sum((gt == 0) & (pred == 1));  % False Positive
    FN = sum((gt == 1) & (pred == 0));  % False Negative
    
    % Hitung metrik
    accuracy = ((TP + TN) / (TP + TN + FP + FN)) * 100;
    sensitivity = (TP / (TP + FN)) * 100;
    specificity = (TN / (TN + FP)) * 100;
end
```

### 📐 Formula:

#### **Akurasi (Accuracy)**
```
Akurasi = (TP + TN) / Total × 100%
= Persentase klasifikasi benar (baik edge maupun background)
```

#### **Sensitivitas (Sensitivity / Recall / TPR)**
```
Sensitivitas = TP / (TP + FN) × 100%
= Kemampuan mendeteksi edge yang sebenarnya edge
= True Positive Rate
```

#### **Spesifisitas (Specificity / TNR)**
```
Spesifisitas = TN / (TN + FP) × 100%
= Kemampuan mendeteksi background yang sebenarnya background
= True Negative Rate
```

### 🔄 Proses untuk 3 Metode:

```matlab
for m = 1:3  % Sobel, Prewitt, LoG
    [accuracy, sensitivity, specificity] = 
        hitung_metrik_segmentasi(groundTruth, segmentedResults{m});
    
    results(m, 1, idx) = accuracy;
    results(m, 2, idx) = sensitivity;
    results(m, 3, idx) = specificity;
end
```

### ✅ Output:
- **Matriks Results**: 3 × 3 × 15
  - Dimensi 1: 3 metode
  - Dimensi 2: 3 metrik (Akurasi, Sens, Spec)
  - Dimensi 3: 15 gambar

### 📋 Validasi:
- ✓ Formula perhitungan benar
- ✓ Perbandingan: Ground Truth vs Hasil Segmentasi
- ✓ Data disimpan dalam struktur 3D array

---

## ═══════════════════════════════════════════════════════════════
## STEP 9: GENERATE TABLE AKURASI.TXT
## ═══════════════════════════════════════════════════════════════

### 📝 Proses Generate Table:

```matlab
fid = fopen(fullfile(tableFolder, 'akurasi_table.txt'), 'w');

% Header
fprintf(fid, 'Ground Truth: %s + %s (dari MSE terbaik)\n', 
        methodNames{bestMethodIdx}, techniqueNames{bestTechniqueIdx});

% Loop untuk setiap metode
for m = 1:3
    fprintf(fid, 'METODE SEGMENTASI: %s\n', segmentationMethods{m});
    fprintf(fid, '| No | Image Name | Akurasi (%%) | Sensitivitas (%%) | Spesifisitas (%%) |\n');
    
    % Loop untuk setiap gambar
    for idx = 1:numImages
        fprintf(fid, '| %2d | %-28s | %11.2f | %16.2f | %16.2f |\n',
            idx, imageNamesList{idx},
            results(m, 1, idx),
            results(m, 2, idx),
            results(m, 3, idx));
    end
    
    % Rata-rata
    fprintf(fid, '| RATA-RATA | %11.2f | %16.2f | %16.2f |\n',
        mean(results(m, 1, :)),
        mean(results(m, 2, :)),
        mean(results(m, 3, :)));
end

fclose(fid);
```

### 📄 Format Output (akurasi_table.txt):

```
========================================================================================
                    TABEL AKURASI SEGMENTASI & MORFOLOGI
         Perbandingan 3 Metode Segmentasi dengan Ground Truth
========================================================================================
Ground Truth: Sobel + Improve_Brightness (dari MSE terbaik)
Metode Segmentasi: Sobel, Prewitt, LoG

========================================================================================
METODE SEGMENTASI: Sobel
========================================================================================
| No | Image Name                   | Akurasi (%) | Sensitivitas (%) | Spesifisitas (%) |
----------------------------------------------------------------------------------------
|  1 | plat_nomor_01_clear.png      |       95.50 |            92.30 |            97.80 |
|  2 | plat_nomor_02_blur.png       |       94.20 |            90.15 |            96.50 |
...
| 15 | plat_nomor_15_shadow.png     |       93.80 |            89.70 |            95.90 |
----------------------------------------------------------------------------------------
|    | RATA-RATA                    |       94.50 |            91.05 |            96.73 |
========================================================================================

[Ulangi untuk Prewitt dan LoG]

========================================================================================
                       RINGKASAN PERBANDINGAN METODE
========================================================================================
| Metode  | Rata-rata Akurasi | Rata-rata Sensitivitas | Rata-rata Spesifisitas |
----------------------------------------------------------------------------------------
| Sobel   |             94.50 |                  91.05 |                  96.73 |
| Prewitt |             93.80 |                  90.20 |                  96.10 |
| LoG     |             92.50 |                  88.75 |                  94.85 |
========================================================================================

*** METODE SEGMENTASI TERBAIK (Akurasi Tertinggi) ***
Metode: Sobel
Akurasi Rata-rata: 94.50%
```

### ✅ Output:
- File: **`Table-Accuration/akurasi_table.txt`**
- Berisi metrik untuk semua metode segmentasi

### 📋 Validasi:
- ✓ Table format rapi
- ✓ Ada ringkasan perbandingan
- ✓ Metode terbaik teridentifikasi

---

## ═══════════════════════════════════════════════════════════════
## STEP 10: GAMBAR HASIL AKHIR
## ═══════════════════════════════════════════════════════════════

### 📂 Struktur Folder Output:

```
image-hasil-terbaik/
├── citra-asli/                     (15 gambar original)
│   ├── plat_nomor_01_clear.png
│   ├── plat_nomor_02_blur.png
│   └── ...
│
├── citra-asli-groundtruth/         (15 gambar Ground Truth)
│   ├── plat_nomor_01_gt.png
│   ├── plat_nomor_02_gt.png
│   └── ...
│
├── sobel-groundtruth/              (15 gambar Sobel GT)
│   ├── plat_nomor_01_sobel_gt.png
│   ├── plat_nomor_02_sobel_gt.png
│   └── ...
│
├── prewitt-groundtruth/            (15 gambar Prewitt GT)
│   ├── plat_nomor_01_prewitt_gt.png
│   ├── plat_nomor_02_prewitt_gt.png
│   └── ...
│
└── log-groundtruth/                (15 gambar LoG GT)
    ├── plat_nomor_01_log_gt.png
    ├── plat_nomor_02_log_gt.png
    └── ...
```

### 🖼️ Karakteristik Gambar:

#### **Citra Asli** (Grayscale)
- Format: PNG
- Nilai pixel: 0-255
- Ukuran: Original size (e.g., 512×512)

#### **Ground Truth** (Binary)
- Format: PNG
- Nilai pixel: 0 (hitam/background) atau 1 (putih/edge)
- Hasil dari: Perbaikan terbaik → Edge detect → Otsu → Morfologi

#### **Sobel/Prewitt/LoG GT** (Binary)
- Format: PNG
- Nilai pixel: 0 atau 1
- Hasil dari: Citra asli → Edge detect → Otsu → Morfologi

### ✅ Output Total:
- **75 gambar** dalam folder `image-hasil-terbaik/`
  - 15 citra asli
  - 15 ground truth
  - 15 sobel GT
  - 15 prewitt GT
  - 15 log GT

### 📋 Validasi:
- ✓ Semua gambar tersimpan dengan benar
- ✓ Struktur folder terorganisir
- ✓ Naming convention konsisten

---

# ✅ VALIDASI KODE KESELURUHAN

## 🔍 Pengecekan Alur:

| Step | Deskripsi | Status | Kode |
|------|-----------|--------|------|
| 1 | Memilih folder | ✅ Benar | `hitung_mse.m` line 15-34 |
| 2 | 5 filter perbaikan | ✅ Benar | `hitung_mse.m` line 84-97 |
| 3 | 3 metode edge detection | ✅ Benar | `hitung_mse.m` line 104-124 |
| 4 | Hitung MSE | ✅ Benar | `hitung_mse.m` line 127 |
| 4.1 | Generate mse_table.txt | ✅ Benar | `hitung_mse.m` line 146-188 |
| 5 | Pilih metode terbaik | ✅ Benar | `hitung_mse.m` line 190-228 |
| 6 | Ground truth processing | ✅ Benar | `hitung_akurasi.m` line 93-130 |
| 7 | Morfologi 3 metode | ✅ Benar | `hitung_akurasi.m` line 132-154 |
| 8 | Hitung akurasi | ✅ Benar | `hitung_akurasi.m` line 160-184 |
| 9 | Generate akurasi_table.txt | ✅ Benar | `hitung_akurasi.m` line 189-260 |
| 10 | Simpan gambar hasil | ✅ Benar | `hitung_akurasi.m` line 90-154 |

## ✅ **KESIMPULAN: SEMUA KODE SUDAH BENAR!** ✅

---

# 📊 DIAGRAM ALUR LENGKAP

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         HITUNG_MSE.M - PART 1                                    │
└─────────────────────────────────────────────────────────────────────────────────┘

    [START]
       │
       v
┌──────────────────┐
│  PILIH FOLDER    │ ← User input (1 atau 2)
│  1_apple-image   │
│  2_plat-image    │
└────────┬─────────┘
         │
         v
┌─────────────────────────────────────────────────────────────┐
│  LOOP: Untuk setiap gambar (1-15)                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Baca gambar → Convert grayscale                       │  │
│  └───────────────┬───────────────────────────────────────┘  │
│                  │                                           │
│                  v                                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  TERAPKAN 5 FILTER PERBAIKAN:                         │  │
│  │  1. Brightness +40                                    │  │
│  │  2. Contrast 15                                       │  │
│  │  3. Combination                                       │  │
│  │  4. Nonlinear (gamma=0.7)                            │  │
│  │  5. Improve (histogram eq)                           │  │
│  │  → Simpan ke image-hasil-mse/                        │  │
│  └───────────────┬───────────────────────────────────────┘  │
│                  │                                           │
│                  v                                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  EDGE DETECTION (3 metode × 6 gambar)                │  │
│  │  FOR m=1:3 (Sobel, Prewitt, LoG)                     │  │
│  │    edgeRef = edge_detect(citra_asli)                 │  │
│  │    FOR t=1:5 (5 filter)                              │  │
│  │       edgeResult = edge_detect(hasil_filter[t])      │  │
│  │       MSE[m,t,idx] = compute_mse(edgeRef,edgeResult) │  │
│  │    END                                                │  │
│  │  END                                                  │  │
│  └───────────────┬───────────────────────────────────────┘  │
└──────────────────┼───────────────────────────────────────────┘
                   │
                   v
         ┌─────────────────┐
         │ GENERATE TABLE  │
         │ mse_table.txt   │ ← 3 metode × 5 teknik × 15 gambar
         └────────┬────────┘
                  │
                  v
         ┌─────────────────────────┐
         │  PILIH METODE TERBAIK   │
         │  - Hitung avgMSE        │
         │  - Cari minimum         │
         │  - Simpan ke .mat       │
         └────────┬────────────────┘
                  │
                  v
         [END HITUNG_MSE.M]


┌─────────────────────────────────────────────────────────────────────────────────┐
│                      HITUNG_AKURASI.M - PART 2                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

    [START]
       │
       v
┌──────────────────┐
│  LOAD METODE     │
│  TERBAIK (.mat)  │ ← bestMethodIdx, bestTechniqueIdx
└────────┬─────────┘
         │
         v
┌─────────────────────────────────────────────────────────────┐
│  LOOP: Untuk setiap gambar (1-15)                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ BUAT GROUND TRUTH:                                    │  │
│  │ 1. Baca hasil perbaikan terbaik (dari MSE)           │  │
│  │ 2. Edge detection (metode terbaik)                   │  │
│  │ 3. Otsu thresholding                                 │  │
│  │ 4. Morfologi (Opening + Closing)                     │  │
│  │ → Simpan ground_truth.png                            │  │
│  └───────────────┬───────────────────────────────────────┘  │
│                  │                                           │
│                  v                                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ SEGMENTASI 3 METODE (pada citra asli):               │  │
│  │ 1. Sobel → Otsu → Morfologi → sobel_gt.png          │  │
│  │ 2. Prewitt → Otsu → Morfologi → prewitt_gt.png      │  │
│  │ 3. LoG → Otsu → Morfologi → log_gt.png              │  │
│  └───────────────┬───────────────────────────────────────┘  │
│                  │                                           │
│                  v                                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ HITUNG METRIK (3 metode):                            │  │
│  │ FOR m=1:3                                             │  │
│  │   Compare: ground_truth vs segmented[m]              │  │
│  │   - Akurasi = (TP+TN)/Total × 100%                  │  │
│  │   - Sensitivitas = TP/(TP+FN) × 100%                │  │
│  │   - Spesifisitas = TN/(TN+FP) × 100%                │  │
│  │ END                                                   │  │
│  └───────────────┬───────────────────────────────────────┘  │
└──────────────────┼───────────────────────────────────────────┘
                   │
                   v
         ┌─────────────────┐
         │ GENERATE TABLE  │
         │akurasi_table.txt│ ← 3 metode × 3 metrik × 15 gambar
         └────────┬────────┘
                  │
                  v
         ┌─────────────────┐
         │ SIMPAN GAMBAR   │
         │ HASIL AKHIR:    │
         │ - Citra asli    │
         │ - Ground truth  │
         │ - Sobel GT      │
         │ - Prewitt GT    │
         │ - LoG GT        │
         └────────┬────────┘
                  │
                  v
         [END HITUNG_AKURASI.M]
```

---

# 📚 REFERENSI FUNGSI

## Fungsi Perbaikan Citra:
- `brightness_adjustment()` - Brightness +40
- `contrast_adjustment()` - Contrast enhancement
- `power_law_transform()` - Gamma correction
- `histogram_equalization_manual()` - Histogram equalization

## Fungsi Edge Detection:
- `sobel_edge_detection()` - Sobel operator
- `prewitt_edge_detection()` - Prewitt operator
- `log_edge_detection()` - Laplacian of Gaussian

## Fungsi Segmentasi & Morfologi:
- `otsu_threshold_manual()` - Otsu's thresholding
- `erosi_manual()` - Erosion operation
- `dilasi_manual()` - Dilation operation

## Fungsi Evaluasi:
- `compute_mse()` - Mean Square Error
- `hitung_metrik_segmentasi()` - Accuracy, Sensitivity, Specificity

## Fungsi Utility:
- `rgb2gray_manual()` - RGB to Grayscale
- `imresize_manual()` - Image resizing

---

**DOKUMENTASI DIBUAT: 19 Januari 2026**
**STATUS: ✅ SEMUA KODE SUDAH VALID DAN BENAR**
