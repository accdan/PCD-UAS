%% ========================================================================
%  HITUNG AKURASI - SEGMENTASI DAN MORFOLOGI
%  Membandingkan Ground Truth dengan 3 Metode Segmentasi
% =========================================================================
% Author: PCD-UAS Project
% Date: 2026-01-19
% Description: 
%   - Menggunakan metode terbaik dari hasil MSE sebagai Ground Truth
%   - Membandingkan dengan 3 metode segmentasi (Sobel, Prewitt, LoG)
%   - Menghitung Akurasi, Sensitivitas, dan Spesifisitas
%   - Menyimpan hasil ke folder image-hasil-terbaik dan Table-Accuration
% =========================================================================

clc; clear; close all;

%% Konfigurasi Folder
inputFolder = '2_plat-image';
mseResultFolder = 'image-hasil-mse';
outputFolder = 'image-hasil-terbaik';
tableFolder = 'Table-Accuration';
mseTableFolder = 'Table-Mse';

% Subfolder untuk hasil
citraAsliFolder = fullfile(outputFolder, 'citra-asli');
citraAsliGTFolder = fullfile(outputFolder, 'citra-asli-groundtruth');
sobelGTFolder = fullfile(outputFolder, 'sobel-groundtruth');
prewittGTFolder = fullfile(outputFolder, 'prewitt-groundtruth');
logGTFolder = fullfile(outputFolder, 'log-groundtruth');

%% Cek Hasil Lama & Menu Pilihan
hasOldOutput = exist(outputFolder, 'dir') && length(dir(fullfile(outputFolder, '**/*.*'))) > 2;
hasOldTable = exist(tableFolder, 'dir') && length(dir(fullfile(tableFolder, '*.*'))) > 2;

if hasOldOutput || hasOldTable
    fprintf('----------------------------------------------------------\n');
    fprintf('  DITEMUKAN HASIL PENGOLAHAN SEBELUMNYA!\n');
    fprintf('----------------------------------------------------------\n');
    fprintf('1. Hapus hasil lama & proses ulang dari awal\n');
    fprintf('2. Lanjutkan tanpa hapus (timpa file lama)\n');
    fprintf('----------------------------------------------------------\n');
    
    pilihanHapus = input('Pilih (1/2): ');
    
    if pilihanHapus == 1
        fprintf('\nMenghapus hasil lama...\n');
        if exist(outputFolder, 'dir')
            rmdir(outputFolder, 's');
            fprintf('  ✓ Folder %s dihapus\n', outputFolder);
        end
        if exist(tableFolder, 'dir')
            rmdir(tableFolder, 's');
            fprintf('  ✓ Folder %s dihapus\n', tableFolder);
        end
        fprintf('\n');
    else
        fprintf('\nMelanjutkan tanpa hapus...\n\n');
    end
end

% Buat semua folder
folders = {outputFolder, citraAsliFolder, citraAsliGTFolder, ...
           sobelGTFolder, prewittGTFolder, logGTFolder, tableFolder};
for i = 1:length(folders)
    if ~exist(folders{i}, 'dir')
        mkdir(folders{i});
    end
end

fprintf('==========================================================\n');
fprintf('      PERHITUNGAN AKURASI - SEGMENTASI & MORFOLOGI\n');
fprintf('==========================================================\n\n');

%% Load Informasi Metode Terbaik dari MSE
if exist(fullfile(mseTableFolder, 'best_method_info.mat'), 'file')
    load(fullfile(mseTableFolder, 'best_method_info.mat'));
    fprintf('Metode terbaik dari MSE:\n');
    fprintf('  - Edge Detection: %s\n', methodNames{bestMethodIdx});
    fprintf('  - Teknik Perbaikan: %s\n', techniqueNames{bestTechniqueIdx});
    
    % Cek apakah ada informasi gambar referensi
    if exist('bestImageName', 'var')
        fprintf('  - Gambar Referensi: %s\n', bestImageName);
        fprintf('  - Index Referensi: %d\n\n', bestImageIdx);
    else
        fprintf('\nWARNING: Gambar referensi tidak ditemukan!\n');
        fprintf('Jalankan ulang hitung_mse.m untuk mendapatkan gambar referensi.\n\n');
        bestImageName = '';
        bestImageIdx = 0;
    end
