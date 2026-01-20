# 📝 LEMBAR HITUNGAN MANUAL 9×9 PIXEL

## Dokumen ini berisi contoh perhitungan manual yang bisa dikerjakan di kertas.

---

# BAGIAN 1: DATA PIXEL 9×9

## 1.1 Citra Asli (Grayscale)

Nilai intensitas pixel (0-255):

```
     Kolom→   1    2    3    4    5    6    7    8    9
Baris↓
    1       120  125  130  128  135  140  138  142  145
    2       122  127  132  130  137  142  140  144  147
    3       118  123  128  126  133  138  136  140  143
    4       124  129  134  132  139  144  142  146  149
    5       126  131  136  134  141  146  144  148  151
    6       128  133  138  136  143  148  146  150  153
    7       130  135  140  138  145  150  148  152  155
    8       132  137  142  140  147  152  150  154  157
    9       134  139  144  142  149  154  152  156  159
```

---

# BAGIAN 2: PERHITUNGAN BRIGHTNESS +40

## Formula: I' = I + 40

### Langkah:
1. Ambil setiap nilai pixel
2. Tambahkan 40
3. Jika hasil > 255, clip ke 255

### Contoh Perhitungan (Baris 1):
```
Pixel(1,1) = 120 + 40 = 160
Pixel(1,2) = 125 + 40 = 165
Pixel(1,3) = 130 + 40 = 170
Pixel(1,4) = 128 + 40 = 168
Pixel(1,5) = 135 + 40 = 175
Pixel(1,6) = 140 + 40 = 180
Pixel(1,7) = 138 + 40 = 178
Pixel(1,8) = 142 + 40 = 182
Pixel(1,9) = 145 + 40 = 185
```

### Hasil Brightness +40:
```
     Kolom→   1    2    3    4    5    6    7    8    9
Baris↓
    1       160  165  170  168  175  180  178  182  185
    2       162  167  172  170  177  182  180  184  187
    3       158  163  168  166  173  178  176  180  183
    4       164  169  174  172  179  184  182  186  189
    5       166  171  176  174  181  186  184  188  191
    6       168  173  178  176  183  188  186  190  193
    7       170  175  180  178  185  190  188  192  195
    8       172  177  182  180  187  192  190  194  197
    9       174  179  184  182  189  194  192  196  199
```

---

# BAGIAN 3: PERHITUNGAN EDGE DETECTION (SOBEL)

## Kernel Sobel:
```
Gx = [-1  0  1]     Gy = [-1 -2 -1]
     [-2  0  2]          [ 0  0  0]
     [-1  0  1]          [ 1  2  1]
```

## Formula:
```
Gradient_X(i,j) = Σ [Region(i,j) × Gx]
Gradient_Y(i,j) = Σ [Region(i,j) × Gy]
Edge(i,j) = √(Gradient_X² + Gradient_Y²)
```

### Contoh Perhitungan untuk Pixel (2,2):

**Region 3×3 sekitar pixel (2,2):**
```
     120  125  130
     122  127  132      ← Pixel (2,2) = 127 (tengah)
     118  123  128
```

**Hitung Gradient X:**
```
Gx = (-1×120) + (0×125) + (1×130)
   + (-2×122) + (0×127) + (2×132)
   + (-1×118) + (0×123) + (1×128)

Gx = -120 + 0 + 130 - 244 + 0 + 264 - 118 + 0 + 128
Gx = 40
```

**Hitung Gradient Y:**
```
Gy = (-1×120) + (-2×125) + (-1×130)
   + ( 0×122) + ( 0×127) + ( 0×132)
   + ( 1×118) + ( 2×123) + ( 1×128)

Gy = -120 - 250 - 130 + 0 + 0 + 0 + 118 + 246 + 128
Gy = -8
```

**Hitung Edge Magnitude:**
```
Edge(2,2) = √(40² + (-8)²)
          = √(1600 + 64)
          = √1664
          = 40.79
```

### Ulangi untuk semua pixel interior (2,2) sampai (8,8).

---

# BAGIAN 4: PERHITUNGAN MSE

## Formula MSE:
```
MSE = (1/MN) × Σᵢ Σⱼ [f(i,j) - g(i,j)]²
```

Dimana:
- f(i,j) = Edge dari citra asli
- g(i,j) = Edge dari citra hasil perbaikan
- M × N = Ukuran citra (9 × 9 = 81)

