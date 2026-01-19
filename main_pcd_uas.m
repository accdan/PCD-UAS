
clc; clear; close all;
inputFolder = 'image';
outputFolder = 'image-hasil';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% ========================================================================
%  BAGIAN 1: PERBAIKAN CITRA DENGAN 3 METODE
% =========================================================================
fprintf('=== BAGIAN 1: PERBAIKAN CITRA ===\n\n');

% Baca citra referensi (yang paling bagus/jelas)
citraReferensi = imread(fullfile(inputFolder, 'plat_nomor_11_sharp.png'));
if size(citraReferensi, 3) == 3
    citraReferensi = rgb2gray_manual(citraReferensi);
end
citraReferensi = double(citraReferensi);

% Baca citra yang akan diperbaiki (pilih yang rusak)
citraInput = imread(fullfile(inputFolder, 'plat_nomor_04_dark.png'));
if size(citraInput, 3) == 3
    citraInput = rgb2gray_manual(citraInput);
end
citraInputDouble = double(citraInput);

fprintf('Citra Referensi: plat_nomor_11_sharp.png\n');
fprintf('Citra Input (rusak): plat_nomor_04_dark.png\n\n');

%% METODE 1: Histogram Equalization (Manual)
fprintf('Metode 1: Histogram Equalization (Manual)\n');
hasil_histeq = histogram_equalization_manual(citraInput);
mse_histeq = hitung_mse(citraReferensi, double(hasil_histeq));
fprintf('MSE Histogram Equalization: %.4f\n\n', mse_histeq);

%% METODE 2: Contrast Stretching (Manual)
fprintf('Metode 2: Contrast Stretching (Manual)\n');
hasil_contrast = contrast_stretching_manual(citraInput);
mse_contrast = hitung_mse(citraReferensi, double(hasil_contrast));
fprintf('MSE Contrast Stretching: %.4f\n\n', mse_contrast);

%% METODE 3: Power Law (Gamma) Transformation (Manual)
fprintf('Metode 3: Power Law / Gamma Transformation (Manual)\n');
gamma = 0.5; % Gamma < 1 untuk mencerahkan gambar gelap
hasil_gamma = power_law_manual(citraInput, gamma);
mse_gamma = hitung_mse(citraReferensi, double(hasil_gamma));
fprintf('MSE Gamma Transformation (gamma=%.1f): %.4f\n\n', gamma, mse_gamma);

%% Menentukan Ranking Metode Berdasarkan MSE
fprintf('=== RANKING METODE PERBAIKAN (Berdasarkan MSE) ===\n');
metode_names = {'Histogram Equalization', 'Contrast Stretching', 'Gamma Transformation'};
mse_values = [mse_histeq, mse_contrast, mse_gamma];
hasil_perbaikan = {hasil_histeq, hasil_contrast, hasil_gamma};

[mse_sorted, idx_sorted] = sort(mse_values, 'ascend');

fprintf('Peringkat 1 (Terbaik): %s - MSE: %.4f\n', metode_names{idx_sorted(1)}, mse_sorted(1));
fprintf('Peringkat 2: %s - MSE: %.4f\n', metode_names{idx_sorted(2)}, mse_sorted(2));
fprintf('Peringkat 3: %s - MSE: %.4f\n\n', metode_names{idx_sorted(3)}, mse_sorted(3));

% Simpan hasil perbaikan terbaik
citraTerbaik = hasil_perbaikan{idx_sorted(1)};
imwrite(uint8(citraTerbaik), fullfile(outputFolder, 'hasil_perbaikan_terbaik.png'));
imwrite(uint8(hasil_histeq), fullfile(outputFolder, 'hasil_histogram_eq.png'));
imwrite(uint8(hasil_contrast), fullfile(outputFolder, 'hasil_contrast_stretch.png'));
imwrite(uint8(hasil_gamma), fullfile(outputFolder, 'hasil_gamma_transform.png'));

%% Visualisasi Hasil Perbaikan
figure('Name', 'Hasil Perbaikan Citra', 'Position', [100, 100, 1200, 800]);

