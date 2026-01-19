%% ========================================================================
%  HITUNG MSE - PERBANDINGAN METODE PERBAIKAN CITRA
%  Menggunakan 3 Metode Edge Detection: Sobel, Prewitt, LoG
% =========================================================================
% Author: PCD-UAS Project
% Date: 2026-01-19
% Description: 
%   - Memproses 15 gambar dengan 5 teknik perbaikan
%   - Menghitung MSE untuk 3 metode edge detection
%   - Menyimpan hasil ke folder image-hasil-mse dan Table-Mse
% =========================================================================

clc; clear; close all;

%% Pilihan Folder Input
fprintf('==========================================================\n');
fprintf('        PILIH FOLDER INPUT GAMBAR\n');
fprintf('==========================================================\n');
fprintf('1. 1_apple-image (Gambar Apel)\n');
fprintf('2. 2_plat-image (Gambar Plat Nomor)\n');
fprintf('==========================================================\n');

% Input pilihan dari user
pilihan = input('Pilih folder (1/2): ');

% Tentukan folder berdasarkan pilihan
if pilihan == 1
    inputFolder = '1_apple-image';
    fprintf('\n✓ Folder dipilih: 1_apple-image\n\n');
elseif pilihan == 2
    inputFolder = '2_plat-image';
    fprintf('\n✓ Folder dipilih: 2_plat-image\n\n');
else
    error('Pilihan tidak valid! Harus 1 atau 2.');
end

%% Konfigurasi Folder Output
outputFolder = 'image-hasil-mse';
tableFolder = 'Table-Mse';

% Buat folder jika belum ada
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
if ~exist(tableFolder, 'dir')
    mkdir(tableFolder);
end

%% Daftar Gambar
imageFiles = dir(fullfile(inputFolder, '*.png'));
numImages = length(imageFiles);

fprintf('==========================================================\n');
fprintf('        PERHITUNGAN MSE - PERBAIKAN CITRA\n');
fprintf('==========================================================\n');
fprintf('Jumlah gambar ditemukan: %d\n\n', numImages);

%% Inisialisasi Tabel Penyimpanan MSE
% Struktur: [Sobel, Prewitt, LoG] x [5 teknik perbaikan] x [15 gambar]
methodNames = {'Sobel', 'Prewitt', 'LoG'};
techniqueNames = {'Brightness_40', 'Contrast_15', 'Combination', 'Nonlinear_Mapping', 'Improve_Brightness'};

% Matriks MSE: 3 metode x 5 teknik x 15 gambar
MSE_Results = zeros(3, 5, numImages);
imageNamesList = cell(numImages, 1);

%% Proses Setiap Gambar
for idx = 1:numImages
    imageName = imageFiles(idx).name;
    imageNamesList{idx} = imageName;
    
    fprintf('Processing [%d/%d]: %s\n', idx, numImages, imageName);
    
    % Baca gambar
    img = imread(fullfile(inputFolder, imageName));
    
    % Konversi ke grayscale jika perlu
    if size(img, 3) == 3
        img = rgb2gray_manual(img);
    end
    imgDouble = double(img);
    
    %% Terapkan 5 Teknik Perbaikan
    % 1. Brightness +40
    hasil_brightness = brightness_adjustment(imgDouble, 40);
    
    % 2. Contrast x1.5 (faktor 15 sebagai persentase peningkatan)
    hasil_contrast = contrast_adjustment(imgDouble, 15);
    
    % 3. Combination Brightness + Contrast
    hasil_combination = contrast_adjustment(brightness_adjustment(imgDouble, 40), 15);
    
    % 4. Nonlinear Mapping (Power Law / Gamma = 0.7)
    hasil_nonlinear = power_law_transform(imgDouble, 0.7);
    
    % 5. Improve Brightness (Histogram Equalization)
    hasil_improve = histogram_equalization_manual(uint8(imgDouble));
    
    % Kumpulkan hasil perbaikan
    hasilPerbaikan = {hasil_brightness, hasil_contrast, hasil_combination, ...
                      hasil_nonlinear, double(hasil_improve)};
    
    %% Terapkan 3 Metode Edge Detection dan Hitung MSE
    for m = 1:3  % 3 metode
        % Edge detection pada citra asli (sebagai referensi)
        switch m
            case 1  % Sobel
                edgeRef = sobel_edge_detection(imgDouble);
            case 2  % Prewitt
                edgeRef = prewitt_edge_detection(imgDouble);
            case 3  % LoG
                edgeRef = log_edge_detection(imgDouble);
        end
        
        for t = 1:5  % 5 teknik perbaikan
            % Edge detection pada hasil perbaikan
            switch m
                case 1
                    edgeResult = sobel_edge_detection(hasilPerbaikan{t});
                case 2
                    edgeResult = prewitt_edge_detection(hasilPerbaikan{t});
                case 3
                    edgeResult = log_edge_detection(hasilPerbaikan{t});
            end
            
            % Hitung MSE
            MSE_Results(m, t, idx) = compute_mse(edgeRef, edgeResult);
        end
    end
    
    %% Simpan Hasil Perbaikan ke folder image-hasil-mse
    [~, baseName, ~] = fileparts(imageName);
    
    % Simpan semua hasil perbaikan
    imwrite(uint8(hasil_brightness), fullfile(outputFolder, [baseName '_brightness40.png']));
    imwrite(uint8(hasil_contrast), fullfile(outputFolder, [baseName '_contrast15.png']));
    imwrite(uint8(hasil_combination), fullfile(outputFolder, [baseName '_combination.png']));
    imwrite(uint8(hasil_nonlinear), fullfile(outputFolder, [baseName '_nonlinear.png']));
    imwrite(uint8(hasil_improve), fullfile(outputFolder, [baseName '_improve.png']));
