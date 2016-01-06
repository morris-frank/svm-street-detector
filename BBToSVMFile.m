function BBToSVMFile(bbFileName, FolderName, sB, MwBB, wHOGCell, numOrient) 
% Converts the BoundingBoxes on a *.bb file to SVM train data
% BBToSVMFile(bbFileName, FolderName)

if nargin < 6
    numOrient = 9;
    if nargin < 5
        wHOGCell = 9;
        if nargin < 4
            MwBB = 9;
            if nargin < 3
                sB = 1;
            end
        end
    end
end

assert(exist(FolderName, 'dir') == 7)
assert(exist(bbFileName, 'file') == 2)

HeaderConfig
global LIBSVM_PATH
addpath(LIBSVM_PATH)

FolderNameAdd = '_train/';
mkdir(strcat(FolderName, FolderNameAdd));

%Load and parse all bounding boxes from the *.bb File
BBFile = fopen(bbFileName);
BBData = textscan(BBFile, 'seq%u16\\I%5u16.jpg    %u16 %u16 %u16 %u16    %1u16');
%[1:FrameID, 2:CatID, 3:left, 4:top, 5:right, 6:bottom]
BBMat  = cell2mat({BBData{2}, BBData{7}, BBData{3}, BBData{4}, BBData{5}, BBData{6}});
BBMat  = unique(sortrows(BBMat), 'rows');
nBB = size(BBMat, 1);
fclose(BBFile);
clear BBData BBFile;

sI = 0;
MsI = 1000;

assert(sB < nBB)

labelVector = double(zeros(MsI, 1));
featureMatrix = double(zeros(MsI, MwBB^2 * (3*numOrient+4)));

oldFrameID = -1;

%Iterate over the Bounding Boxes
for b = sB:nBB
    sI = sI + 1;

    %Load HOG features for this Bounding Box
    if BBMat(b,1) ~= oldFrameID
        load(strcat(FolderName, '_hog/I', sprintf('%05d', BBMat(b, 1)), '_data.mat'));
        HOG = data; clear data
        [yHOG, xHOG, ~] = size(HOG);
        oldFrameID = BBMat(b,1);
    end

    %Most left HOG cell overlapping BBox:
    l = idivide(BBMat(b, 3), wHOGCell, 'floor') + 1;
    %Highest HOG cell overlapping BBox:
    o = idivide(BBMat(b, 4), wHOGCell, 'floor') + 1;
    %Most right HOG cell overlapping BBox:
    r = idivide(BBMat(b, 5), wHOGCell, 'floor') + 2;
    r = min(r, xHOG);
    %Lowest HOG cell overlapping BBox:
    u = idivide(BBMat(b, 6), wHOGCell, 'floor') + 2;
    u = min(u, yHOG);

    %If the Bounding Box is not correctly scaled use the scaleFeatureMat
    %function to scale it
    if u-o+1 ~= MwBB || r-l+1 ~= MwBB
        scaledFeatures = scaleFeatureMat(HOG(o:u, l:r, :), MwBB);
    else
        scaledFeatures = HOG(o:u, l:r, :);
    end
    featureMatrix(sI, :, :) = reshape(scaledFeatures, [], 1).';
    labelVector(sI) = BBMat(b, 2);

    %Time to save some stuff eh
    if sI == MsI
        libsvmwrite(strcat(FolderName, FolderNameAdd, num2str(b-MsI), '-', num2str(b), '.train'), labelVector, sparse(featureMatrix));
        sI = 0;
        disp(strcat(num2str(BBMat(b,1)), ': ', num2str(b/nBB*100), '%'));
    end
end
    libsvmwrite('test.txt', labelVector, sparse(featureMatrix));
end