subplot(2,3,1);
imshow(uint8(citraReferensi));
title('Citra Referensi (Sharp)');

subplot(2,3,2);
imshow(citraInput);
title('Citra Input (Dark)');

subplot(2,3,4);
imshow(uint8(hasil_histeq));
title(sprintf('Histogram Eq\nMSE: %.2f', mse_histeq));

subplot(2,3,5);
imshow(uint8(hasil_contrast));
title(sprintf('Contrast Stretch\nMSE: %.2f', mse_contrast));

subplot(2,3,6);
imshow(uint8(hasil_gamma));
title(sprintf('Gamma Transform\nMSE: %.2f', mse_gamma));

subplot(2,3,3);
imshow(uint8(citraTerbaik));
title(sprintf('TERBAIK: %s', metode_names{idx_sorted(1)}));

saveas(gcf, fullfile(outputFolder, 'perbandingan_perbaikan.png'));

%% ========================================================================
%  BAGIAN 2: SEGMENTASI DENGAN 3 METODE (dari hasil terbaik)
% =========================================================================
fprintf('\n=== BAGIAN 2: SEGMENTASI CITRA ===\n\n');

citraSegmentasi = double(citraTerbaik);

%% METODE SEGMENTASI 1: Otsu Thresholding (Manual)
fprintf('Metode Segmentasi 1: Otsu Thresholding (Manual)\n');
[hasil_otsu, threshold_otsu] = otsu_threshold_manual(uint8(citraSegmentasi));
fprintf('Threshold Otsu: %d\n\n', threshold_otsu);

%% METODE SEGMENTASI 2: Adaptive Thresholding (Manual)
fprintf('Metode Segmentasi 2: Adaptive Thresholding (Manual)\n');
blockSize = 15;
C = 5;
hasil_adaptive = adaptive_threshold_manual(uint8(citraSegmentasi), blockSize, C);
fprintf('Block Size: %d, Konstanta C: %d\n\n', blockSize, C);

%% METODE SEGMENTASI 3: Global Thresholding dengan Iterative Method (Manual)
fprintf('Metode Segmentasi 3: Iterative Global Thresholding (Manual)\n');
[hasil_iterative, threshold_iterative] = iterative_threshold_manual(uint8(citraSegmentasi));
fprintf('Threshold Iterative: %d\n\n', threshold_iterative);

% Simpan hasil segmentasi
imwrite(hasil_otsu, fullfile(outputFolder, 'segmentasi_otsu.png'));
imwrite(hasil_adaptive, fullfile(outputFolder, 'segmentasi_adaptive.png'));
imwrite(hasil_iterative, fullfile(outputFolder, 'segmentasi_iterative.png'));

%% Visualisasi Hasil Segmentasi
figure('Name', 'Hasil Segmentasi', 'Position', [100, 100, 1000, 400]);

subplot(1,4,1);
imshow(uint8(citraSegmentasi));
title('Citra Input Segmentasi');

subplot(1,4,2);
imshow(hasil_otsu);
title(sprintf('Otsu (T=%d)', threshold_otsu));

subplot(1,4,3);
imshow(hasil_adaptive);
title(sprintf('Adaptive (B=%d)', blockSize));

subplot(1,4,4);
imshow(hasil_iterative);
title(sprintf('Iterative (T=%d)', threshold_iterative));

saveas(gcf, fullfile(outputFolder, 'perbandingan_segmentasi.png'));

%% ========================================================================
%  BAGIAN 3: MORFOLOGI DAN AKURASI
% =========================================================================
fprintf('\n=== BAGIAN 3: OPERASI MORFOLOGI ===\n\n');

% Gunakan hasil segmentasi Otsu untuk morfologi
citraBiner = hasil_otsu;

% Buat Structuring Element (SE) 3x3 persegi
SE = ones(3, 3);

%% Operasi Morfologi Manual
fprintf('Melakukan operasi morfologi...\n\n');