end

fprintf('\n==========================================================\n');
fprintf('Proses perbaikan citra selesai!\n');
fprintf('==========================================================\n\n');

%% Generate Tabel MSE dan Simpan ke File TXT
fprintf('Generating MSE Table...\n');

% Buka file untuk penulisan
fid = fopen(fullfile(tableFolder, 'mse_table.txt'), 'w');

% Header
fprintf(fid, '========================================================================================\n');
fprintf(fid, '                     TABEL MSE - PERBANDINGAN METODE PERBAIKAN CITRA\n');
fprintf(fid, '                        Menggunakan 3 Metode Edge Detection\n');
fprintf(fid, '========================================================================================\n\n');
fprintf(fid, 'Tanggal: %s\n', datestr(now, 'dd-mm-yyyy HH:MM:SS'));
fprintf(fid, 'Jumlah Gambar: %d\n\n', numImages);

% Loop untuk setiap metode edge detection
for m = 1:3
    fprintf(fid, '========================================================================================\n');
    fprintf(fid, 'METODE %d: %s\n', m, methodNames{m});
    fprintf(fid, '========================================================================================\n');
    fprintf(fid, '| No | %-28s | Bright40   | Contrast15 | Combi      | Nonlinear  | Improve    |\n', 'Image Name');
    fprintf(fid, '----------------------------------------------------------------------------------------\n');
    
    for idx = 1:numImages
        fprintf(fid, '| %2d | %-28s | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f |\n', ...
            idx, imageNamesList{idx}, ...
            MSE_Results(m, 1, idx), ...
            MSE_Results(m, 2, idx), ...
            MSE_Results(m, 3, idx), ...
            MSE_Results(m, 4, idx), ...
            MSE_Results(m, 5, idx));
    end
    
    % Hitung rata-rata
    fprintf(fid, '----------------------------------------------------------------------------------------\n');
    fprintf(fid, '|    | %-28s | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f |\n', ...
        'RATA-RATA', ...
        mean(MSE_Results(m, 1, :)), ...
        mean(MSE_Results(m, 2, :)), ...
        mean(MSE_Results(m, 3, :)), ...
        mean(MSE_Results(m, 4, :)), ...
        mean(MSE_Results(m, 5, :)));
    fprintf(fid, '========================================================================================\n\n');
end

%% Tentukan Metode dan Teknik Terbaik (MSE Terendah)
% Hitung rata-rata MSE untuk setiap kombinasi metode dan teknik
avgMSE = zeros(3, 5);
for m = 1:3
    for t = 1:5
        avgMSE(m, t) = mean(MSE_Results(m, t, :));
    end
end

% Cari minimum
[minMSE_perMethod, bestTechIdx] = min(avgMSE, [], 2);
[globalMinMSE, bestMethodIdx] = min(minMSE_perMethod);
bestTechniqueIdx = bestTechIdx(bestMethodIdx);

fprintf(fid, '========================================================================================\n');
fprintf(fid, '                              KESIMPULAN\n');
fprintf(fid, '========================================================================================\n');
fprintf(fid, 'Metode Edge Detection Terbaik : %s\n', methodNames{bestMethodIdx});
fprintf(fid, 'Teknik Perbaikan Terbaik      : %s\n', techniqueNames{bestTechniqueIdx});
fprintf(fid, 'MSE Rata-rata Terendah        : %.4f\n', globalMinMSE);
fprintf(fid, '========================================================================================\n');
fprintf(fid, '\nRINGKASAN MSE RATA-RATA PER METODE:\n');
fprintf(fid, '----------------------------------------------------------------------------------------\n');
fprintf(fid, '| Metode  | Bright40   | Contrast15 | Combi      | Nonlinear  | Improve    | Terbaik    |\n');
fprintf(fid, '----------------------------------------------------------------------------------------\n');
for m = 1:3
    [minVal, minIdx] = min(avgMSE(m, :));
    fprintf(fid, '| %-7s | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f | %-10s |\n', ...
        methodNames{m}, avgMSE(m, 1), avgMSE(m, 2), avgMSE(m, 3), avgMSE(m, 4), avgMSE(m, 5), techniqueNames{minIdx});