else
    % Default jika file tidak ditemukan
    fprintf('WARNING: File best_method_info.mat tidak ditemukan!\n');
    fprintf('Menggunakan default: Sobel + Improve_Brightness\n\n');
    bestMethodIdx = 1;  % Sobel
    bestTechniqueIdx = 5;  % Improve Brightness
    methodNames = {'Sobel', 'Prewitt', 'LoG'};
    techniqueNames = {'Brightness_40', 'Contrast_15', 'Combination', 'Nonlinear_Mapping', 'Improve_Brightness'};
    bestImageName = '';
    bestImageIdx = 0;
end

%% Mapping teknik perbaikan ke suffix file
techniqueSuffix = {'_brightness40', '_contrast15', '_combination', '_nonlinear', '_improve'};
selectedSuffix = techniqueSuffix{bestTechniqueIdx};

%% Daftar Gambar
imageFiles = [dir(fullfile(inputFolder, '*.png')); ...
              dir(fullfile(inputFolder, '*.jpg')); ...
              dir(fullfile(inputFolder, '*.jpeg')); ...
              dir(fullfile(inputFolder, '*.bmp'))];
numImages = length(imageFiles);

fprintf('Jumlah gambar yang akan diproses: %d\n\n', numImages);

%% Inisialisasi Tabel Hasil
% 3 baris untuk 3 metode (Sobel, Prewitt, LoG)
% Kolom: [Akurasi, Sensitivitas, Spesifisitas]
results = zeros(3, 3, numImages);  % 3 metode x 3 metrik x 15 gambar
imageNamesList = cell(numImages, 1);
segmentationMethods = {'Sobel', 'Prewitt', 'LoG'};

%% Buat Ground Truth dari Gambar Referensi Terbaik
if ~isempty(bestImageName)
    fprintf('========================================================================\n');
    fprintf('  MEMBUAT GROUND TRUTH DARI GAMBAR REFERENSI TERBAIK\n');
    fprintf('========================================================================\n');
    fprintf('Gambar Referensi: %s\n\n', bestImageName);
    
    % Baca gambar referensi yang sudah diproses dengan teknik terbaik
    [~, refBaseName, ~] = fileparts(bestImageName);
    refEnhancedFile = fullfile(mseResultFolder, [refBaseName selectedSuffix '.png']);
    
    if exist(refEnhancedFile, 'file')
        imgRef = imread(refEnhancedFile);
        if size(imgRef, 3) == 3
            imgRef = rgb2gray_manual(imgRef);
        end
        
        % Edge detection dengan metode terbaik
        imgRefDouble = double(imgRef);
        switch bestMethodIdx
            case 1  % Sobel
                edgeRef = sobel_edge_detection(imgRefDouble);
            case 2  % Prewitt
                edgeRef = prewitt_edge_detection(imgRefDouble);
            case 3  % LoG
                edgeRef = log_edge_detection(imgRefDouble);
        end
        
        % Otsu thresholding
        [groundTruthReference, thresholdRef] = otsu_threshold_manual(uint8(edgeRef));
        
        % Morfologi
        SE = ones(3, 3);
        groundTruthReference = dilasi_manual(erosi_manual(groundTruthReference, SE), SE);  % Opening
        groundTruthReference = erosi_manual(dilasi_manual(groundTruthReference, SE), SE);  % Closing
        
        % Simpan Ground Truth Referensi
        imwrite(groundTruthReference, fullfile(citraAsliGTFolder, 'ground_truth_reference.png'));
        
        fprintf('✓ Ground Truth Reference berhasil dibuat\n');
        fprintf('  Threshold: %d\n\n', thresholdRef);
    else
        error('File hasil perbaikan referensi tidak ditemukan: %s', refEnhancedFile);
    end
else
    error('Gambar referensi tidak tersedia! Jalankan hitung_mse.m terlebih dahulu.');