% 1. Erosi Manual
hasil_erosi = erosi_manual(citraBiner, SE);

% 2. Dilasi Manual
hasil_dilasi = dilasi_manual(citraBiner, SE);

% 3. Opening Manual (Erosi kemudian Dilasi)
hasil_opening = dilasi_manual(erosi_manual(citraBiner, SE), SE);

% 4. Closing Manual (Dilasi kemudian Erosi)
hasil_closing = erosi_manual(dilasi_manual(citraBiner, SE), SE);

% Simpan hasil morfologi
imwrite(hasil_erosi, fullfile(outputFolder, 'morfologi_erosi.png'));
imwrite(hasil_dilasi, fullfile(outputFolder, 'morfologi_dilasi.png'));
imwrite(hasil_opening, fullfile(outputFolder, 'morfologi_opening.png'));
imwrite(hasil_closing, fullfile(outputFolder, 'morfologi_closing.png'));

%% Visualisasi Hasil Morfologi
figure('Name', 'Hasil Morfologi', 'Position', [100, 100, 1200, 400]);

subplot(1,5,1);
imshow(citraBiner);
title('Citra Biner Asli');

subplot(1,5,2);
imshow(hasil_erosi);
title('Erosi');

subplot(1,5,3);
imshow(hasil_dilasi);
title('Dilasi');

subplot(1,5,4);
imshow(hasil_opening);
title('Opening');

subplot(1,5,5);
imshow(hasil_closing);
title('Closing');

saveas(gcf, fullfile(outputFolder, 'perbandingan_morfologi.png'));

%% ========================================================================
%  PERHITUNGAN AKURASI SEGMENTASI
% =========================================================================
fprintf('\n=== PERHITUNGAN AKURASI SEGMENTASI ===\n\n');

% Gunakan hasil Otsu sebagai Ground Truth (referensi)
groundTruth = hasil_otsu;

% Hitung akurasi masing-masing metode segmentasi
akurasi_otsu = hitung_akurasi(groundTruth, hasil_otsu);
akurasi_adaptive = hitung_akurasi(groundTruth, hasil_adaptive);
akurasi_iterative = hitung_akurasi(groundTruth, hasil_iterative);

fprintf('Akurasi Otsu (sebagai referensi): %.2f%%\n', akurasi_otsu);
fprintf('Akurasi Adaptive Thresholding: %.2f%%\n', akurasi_adaptive);
fprintf('Akurasi Iterative Thresholding: %.2f%%\n\n', akurasi_iterative);

% Hitung juga metrik lainnya
fprintf('=== METRIK EVALUASI SEGMENTASI DETAIL ===\n');
fprintf('\n--- Metode Otsu vs Ground Truth ---\n');
[acc, sens, spec, prec] = hitung_metrik_segmentasi(groundTruth, hasil_otsu);
fprintf('Accuracy: %.2f%%, Sensitivity: %.2f%%, Specificity: %.2f%%, Precision: %.2f%%\n', acc, sens, spec, prec);

fprintf('\n--- Metode Adaptive vs Ground Truth ---\n');
[acc, sens, spec, prec] = hitung_metrik_segmentasi(groundTruth, hasil_adaptive);
fprintf('Accuracy: %.2f%%, Sensitivity: %.2f%%, Specificity: %.2f%%, Precision: %.2f%%\n', acc, sens, spec, prec);

fprintf('\n--- Metode Iterative vs Ground Truth ---\n');
[acc, sens, spec, prec] = hitung_metrik_segmentasi(groundTruth, hasil_iterative);
fprintf('Accuracy: %.2f%%, Sensitivity: %.2f%%, Specificity: %.2f%%, Precision: %.2f%%\n', acc, sens, spec, prec);

%% Ringkasan Hasil Akhir
fprintf('\n');
fprintf('========================================\n');
fprintf('         RINGKASAN HASIL AKHIR         \n');
fprintf('========================================\n');
fprintf('\n[PERBAIKAN CITRA]\n');
fprintf('Metode Terbaik: %s\n', metode_names{idx_sorted(1)});
fprintf('Nilai MSE: %.4f\n', mse_sorted(1));