end
fprintf(fid, '----------------------------------------------------------------------------------------\n');
fprintf(fid, '\n*** METODE DAN TEKNIK TERBAIK UNTUK DIGUNAKAN PADA TAHAP AKURASI ***\n');
fprintf(fid, '    Gunakan: %s + %s\n', methodNames{bestMethodIdx}, techniqueNames{bestTechniqueIdx});
fprintf(fid, '========================================================================================\n');

%% Tentukan Gambar Referensi Terbaik (MSE Terendah)
% Cari gambar dengan MSE terendah pada kombinasi metode dan teknik terbaik
mseValues = MSE_Results(bestMethodIdx, bestTechniqueIdx, :);
mseValues = mseValues(:);  % Convert to column vector

[minMSE_image, bestImageIdx] = min(mseValues);
bestImageName = imageNamesList{bestImageIdx};

% Tambahkan informasi ke file txt
fprintf(fid, '\n========================================================================================\n');
fprintf(fid, '                         GAMBAR REFERENSI TERBAIK\n');
fprintf(fid, '========================================================================================\n');
fprintf(fid, 'Gambar dengan MSE Terendah:\n');
fprintf(fid, '  - Nama Gambar  : %s\n', bestImageName);
fprintf(fid, '  - Index        : %d\n', bestImageIdx);
fprintf(fid, '  - MSE Value    : %.4f\n', minMSE_image);
fprintf(fid, '  - Metode       : %s\n', methodNames{bestMethodIdx});
fprintf(fid, '  - Teknik       : %s\n', techniqueNames{bestTechniqueIdx});
fprintf(fid, '\n*** GAMBAR INI AKAN DIGUNAKAN SEBAGAI GROUND TRUTH REFERENSI ***\n');
fprintf(fid, '========================================================================================\n');

fclose(fid);

%% Simpan informasi metode terbaik dan gambar referensi ke file untuk digunakan oleh hitung_akurasi.m
save(fullfile(tableFolder, 'best_method_info.mat'), ...
     'bestMethodIdx', 'bestTechniqueIdx', 'methodNames', 'techniqueNames', ...
     'bestImageIdx', 'bestImageName');

fprintf('\n==========================================================\n');
fprintf('HASIL:\n');
fprintf('- Tabel MSE disimpan di: %s/mse_table.txt\n', tableFolder);
fprintf('- Gambar hasil disimpan di: %s/\n', outputFolder);
fprintf('- Metode terbaik: %s + %s (MSE: %.4f)\n', ...
    methodNames{bestMethodIdx}, techniqueNames{bestTechniqueIdx}, globalMinMSE);
fprintf('==========================================================\n');

%% Tampilkan ringkasan di command window
fprintf('\n=== RINGKASAN MSE ===\n');
for m = 1:3
    fprintf('\n%s:\n', methodNames{m});
    fprintf('  Brightness 40     : %.4f\n', mean(MSE_Results(m, 1, :)));
    fprintf('  Contrast 15       : %.4f\n', mean(MSE_Results(m, 2, :)));
    fprintf('  Combination       : %.4f\n', mean(MSE_Results(m, 3, :)));
    fprintf('  Nonlinear Mapping : %.4f\n', mean(MSE_Results(m, 4, :)));
    fprintf('  Improve Brightness: %.4f\n', mean(MSE_Results(m, 5, :)));
end

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

%% Fungsi Brightness Adjustment
function hasil = brightness_adjustment(img, value)
    % Menambahkan nilai brightness ke citra
    hasil = img + value;
    hasil = max(0, min(255, hasil));  % Clip ke rentang [0, 255]
end

%% Fungsi Contrast Adjustment
function hasil = contrast_adjustment(img, factor)
    % Meningkatkan kontras dengan faktor tertentu
    % factor > 1 = meningkatkan kontras
    contrastFactor = 1 + (factor / 100);  % Konversi persentase ke faktor
    meanVal = mean(img(:));
    hasil = (img - meanVal) * contrastFactor + meanVal;
    hasil = max(0, min(255, hasil));
end

