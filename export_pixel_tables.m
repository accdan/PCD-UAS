%% ========================================================================
%  EXPORT PIXEL TABLES - Export 9x9 Pixel Values to CSV
% =========================================================================
% Description:
%   Script ini mengekspor nilai pixel 9x9 (pojok kiri atas) dari semua
%   tahap pemrosesan citra ke format CSV untuk analisis lebih lanjut.
%
% Input Folders:
%   - 2_plat-image/          : Citra asli
%   - image-hasil-mse/       : Hasil 5 teknik perbaikan
%   - image-hasil-terbaik/   : Hasil ground truth dan segmentasi
%
% Output:
%   - Pixel-Tables/1_hasil_mse/      : CSV untuk setiap filter MSE
%   - Pixel-Tables/2_hasil_terbaik/  : CSV untuk GT dan segmentasi
% =========================================================================

clc; clear; close all;

fprintf('========================================================================\n');
fprintf('              EXPORT PIXEL VALUES TO CSV\n');
fprintf('              9x9 Pixels (Top-Left Corner)\n');
fprintf('========================================================================\n\n');

%% Konfigurasi Folder
inputFolderOriginal = '2_plat-image';
mseResultFolder = 'image-hasil-mse';
akurasiResultFolder = 'image-hasil-terbaik';
outputBaseFolder = 'Pixel-Tables';

%% Buat Struktur Folder Output
fprintf('Creating folder structure...\n');

% Folder utama
if ~exist(outputBaseFolder, 'dir')
    mkdir(outputBaseFolder);
end

% Folder MSE
mseFolders = {
    fullfile(outputBaseFolder, '1_hasil_mse', '01_citra_asli');
    fullfile(outputBaseFolder, '1_hasil_mse', '02_brightness');
    fullfile(outputBaseFolder, '1_hasil_mse', '03_contrast');
    fullfile(outputBaseFolder, '1_hasil_mse', '04_combination');
    fullfile(outputBaseFolder, '1_hasil_mse', '05_nonlinear');
    fullfile(outputBaseFolder, '1_hasil_mse', '06_improve');
};

% Folder Akurasi
akurasiFolders = {
    fullfile(outputBaseFolder, '2_hasil_terbaik', '01_citra_asli');
    fullfile(outputBaseFolder, '2_hasil_terbaik', '02_ground_truth');
    fullfile(outputBaseFolder, '2_hasil_terbaik', '03_sobel_gt');
    fullfile(outputBaseFolder, '2_hasil_terbaik', '04_prewitt_gt');
    fullfile(outputBaseFolder, '2_hasil_terbaik', '05_log_gt');
};

% Buat semua folder
allFolders = [mseFolders; akurasiFolders];
for i = 1:length(allFolders)
    if ~exist(allFolders{i}, 'dir')
        mkdir(allFolders{i});
    end
end

fprintf('✓ Folder structure created!\n\n');

%% Daftar Gambar
imageFiles = dir(fullfile(inputFolderOriginal, '*.png'));
numImages = length(imageFiles);

fprintf('Found %d images to process\n\n', numImages);