fprintf('\n[SEGMENTASI]\n');
fprintf('3 Metode: Otsu, Adaptive, Iterative\n');
fprintf('Threshold Otsu: %d\n', threshold_otsu);

fprintf('\n[MORFOLOGI]\n');
fprintf('Operasi: Erosi, Dilasi, Opening, Closing\n');
fprintf('Structuring Element: 3x3\n');

fprintf('\n[AKURASI]\n');
fprintf('Adaptive vs Otsu: %.2f%%\n', akurasi_adaptive);
fprintf('Iterative vs Otsu: %.2f%%\n', akurasi_iterative);

fprintf('\nSemua hasil disimpan di folder: %s\n', outputFolder);
fprintf('========================================\n');

%% ========================================================================
%  FUNGSI-FUNGSI MANUAL (TANPA LIBRARY)
% =========================================================================

%% Fungsi Konversi RGB ke Grayscale Manual
function gray = rgb2gray_manual(rgb)
    % Konversi RGB ke Grayscale menggunakan formula standar
    % Y = 0.299*R + 0.587*G + 0.114*B
    R = double(rgb(:,:,1));
    G = double(rgb(:,:,2));
    B = double(rgb(:,:,3));
    gray = uint8(0.299*R + 0.587*G + 0.114*B);
end

%% Fungsi Hitung MSE Manual
function mse = hitung_mse(citra1, citra2)
    % Pastikan ukuran sama
    [m1, n1] = size(citra1);
    [m2, n2] = size(citra2);
    
    % Resize jika ukuran berbeda
    if m1 ~= m2 || n1 ~= n2
        citra2 = imresize_manual(citra2, [m1, n1]);
    end
    
    % Hitung MSE
    diff = double(citra1) - double(citra2);
    mse = sum(sum(diff.^2)) / (m1 * n1);
end

%% Fungsi Resize Manual (Nearest Neighbor)
function resized = imresize_manual(img, newSize)
    [oldM, oldN] = size(img);
    newM = newSize(1);
    newN = newSize(2);
    
    resized = zeros(newM, newN);
    
    rowScale = oldM / newM;
    colScale = oldN / newN;
    
    for i = 1:newM
        for j = 1:newN
            oldRow = round((i - 0.5) * rowScale + 0.5);
            oldCol = round((j - 0.5) * colScale + 0.5);
            
            oldRow = max(1, min(oldM, oldRow));
            oldCol = max(1, min(oldN, oldCol));
            
            resized(i, j) = img(oldRow, oldCol);
        end
    end
end

%% Fungsi Histogram Equalization Manual
function hasil = histogram_equalization_manual(img)
    img = double(img);
    [m, n] = size(img);
    totalPixels = m * n;
    
    % Hitung histogram
    histogram = zeros(1, 256);
    for i = 1:m
        for j = 1:n
            intensitas = round(img(i, j)) + 1;
            intensitas = max(1, min(256, intensitas));
            histogram(intensitas) = histogram(intensitas) + 1;
        end
    end
    
    % Hitung CDF (Cumulative Distribution Function)
    cdf = zeros(1, 256);
    cdf(1) = histogram(1);
    for i = 2:256
        cdf(i) = cdf(i-1) + histogram(i);
    end
    
    % Normalisasi CDF
    cdf_min = min(cdf(cdf > 0));
    lut = zeros(1, 256);
    for i = 1:256
        lut(i) = round(((cdf(i) - cdf_min) / (totalPixels - cdf_min)) * 255);
    end
    
    % Terapkan LUT ke citra
    hasil = zeros(m, n);
    for i = 1:m
        for j = 1:n
            intensitas = round(img(i, j)) + 1;
            intensitas = max(1, min(256, intensitas));
            hasil(i, j) = lut(intensitas);
        end
    end
    
    hasil = uint8(hasil);
end