### Contoh Data Edge (sederhana):

**Edge Citra Asli (f):**
```
     1    2    3    4    5    6    7    8    9
1    0   10   20   30   40   50   40   30   20
2   10   20   30   40   50   60   50   40   30
3   20   30   40   50   60   70   60   50   40
4   30   40   50   60   70   80   70   60   50
5   40   50   60   70   80   90   80   70   60
6   30   40   50   60   70   80   70   60   50
7   20   30   40   50   60   70   60   50   40
8   10   20   30   40   50   60   50   40   30
9    0   10   20   30   40   50   40   30   20
```

**Edge Citra Filter (g):**
```
     1    2    3    4    5    6    7    8    9
1    5   15   25   35   45   55   45   35   25
2   15   25   35   45   55   65   55   45   35
3   25   35   45   55   65   75   65   55   45
4   35   45   55   65   75   85   75   65   55
5   45   55   65   75   85   95   85   75   65
6   35   45   55   65   75   85   75   65   55
7   25   35   45   55   65   75   65   55   45
8   15   25   35   45   55   65   55   45   35
9    5   15   25   35   45   55   45   35   25
```

### Langkah Perhitungan:

**1. Hitung selisih per pixel:**
```
diff(1,1) = 0 - 5 = -5
diff(1,2) = 10 - 15 = -5
diff(1,3) = 20 - 25 = -5
... dst
```

**2. Kuadratkan setiap selisih:**
```
diff²(1,1) = (-5)² = 25
diff²(1,2) = (-5)² = 25
diff²(1,3) = (-5)² = 25
... dst
```

**3. Jumlahkan semua:**
```
Σ diff² = 25 + 25 + 25 + ... (81 nilai)
        = 25 × 81 = 2025  (jika semua selisih = 5)
```

**4. Bagi dengan jumlah pixel:**
```
MSE = Σ diff² / (M × N)
    = 2025 / 81
    = 25.00
```

---

# BAGIAN 5: PERHITUNGAN OTSU THRESHOLDING

## Tujuan: Mencari threshold optimal secara otomatis

### Langkah 1: Hitung Histogram

Dari data 9×9 pixel, hitung frekuensi setiap intensitas:

```
Intensitas  Frekuensi
118         1
120         1
122         1
123         1
...         ...
159         1
```

### Langkah 2: Hitung Probabilitas
```
P(i) = Frekuensi(i) / Total_Pixel
P(118) = 1 / 81 = 0.0123
```

### Langkah 3: Untuk setiap threshold t (0-255), hitung:

**Between-class variance:**
```
σ²_B(t) = w₀(t) × w₁(t) × [μ₀(t) - μ₁(t)]²
```

Dimana:
- w₀ = probabilitas kelas background (intensitas 0-t)
- w₁ = probabilitas kelas foreground (intensitas t+1-255)
- μ₀ = mean intensitas kelas background
- μ₁ = mean intensitas kelas foreground

### Langkah 4: Pilih threshold dengan σ²_B maksimum

---

# BAGIAN 6: PERHITUNGAN AKURASI, SENSITIVITAS, SPESIFISITAS

## Confusion Matrix:

```
                    GROUND TRUTH
                    0 (BG)    1 (Edge)
PREDIKSI  0 (BG)      TN         FN
          1 (Edge)    FP         TP
```

### Contoh Data Biner 9×9:

**Ground Truth (GT):**
```
0  0  0  0  1  0  0  0  0
0  0  0  1  1  1  0  0  0
0  0  1  1  1  1  1  0  0
0  1  1  1  1  1  1  1  0
1  1  1  1  1  1  1  1  1
0  1  1  1  1  1  1  1  0
0  0  1  1  1  1  1  0  0
0  0  0  1  1  1  0  0  0
0  0  0  0  1  0  0  0  0
```

**Prediksi (Hasil Segmentasi):**
```
0  0  0  0  1  0  0  0  0
0  0  0  1  1  1  0  0  0
0  0  1  1  1  1  1  0  0
0  1  1  0  1  1  1  1  0     ← Ada kesalahan di (4,4)
1  1  1  1  1  1  1  1  1
0  1  1  1  1  1  1  1  0
0  0  1  1  1  1  0  0  0     ← Ada kesalahan di (7,7)
0  0  0  1  1  1  0  0  0
0  0  0  0  1  0  0  0  0
```

### Hitung Confusion Matrix:

**Bandingkan pixel per pixel:**

| Posisi | GT | Pred | Hasil |
|--------|----|----- |-------|
| (1,1)  | 0  | 0    | TN    |
| (1,5)  | 1  | 1    | TP    |
| (4,4)  | 1  | 0    | FN    |
| (7,7)  | 1  | 0    | FN    |
| ...    |    |      |       |

**Hasil Hitung:**
```
TP = 39 (edge benar terdeteksi)
TN = 38 (background benar terdeteksi)
FP = 0  (salah deteksi edge)
FN = 4  (gagal deteksi edge)
```

### Hitung Metrik:

**Akurasi:**
```
Akurasi = (TP + TN) / Total × 100%
        = (39 + 38) / 81 × 100%
        = 77 / 81 × 100%
        = 95.06%
```

**Sensitivitas:**
```
Sensitivitas = TP / (TP + FN) × 100%
             = 39 / (39 + 4) × 100%
             = 39 / 43 × 100%
             = 90.70%
```

**Spesifisitas:**
```
Spesifisitas = TN / (TN + FP) × 100%
             = 38 / (38 + 0) × 100%
             = 38 / 38 × 100%
             = 100.00%
```

---

# BAGIAN 7: MORFOLOGI (EROSI & DILASI)

## Structuring Element (SE) 3×3:
```
SE = [1  1  1]
     [1  1  1]
     [1  1  1]
```

### EROSI

**Aturan:** Pixel = 1 jika SEMUA pixel di SE = 1

**Contoh untuk pixel (2,2):**
```
Region:  [0  0  0]
         [0  0  0]
         [0  0  1]

SE:      [1  1  1]
         [1  1  1]
         [1  1  1]

Hasil: 0 (karena tidak semua = 1)
```

### DILASI

**Aturan:** Pixel = 1 jika ADA pixel di SE = 1

**Contoh untuk pixel (2,2):**
```
Region:  [0  0  0]
         [0  0  0]
         [0  0  1]

SE:      [1  1  1]
         [1  1  1]
         [1  1  1]

Hasil: 1 (karena ada yang = 1)
```

### OPENING = Erosi → Dilasi
(Menghilangkan noise kecil)

### CLOSING = Dilasi → Erosi
(Menutup lubang kecil)

---

# 📋 LEMBAR KERJA KOSONG

## Untuk Latihan Sendiri:

### Data Citra Asli (isi sendiri):
```
     1    2    3    4    5    6    7    8    9
1   ___  ___  ___  ___  ___  ___  ___  ___  ___
2   ___  ___  ___  ___  ___  ___  ___  ___  ___
3   ___  ___  ___  ___  ___  ___  ___  ___  ___
4   ___  ___  ___  ___  ___  ___  ___  ___  ___
5   ___  ___  ___  ___  ___  ___  ___  ___  ___
6   ___  ___  ___  ___  ___  ___  ___  ___  ___
7   ___  ___  ___  ___  ___  ___  ___  ___  ___
8   ___  ___  ___  ___  ___  ___  ___  ___  ___
9   ___  ___  ___  ___  ___  ___  ___  ___  ___
```

### Hasil Brightness +40:
```
     1    2    3    4    5    6    7    8    9
1   ___  ___  ___  ___  ___  ___  ___  ___  ___
2   ___  ___  ___  ___  ___  ___  ___  ___  ___
3   ___  ___  ___  ___  ___  ___  ___  ___  ___
4   ___  ___  ___  ___  ___  ___  ___  ___  ___
5   ___  ___  ___  ___  ___  ___  ___  ___  ___
6   ___  ___  ___  ___  ___  ___  ___  ___  ___
7   ___  ___  ___  ___  ___  ___  ___  ___  ___
8   ___  ___  ___  ___  ___  ___  ___  ___  ___
9   ___  ___  ___  ___  ___  ___  ___  ___  ___
```

### Perhitungan MSE:
```
Σ diff² = _________________

MSE = Σ diff² / 81 = _____________
```

### Perhitungan Akurasi:
```
TP = ___    TN = ___
FP = ___    FN = ___

Akurasi = (TP + TN) / 81 × 100% = ___%

Sensitivitas = TP / (TP + FN) × 100% = ___%

Spesifisitas = TN / (TN + FP) × 100% = ___%
```

---

**Dokumen ini siap untuk dicetak dan dikerjakan di kertas!** 📝