end

%% Proses Setiap Gambar
for idx = 1:numImages
    imageName = imageFiles(idx).name;
    [~, baseName, ~] = fileparts(imageName);
    imageNamesList{idx} = imageName;
    
    fprintf('Processing [%d/%d]: %s\n', idx, numImages, imageName);
    
    % Baca citra asli
    imgOriginal = imread(fullfile(inputFolder, imageName));
    if size(imgOriginal, 3) == 3
        imgOriginal = rgb2gray_manual(imgOriginal);
    end
    
    % Simpan citra asli
    imwrite(imgOriginal, fullfile(citraAsliFolder, imageName));
    
    %% STEP 1: Segmentasi citra asli dengan 3 metode
    imgOriginalDouble = double(imgOriginal);
    SE = ones(3, 3);
    
    % Metode 1: Sobel
    edgeSobel = sobel_edge_detection(imgOriginalDouble);
    [sobelGT, thresholdSobel] = otsu_threshold_manual(uint8(edgeSobel));
    sobelGT = dilasi_manual(erosi_manual(sobelGT, SE), SE);  % Opening
    sobelGT = erosi_manual(dilasi_manual(sobelGT, SE), SE);  % Closing
    imwrite(sobelGT, fullfile(sobelGTFolder, [baseName '_sobel_gt.png']));
    
    % Metode 2: Prewitt
    edgePrewitt = prewitt_edge_detection(imgOriginalDouble);
    [prewittGT, thresholdPrewitt] = otsu_threshold_manual(uint8(edgePrewitt));
    prewittGT = dilasi_manual(erosi_manual(prewittGT, SE), SE);  % Opening
    prewittGT = erosi_manual(dilasi_manual(prewittGT, SE), SE);  % Closing
    imwrite(prewittGT, fullfile(prewittGTFolder, [baseName '_prewitt_gt.png']));
    
    % Metode 3: LoG
    edgeLog = log_edge_detection(imgOriginalDouble);
    [logGT, thresholdLog] = otsu_threshold_manual(uint8(edgeLog));
    logGT = dilasi_manual(erosi_manual(logGT, SE), SE);  % Opening
    logGT = erosi_manual(dilasi_manual(logGT, SE), SE);  % Closing
    imwrite(logGT, fullfile(logGTFolder, [baseName '_log_gt.png']));
    
    fprintf('  - Sobel threshold: %d\n', thresholdSobel);
    fprintf('  - Prewitt threshold: %d\n', thresholdPrewitt);
    fprintf('  - LoG threshold: %d\n', thresholdLog);
    
    %% STEP 2: Hitung Akurasi untuk setiap metode (vs Ground Truth Referensi)
    segmentedResults = {sobelGT, prewittGT, logGT};
    
    for m = 1:3
        % Resize jika perlu
        [gtRows, gtCols] = size(groundTruthReference);
        [resRows, resCols] = size(segmentedResults{m});
        
        if gtRows ~= resRows || gtCols ~= resCols
            segmentedResized = imresize_manual(double(segmentedResults{m}), [gtRows, gtCols]);
            segmentedResized = logical(segmentedResized > 0.5);
        else
            segmentedResized = segmentedResults{m};
        end
        
        % Hitung metrik (dibandingkan dengan Ground Truth Referensi)
        [accuracy, sensitivity, specificity] = hitung_metrik_segmentasi(groundTruthReference, segmentedResized);
        
        results(m, 1, idx) = accuracy;
        results(m, 2, idx) = sensitivity;
        results(m, 3, idx) = specificity;
        
        fprintf('  - %s: Akurasi=%.2f%%, Sens=%.2f%%, Spec=%.2f%%\n', ...
            segmentationMethods{m}, accuracy, sensitivity, specificity);
    end
    
    fprintf('\n');
end

%% Generate Tabel Akurasi dan Simpan ke File TXT
fprintf('Generating Accuracy Table...\n');

fid = fopen(fullfile(tableFolder, 'akurasi_table.txt'), 'w');