%% Proses Setiap Gambar
for idx = 1:numImages
    imageName = imageFiles(idx).name;
    [~, baseName, ~] = fileparts(imageName);
    
    fprintf('[%d/%d] Processing: %s\n', idx, numImages, imageName);
    
    %% ========== BAGIAN 1: HASIL MSE ==========
    
    % 1. Citra Asli
    imgOriginal = imread(fullfile(inputFolderOriginal, imageName));
    if size(imgOriginal, 3) == 3
        imgOriginal = rgb2gray_manual(imgOriginal);
    end
    exportCSV(imgOriginal, mseFolders{1}, [baseName '_original.csv']);
    
    % 2. Brightness +40
    imgFile = fullfile(mseResultFolder, [baseName '_brightness40.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, mseFolders{2}, [baseName '_brightness.csv']);
    end
    
    % 3. Contrast 15
    imgFile = fullfile(mseResultFolder, [baseName '_contrast15.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, mseFolders{3}, [baseName '_contrast.csv']);
    end
    
    % 4. Combination
    imgFile = fullfile(mseResultFolder, [baseName '_combination.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, mseFolders{4}, [baseName '_combination.csv']);
    end
    
    % 5. Nonlinear
    imgFile = fullfile(mseResultFolder, [baseName '_nonlinear.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, mseFolders{5}, [baseName '_nonlinear.csv']);
    end
    
    % 6. Improve
    imgFile = fullfile(mseResultFolder, [baseName '_improve.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, mseFolders{6}, [baseName '_improve.csv']);
    end
    
    %% ========== BAGIAN 2: HASIL TERBAIK (GROUND TRUTH) ==========
    
    % 1. Citra Asli (dari folder hasil terbaik)
    imgFile = fullfile(akurasiResultFolder, 'citra-asli', imageName);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, akurasiFolders{1}, [baseName '_original.csv']);
    end
    
    % 2. Ground Truth
    imgFile = fullfile(akurasiResultFolder, 'citra-asli-groundtruth', [baseName '_gt.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, akurasiFolders{2}, [baseName '_gt.csv']);
    end
    
    % 3. Sobel GT
    imgFile = fullfile(akurasiResultFolder, 'sobel-groundtruth', [baseName '_sobel_gt.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, akurasiFolders{3}, [baseName '_sobel_gt.csv']);
    end
    
    % 4. Prewitt GT
    imgFile = fullfile(akurasiResultFolder, 'prewitt-groundtruth', [baseName '_prewitt_gt.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, akurasiFolders{4}, [baseName '_prewitt_gt.csv']);
    end
    
    % 5. LoG GT
    imgFile = fullfile(akurasiResultFolder, 'log-groundtruth', [baseName '_log_gt.png']);
    if exist(imgFile, 'file')
        img = imread(imgFile);
        exportCSV(img, akurasiFolders{5}, [baseName '_log_gt.csv']);
    end
    
    fprintf('  ✓ Exported all pixel tables for %s\n\n', imageName);
end

%% Generate Summary Report
fprintf('========================================================================\n');
fprintf('Generating summary report...\n');

summaryFile = fullfile(outputBaseFolder, 'SUMMARY_REPORT.txt');
fid = fopen(summaryFile, 'w');

fprintf(fid, '========================================================================\n');
fprintf(fid, '                    PIXEL TABLES EXPORT SUMMARY\n');
fprintf(fid, '========================================================================\n');
fprintf(fid, 'Date: %s\n', datestr(now, 'dd-mm-yyyy HH:MM:SS'));
fprintf(fid, 'Total Images Processed: %d\n\n', numImages);

fprintf(fid, '------------------------------------------------------------------------\n');
fprintf(fid, 'STRUCTURE:\n');
fprintf(fid, '------------------------------------------------------------------------\n');
fprintf(fid, 'Pixel-Tables/\n');
fprintf(fid, '├── 1_hasil_mse/\n');
fprintf(fid, '│   ├── 01_citra_asli/     (%d files)\n', numImages);
fprintf(fid, '│   ├── 02_brightness/     (%d files)\n', numImages);
fprintf(fid, '│   ├── 03_contrast/       (%d files)\n', numImages);
fprintf(fid, '│   ├── 04_combination/    (%d files)\n', numImages);
fprintf(fid, '│   ├── 05_nonlinear/      (%d files)\n', numImages);
fprintf(fid, '│   └── 06_improve/        (%d files)\n', numImages);
fprintf(fid, '│\n');
fprintf(fid, '└── 2_hasil_terbaik/\n');
fprintf(fid, '    ├── 01_citra_asli/    (%d files)\n', numImages);
fprintf(fid, '    ├── 02_ground_truth/  (%d files)\n', numImages);
fprintf(fid, '    ├── 03_sobel_gt/      (%d files)\n', numImages);
fprintf(fid, '    ├── 04_prewitt_gt/    (%d files)\n', numImages);
fprintf(fid, '    └── 05_log_gt/        (%d files)\n\n', numImages);

fprintf(fid, '------------------------------------------------------------------------\n');
fprintf(fid, 'CSV FORMAT:\n');
fprintf(fid, '------------------------------------------------------------------------\n');
fprintf(fid, '- Each CSV file contains 9x9 pixel values\n');
fprintf(fid, '- Values extracted from top-left corner of image\n');
fprintf(fid, '- Format: 9 rows x 9 columns\n');
fprintf(fid, '- Can be opened with Excel, MATLAB, Python, etc.\n\n');

fprintf(fid, '------------------------------------------------------------------------\n');
fprintf(fid, 'USAGE:\n');
fprintf(fid, '------------------------------------------------------------------------\n');
fprintf(fid, '1. Open CSV file in Excel or text editor\n');
fprintf(fid, '2. Each row represents a row of pixels\n');
fprintf(fid, '3. Each column represents a column of pixels\n');
fprintf(fid, '4. Values range from 0-255 (grayscale) or 0-1 (binary)\n\n');

fprintf(fid, '========================================================================\n');
fprintf(fid, 'Total CSV Files Generated: %d\n', numImages * 11);
fprintf(fid, '========================================================================\n');

fclose(fid);

fprintf('✓ Summary report saved to: %s\n', summaryFile);
fprintf('========================================================================\n');
fprintf('EXPORT COMPLETED!\n');
fprintf('========================================================================\n');
fprintf('Total CSV files generated: %d\n', numImages * 11);
fprintf('Output folder: %s\n', outputBaseFolder);
fprintf('========================================================================\n');

%% ========================================================================
%                          FUNGSI HELPER
% =========================================================================

%% Fungsi Export 9x9 Pixels ke CSV
function exportCSV(img, folderPath, fileName)
    % Konversi ke double
    img = double(img);
    
    % Ambil 9x9 pixel dari pojok kiri atas
    [m, n] = size(img);
    rows = min(9, m);
    cols = min(9, n);
    pixels_9x9 = img(1:rows, 1:cols);
    
    % Jika kurang dari 9x9, pad dengan 0
    if rows < 9 || cols < 9
        temp = zeros(9, 9);
        temp(1:rows, 1:cols) = pixels_9x9;
        pixels_9x9 = temp;
    end
    
    % Simpan ke CSV
    fullPath = fullfile(folderPath, fileName);
    csvwrite(fullPath, pixels_9x9);
end

%% Fungsi Konversi RGB ke Grayscale Manual
function gray = rgb2gray_manual(rgb)
    R = double(rgb(:,:,1));
    G = double(rgb(:,:,2));
    B = double(rgb(:,:,3));
    gray = uint8(0.299*R + 0.587*G + 0.114*B);
end