%% Fungsi Contrast Stretching Manual
function hasil = contrast_stretching_manual(img)
    img = double(img);
    
    % Cari nilai minimum dan maximum
    minVal = min(img(:));
    maxVal = max(img(:));
    
    % Hindari pembagian dengan nol
    if maxVal == minVal
        hasil = uint8(img);
        return;
    end
    
    % Terapkan contrast stretching
    % Formula: Out = (In - min) / (max - min) * 255
    hasil = ((img - minVal) / (maxVal - minVal)) * 255;
    hasil = uint8(hasil);
end

%% Fungsi Power Law (Gamma) Transformation Manual
function hasil = power_law_manual(img, gamma)
    img = double(img);
    
    % Normalisasi ke rentang [0, 1]
    imgNorm = img / 255;
    
    % Terapkan power law: s = c * r^gamma
    c = 1; % konstanta
    hasilNorm = c * (imgNorm .^ gamma);
    
    % Kembalikan ke rentang [0, 255]
    hasil = hasilNorm * 255;
    hasil = uint8(min(255, max(0, hasil)));
end

%% Fungsi Otsu Thresholding Manual
function [biner, threshold] = otsu_threshold_manual(img)
    img = double(img);
    [m, n] = size(img);
    totalPixels = m * n;
    
    % Hitung histogram
    histogram = zeros(1, 256);
    for i = 1:m
        for j = 1:n
            intensitas = round(img(i, j)) + 1;
            intensitas = max(1, min(256, intensitas));
            histogram(intensitas) = histogram(intensitas) + 1;
        end
    end
    
    % Normalisasi histogram
    prob = histogram / totalPixels;
    
    % Hitung mean global
    meanGlobal = 0;
    for i = 1:256
        meanGlobal = meanGlobal + (i-1) * prob(i);
    end
    
    % Cari threshold optimal dengan memaksimalkan between-class variance
    maxVariance = 0;
    threshold = 0;
    
    for t = 1:255
        % Hitung probabilitas kelas
        w0 = sum(prob(1:t));
        w1 = sum(prob(t+1:256));
        
        if w0 == 0 || w1 == 0
            continue;
        end
        
        % Hitung mean kelas
        mean0 = 0;
        for i = 1:t
            mean0 = mean0 + (i-1) * prob(i);
        end
        mean0 = mean0 / w0;
        
        mean1 = 0;
        for i = t+1:256
            mean1 = mean1 + (i-1) * prob(i);
        end
        mean1 = mean1 / w1;
        
        % Hitung between-class variance
        variance = w0 * w1 * (mean0 - mean1)^2;
        
        if variance > maxVariance
            maxVariance = variance;
            threshold = t - 1;
        end
    end
    
    % Terapkan thresholding
    biner = img > threshold;
    biner = logical(biner);
end

%% Fungsi Adaptive Thresholding Manual
function biner = adaptive_threshold_manual(img, blockSize, C)
    img = double(img);
    [m, n] = size(img);
    biner = zeros(m, n);
    
    halfBlock = floor(blockSize / 2);
    
    for i = 1:m
        for j = 1:n
            % Tentukan batas blok
            rowStart = max(1, i - halfBlock);
            rowEnd = min(m, i + halfBlock);
            colStart = max(1, j - halfBlock);
            colEnd = min(n, j + halfBlock);
            
            % Ambil blok lokal
            blok = img(rowStart:rowEnd, colStart:colEnd);
            
            % Hitung mean lokal
            meanLokal = sum(blok(:)) / numel(blok);
            
            % Threshold = mean lokal - C
            threshold = meanLokal - C;
            
            % Terapkan thresholding
            if img(i, j) > threshold
                biner(i, j) = 1;
            else
                biner(i, j) = 0;
            end
        end
    end
    
    biner = logical(biner);
end