% Header
fprintf(fid, '========================================================================================\n');
fprintf(fid, '                    TABEL AKURASI SEGMENTASI & MORFOLOGI\n');
fprintf(fid, '         Perbandingan 3 Metode Segmentasi dengan Ground Truth Referensi\n');
fprintf(fid, '========================================================================================\n\n');
fprintf(fid, 'Tanggal              : %s\n', datestr(now, 'dd-mm-yyyy HH:MM:SS'));
fprintf(fid, 'Ground Truth Referensi:\n');
fprintf(fid, '  - Gambar           : %s\n', bestImageName);
fprintf(fid, '  - Metode           : %s\n', methodNames{bestMethodIdx});
fprintf(fid, '  - Teknik           : %s\n', techniqueNames{bestTechniqueIdx});
fprintf(fid, 'Metode Segmentasi    : Sobel, Prewitt, LoG\n');
fprintf(fid, 'Structuring Element  : 3x3 (Opening + Closing)\n\n');

% Tabel untuk setiap metode
for m = 1:3
    fprintf(fid, '========================================================================================\n');
    fprintf(fid, 'METODE SEGMENTASI: %s\n', segmentationMethods{m});
    fprintf(fid, '========================================================================================\n');
    fprintf(fid, '| No | %-28s | Akurasi (%%) | Sensitivitas (%%) | Spesifisitas (%%) |\n', 'Image Name');
    fprintf(fid, '----------------------------------------------------------------------------------------\n');
    
    for idx = 1:numImages
        fprintf(fid, '| %2d | %-28s | %11.2f | %16.2f | %16.2f |\n', ...
            idx, imageNamesList{idx}, results(m, 1, idx), results(m, 2, idx), results(m, 3, idx));
    end
    
    % Rata-rata
    fprintf(fid, '----------------------------------------------------------------------------------------\n');
    fprintf(fid, '|    | %-28s | %11.2f | %16.2f | %16.2f |\n', ...
        'RATA-RATA', mean(results(m, 1, :)), mean(results(m, 2, :)), mean(results(m, 3, :)));
    fprintf(fid, '========================================================================================\n\n');
end

% Ringkasan perbandingan
fprintf(fid, '========================================================================================\n');
fprintf(fid, '                       RINGKASAN PERBANDINGAN METODE\n');
fprintf(fid, '========================================================================================\n');
fprintf(fid, '| Metode  | Rata-rata Akurasi | Rata-rata Sensitivitas | Rata-rata Spesifisitas |\n');
fprintf(fid, '----------------------------------------------------------------------------------------\n');
for m = 1:3
    fprintf(fid, '| %-7s | %17.2f | %22.2f | %22.2f |\n', ...
        segmentationMethods{m}, mean(results(m, 1, :)), mean(results(m, 2, :)), mean(results(m, 3, :)));
end
fprintf(fid, '========================================================================================\n\n');

% Tentukan metode terbaik
[~, bestSegMethod] = max(mean(results(:, 1, :), 3));
fprintf(fid, '*** METODE SEGMENTASI TERBAIK (Akurasi Tertinggi) ***\n');
fprintf(fid, 'Metode: %s\n', segmentationMethods{bestSegMethod});
fprintf(fid, 'Akurasi Rata-rata: %.2f%%\n', mean(results(bestSegMethod, 1, :)));
fprintf(fid, '========================================================================================\n\n');

% Keterangan
fprintf(fid, 'KETERANGAN:\n');
fprintf(fid, '----------------------------------------------------------------------------------------\n');
fprintf(fid, 'Ground Truth dibuat dari:\n');
fprintf(fid, '  1. Citra asli + Perbaikan terbaik MSE (%s)\n', techniqueNames{bestTechniqueIdx});
fprintf(fid, '  2. Edge detection dengan metode terbaik MSE (%s)\n', methodNames{bestMethodIdx});
fprintf(fid, '  3. Otsu thresholding + Morfologi (Opening + Closing)\n\n');
fprintf(fid, 'Setiap metode segmentasi:\n');
fprintf(fid, '  1. Citra asli + Edge detection (Sobel/Prewitt/LoG)\n');
fprintf(fid, '  2. Otsu thresholding + Morfologi (Opening + Closing)\n');
fprintf(fid, '  3. Dibandingkan dengan Ground Truth\n\n');
fprintf(fid, 'Metrik:\n');
fprintf(fid, '  - Akurasi      = (TP + TN) / Total x 100%%\n');
fprintf(fid, '  - Sensitivitas = TP / (TP + FN) x 100%%\n');
fprintf(fid, '  - Spesifisitas = TN / (TN + FP) x 100%%\n');
fprintf(fid, '========================================================================================\n');