%% Fungsi Power Law Transform (Gamma Correction)
function hasil = power_law_transform(img, gamma)
    % Normalisasi ke [0, 1]
    imgNorm = img / 255;
    % Terapkan power law
    hasilNorm = imgNorm .^ gamma;
    % Kembalikan ke [0, 255]
    hasil = hasilNorm * 255;
    hasil = max(0, min(255, hasil));
end

%% Fungsi Histogram Equalization Manual
function hasil = histogram_equalization_manual(img)
    img = double(img);
    [m, n] = size(img);
    totalPixels = m * n;
    
    % Hitung histogram
    histogram_vals = zeros(1, 256);
    for i = 1:m
        for j = 1:n
            intensitas = round(img(i, j)) + 1;
            intensitas = max(1, min(256, intensitas));
            histogram_vals(intensitas) = histogram_vals(intensitas) + 1;
        end
    end
    
    % Hitung CDF
    cdf = zeros(1, 256);
    cdf(1) = histogram_vals(1);
    for i = 2:256
        cdf(i) = cdf(i-1) + histogram_vals(i);
    end
    
    % Normalisasi CDF
    cdf_min = min(cdf(cdf > 0));
    lut = zeros(1, 256);
    for i = 1:256
        lut(i) = round(((cdf(i) - cdf_min) / (totalPixels - cdf_min)) * 255);
    end
    
    % Terapkan LUT
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

%% Fungsi Sobel Edge Detection Manual
function edge_img = sobel_edge_detection(img)
    img = double(img);
    [m, n] = size(img);
    
    % Kernel Sobel
    Gx = [-1 0 1; -2 0 2; -1 0 1];
    Gy = [-1 -2 -1; 0 0 0; 1 2 1];
    
    % Padding
    imgPad = padarray(img, [1 1], 'replicate');
    
    % Konvolusi
    gradX = zeros(m, n);
    gradY = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = imgPad(i:i+2, j:j+2);
            gradX(i, j) = sum(sum(region .* Gx));
            gradY(i, j) = sum(sum(region .* Gy));
        end
    end
    
    % Magnitude
    edge_img = sqrt(gradX.^2 + gradY.^2);
    edge_img = edge_img / max(edge_img(:)) * 255;  % Normalisasi ke [0, 255]
end

%% Fungsi Prewitt Edge Detection Manual
function edge_img = prewitt_edge_detection(img)
    img = double(img);
    [m, n] = size(img);
    
    % Kernel Prewitt
    Gx = [-1 0 1; -1 0 1; -1 0 1];
    Gy = [-1 -1 -1; 0 0 0; 1 1 1];
    
    % Padding
    imgPad = padarray(img, [1 1], 'replicate');
    
    % Konvolusi
    gradX = zeros(m, n);
    gradY = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = imgPad(i:i+2, j:j+2);
            gradX(i, j) = sum(sum(region .* Gx));
            gradY(i, j) = sum(sum(region .* Gy));
        end
    end
    
    % Magnitude
    edge_img = sqrt(gradX.^2 + gradY.^2);
    edge_img = edge_img / max(edge_img(:)) * 255;
end

%% Fungsi LoG (Laplacian of Gaussian) Edge Detection Manual
function edge_img = log_edge_detection(img)
    img = double(img);
    [m, n] = size(img);
    
    % Gaussian smoothing kernel (5x5, sigma = 1.4)
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
    
    % Laplacian kernel
    laplacian = [0 1 0; 1 -4 1; 0 1 0];
    
    % Apply Gaussian smoothing first
    imgPad = padarray(img, [half half], 'replicate');
    smoothed = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = imgPad(i:i+size_k-1, j:j+size_k-1);
            smoothed(i, j) = sum(sum(region .* gaussian_kernel));
        end
    end
    
    % Apply Laplacian
    smoothedPad = padarray(smoothed, [1 1], 'replicate');
    edge_img = zeros(m, n);
    
    for i = 1:m
        for j = 1:n
            region = smoothedPad(i:i+2, j:j+2);
            edge_img(i, j) = abs(sum(sum(region .* laplacian)));
        end
    end
    
    % Normalisasi
    if max(edge_img(:)) > 0
        edge_img = edge_img / max(edge_img(:)) * 255;
    end
end

%% Fungsi Hitung MSE Manual
function mse = compute_mse(citra1, citra2)
    citra1 = double(citra1);
    citra2 = double(citra2);
    
    [m1, n1] = size(citra1);
    [m2, n2] = size(citra2);
    
    % Resize jika ukuran berbeda
    if m1 ~= m2 || n1 ~= n2
        citra2 = imresize_manual(citra2, [m1, n1]);
    end
    
    % Hitung MSE
    diff = citra1 - citra2;
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