%% Fungsi Iterative Thresholding Manual
function [biner, threshold] = iterative_threshold_manual(img)
    img = double(img);
    
    % Threshold awal = mean dari citra
    threshold = mean(img(:));
    deltaT = 1; % konvergensi
    
    while true
        % Bagi piksel menjadi dua grup
        g1 = img(img <= threshold);
        g2 = img(img > threshold);
        
        % Hitung mean masing-masing grup
        if isempty(g1)
            m1 = 0;
        else
            m1 = mean(g1);
        end
        
        if isempty(g2)
            m2 = 255;
        else
            m2 = mean(g2);
        end
        
        % Threshold baru = rata-rata dari kedua mean
        thresholdBaru = (m1 + m2) / 2;
        
        % Cek konvergensi
        if abs(thresholdBaru - threshold) < deltaT
            break;
        end
        
        threshold = thresholdBaru;
    end
    
    threshold = round(threshold);
    
    % Terapkan thresholding
    biner = img > threshold;
    biner = logical(biner);
end

%% Fungsi Erosi Manual
function hasil = erosi_manual(img, SE)
    img = double(img);
    [m, n] = size(img);
    [seM, seN] = size(SE);
    
    padM = floor(seM / 2);
    padN = floor(seN / 2);
    
    % Padding dengan 0
    imgPad = zeros(m + 2*padM, n + 2*padN);
    imgPad(padM+1:padM+m, padN+1:padN+n) = img;
    
    hasil = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            % Ambil region
            region = imgPad(i:i+seM-1, j:j+seN-1);
            
            % Erosi: minimum dari region yang overlap dengan SE
            overlap = region .* SE;
            
            % Cek apakah semua elemen SE fit (untuk binary erosion)
            if all(overlap(SE == 1) >= 1)
                hasil(i, j) = 1;
            else
                hasil(i, j) = 0;
            end
        end
    end
    
    hasil = logical(hasil);
end

%% Fungsi Dilasi Manual
function hasil = dilasi_manual(img, SE)
    img = double(img);
    [m, n] = size(img);
    [seM, seN] = size(SE);
    
    padM = floor(seM / 2);
    padN = floor(seN / 2);
    
    % Padding dengan 0
    imgPad = zeros(m + 2*padM, n + 2*padN);
    imgPad(padM+1:padM+m, padN+1:padN+n) = img;
    
    hasil = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            % Ambil region
            region = imgPad(i:i+seM-1, j:j+seN-1);
            
            % Dilasi: maximum dari region yang overlap dengan SE
            overlap = region .* SE;
            
            % Cek apakah ada elemen yang overlap
            if any(overlap(:) >= 1)
                hasil(i, j) = 1;
            else
                hasil(i, j) = 0;
            end
        end
    end
    
    hasil = logical(hasil);
end

%% Fungsi Hitung Akurasi
function akurasi = hitung_akurasi(groundTruth, prediksi)
    gt = double(groundTruth(:));
    pred = double(prediksi(:));
    
    % Hitung jumlah piksel yang sama
    sama = sum(gt == pred);
    total = length(gt);
    
    akurasi = (sama / total) * 100;
end

%% Fungsi Hitung Metrik Segmentasi Detail
function [accuracy, sensitivity, specificity, precision] = hitung_metrik_segmentasi(groundTruth, prediksi)
    gt = double(groundTruth(:));
    pred = double(prediksi(:));
    
    % True Positive: GT=1, Pred=1
    TP = sum((gt == 1) & (pred == 1));
    
    % True Negative: GT=0, Pred=0
    TN = sum((gt == 0) & (pred == 0));
    
    % False Positive: GT=0, Pred=1
    FP = sum((gt == 0) & (pred == 1));
    
    % False Negative: GT=1, Pred=0
    FN = sum((gt == 1) & (pred == 0));
    
    % Hitung metrik
    accuracy = ((TP + TN) / (TP + TN + FP + FN)) * 100;
    
    if (TP + FN) == 0
        sensitivity = 0;
    else
        sensitivity = (TP / (TP + FN)) * 100;
    end
    
    if (TN + FP) == 0
        specificity = 0;
    else
        specificity = (TN / (TN + FP)) * 100;
    end
    
    if (TP + FP) == 0
        precision = 0;
    else
        precision = (TP / (TP + FP)) * 100;
    end
end