fclose(fid);

%% Tampilkan Ringkasan di Command Window
fprintf('\n==========================================================\n');
fprintf('                 RINGKASAN HASIL AKURASI\n');
fprintf('==========================================================\n');
fprintf('Ground Truth: %s + %s\n', methodNames{bestMethodIdx}, techniqueNames{bestTechniqueIdx});
fprintf('----------------------------------------------------------\n');
for m = 1:3
    fprintf('%s:\n', segmentationMethods{m});
    fprintf('  Akurasi     : %.2f%%\n', mean(results(m, 1, :)));
    fprintf('  Sensitivitas: %.2f%%\n', mean(results(m, 2, :)));
    fprintf('  Spesifisitas: %.2f%%\n', mean(results(m, 3, :)));
    fprintf('----------------------------------------------------------\n');
end
fprintf('\nMetode Terbaik: %s (%.2f%%)\n', segmentationMethods{bestSegMethod}, mean(results(bestSegMethod, 1, :)));
fprintf('==========================================================\n');
fprintf('\nHASIL:\n');
fprintf('- Tabel Akurasi: %s/akurasi_table.txt\n', tableFolder);
fprintf('- Citra Asli: %s/\n', citraAsliFolder);
fprintf('- Ground Truth: %s/\n', citraAsliGTFolder);
fprintf('- Sobel GT: %s/\n', sobelGTFolder);
fprintf('- Prewitt GT: %s/\n', prewittGTFolder);
fprintf('- LoG GT: %s/\n', logGTFolder);
fprintf('==========================================================\n');

fprintf('\nProses selesai!\n');

%% ========================================================================
%                          FUNGSI-FUNGSI MANUAL
% =========================================================================

%% Fungsi Konversi RGB ke Grayscale Manual
function gray = rgb2gray_manual(rgb)
    R = double(rgb(:,:,1));
    G = double(rgb(:,:,2));
    B = double(rgb(:,:,3));
    gray = uint8(0.299*R + 0.587*G + 0.114*B);
end

%% Fungsi Otsu Thresholding Manual
function [biner, threshold] = otsu_threshold_manual(img)
    img = double(img);
    [m, n] = size(img);
    totalPixels = m * n;
    
    histogram_vals = zeros(1, 256);
    for i = 1:m
        for j = 1:n
            intensitas = round(img(i, j)) + 1;
            intensitas = max(1, min(256, intensitas));
            histogram_vals(intensitas) = histogram_vals(intensitas) + 1;
        end
    end
    
    prob = histogram_vals / totalPixels;
    maxVariance = 0;
    threshold = 0;
    
    for t = 1:255
        w0 = sum(prob(1:t));
        w1 = sum(prob(t+1:256));
        
        if w0 == 0 || w1 == 0
            continue;
        end
        
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
        
        variance = w0 * w1 * (mean0 - mean1)^2;
        
        if variance > maxVariance
            maxVariance = variance;
            threshold = t - 1;
        end
    end
    
    biner = img > threshold;
    biner = logical(biner);
end

%% Fungsi Sobel Edge Detection Manual
function edge_img = sobel_edge_detection(img)
    img = double(img);
    [m, n] = size(img);
    
    Gx = [-1 0 1; -2 0 2; -1 0 1];
    Gy = [-1 -2 -1; 0 0 0; 1 2 1];
    
    imgPad = padarray(img, [1 1], 'replicate');
    
    gradX = zeros(m, n);
    gradY = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = imgPad(i:i+2, j:j+2);
            gradX(i, j) = sum(sum(region .* Gx));
            gradY(i, j) = sum(sum(region .* Gy));
        end
    end
    
    edge_img = sqrt(gradX.^2 + gradY.^2);
    if max(edge_img(:)) > 0
        edge_img = edge_img / max(edge_img(:)) * 255;
    end
end

%% Fungsi Prewitt Edge Detection Manual
function edge_img = prewitt_edge_detection(img)
    img = double(img);
    [m, n] = size(img);
    
    Gx = [-1 0 1; -1 0 1; -1 0 1];
    Gy = [-1 -1 -1; 0 0 0; 1 1 1];
    
    imgPad = padarray(img, [1 1], 'replicate');
    
    gradX = zeros(m, n);
    gradY = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = imgPad(i:i+2, j:j+2);
            gradX(i, j) = sum(sum(region .* Gx));
            gradY(i, j) = sum(sum(region .* Gy));
        end
    end
    
    edge_img = sqrt(gradX.^2 + gradY.^2);
    if max(edge_img(:)) > 0
        edge_img = edge_img / max(edge_img(:)) * 255;
    end
end

%% Fungsi LoG Edge Detection Manual
function edge_img = log_edge_detection(img)
    img = double(img);
    [m, n] = size(img);
    
    sigma = 1.4;
    size_k = 5;
    half = floor(size_k / 2);
    
    gaussian_kernel = zeros(size_k, size_k);
    for i = -half:half
        for j = -half:half
            gaussian_kernel(i+half+1, j+half+1) = exp(-(i^2 + j^2) / (2 * sigma^2));
        end
    end
    gaussian_kernel = gaussian_kernel / sum(gaussian_kernel(:));
    
    laplacian = [0 1 0; 1 -4 1; 0 1 0];
    
    imgPad = padarray(img, [half half], 'replicate');
    smoothed = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = imgPad(i:i+size_k-1, j:j+size_k-1);
            smoothed(i, j) = sum(sum(region .* gaussian_kernel));
        end
    end
    
    smoothedPad = padarray(smoothed, [1 1], 'replicate');
    edge_img = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = smoothedPad(i:i+2, j:j+2);
            edge_img(i, j) = abs(sum(sum(region .* laplacian)));
        end
    end
    
    if max(edge_img(:)) > 0
        edge_img = edge_img / max(edge_img(:)) * 255;
    end
end

%% Fungsi Erosi Manual
function hasil = erosi_manual(img, SE)
    img = double(img);
    [m, n] = size(img);
    [seM, seN] = size(SE);
    
    padM = floor(seM / 2);
    padN = floor(seN / 2);
    
    imgPad = zeros(m + 2*padM, n + 2*padN);
    imgPad(padM+1:padM+m, padN+1:padN+n) = img;
    
    hasil = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = imgPad(i:i+seM-1, j:j+seN-1);
            overlap = region .* SE;
            
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
    
    imgPad = zeros(m + 2*padM, n + 2*padN);
    imgPad(padM+1:padM+m, padN+1:padN+n) = img;
    
    hasil = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = imgPad(i:i+seM-1, j:j+seN-1);
            overlap = region .* SE;
            
            if any(overlap(:) >= 1)
                hasil(i, j) = 1;
            else
                hasil(i, j) = 0;
            end
        end
    end
    
    hasil = logical(hasil);
end

%% Fungsi Resize Manual
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

%% Fungsi Hitung Metrik Segmentasi
function [accuracy, sensitivity, specificity] = hitung_metrik_segmentasi(groundTruth, prediksi)
    gt = double(groundTruth(:));
    pred = double(prediksi(:));
    
    TP = sum((gt == 1) & (pred == 1));
    TN = sum((gt == 0) & (pred == 0));
    FP = sum((gt == 0) & (pred == 1));
    FN = sum((gt == 1) & (pred == 0));
    
    total = TP + TN + FP + FN;
    if total == 0
        accuracy = 0;
    else
        accuracy = ((TP + TN) / total) * 100;
    end
    
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
end
