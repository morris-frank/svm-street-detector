function ProcessBBFile(bbFileName, FolderName, sB, MwBB, wHOGCell, numOrient)
% Converts the BoundingBoxes on a *.bb file to SVM train data
% ProcessBBFile(bbFileName, FolderName)

HeaderConfig
global LIBSVM_PATH DATAFOLDER HOGCELLSIZE BBSIZE

if nargin < 6
    numOrient = 9;
    if nargin < 5
        wHOGCell = HOGCELLSIZE;
        if nargin < 4
            MwBB = BBSIZE;
            if nargin < 3
                sB = 1;
            end
        end
    end
end

addpath(LIBSVM_PATH)
FolderPath = strcat(DATAFOLDER, FolderName);
bbFilePath = strcat(DATAFOLDER, bbFileName);

assert(exist(FolderPath, 'dir') == 7)
assert(exist(bbFilePath, 'file') == 2)

FolderPathAdd = '_train/';
mkdir(strcat(FolderPath, FolderPathAdd));

%Load and parse all bounding boxes from the *.bb File
BBFile = fopen(bbFilePath);
BBData = textscan(BBFile, 'seq%u16\\I%5u16.jpg    %u16 %u16 %u16 %u16    %1u16');
%[1:FrameID, 2:CatID, 3:left, 4:top, 5:right, 6:bottom]
BBMat  = cell2mat({BBData{2}, BBData{7}, BBData{3}, BBData{4}, BBData{5}, BBData{6}});
BBMat  = unique(sortrows(BBMat), 'rows');
nBB = size(BBMat, 1);
fclose(BBFile);
clear BBData BBFile;

assert(sB < nBB)

labelVector = double(zeros(nBB, 1));
featureMatrix = double(zeros(nBB, 256 + MwBB^2 * (3*numOrient+4)));

BBWidth = MwBB * wHOGCell;
hBBWidth = floor(BBWidth/2);

im = im2single(rgb2gray(imread(strcat(...
        FolderPath, '/I', sprintf('%05d', BBMat(1, 1)), '.jpg'...
        ))));
oldFrameID = BBMat(1, 1);
[im_y, im_x] = size(im);

%Iterate over the Bounding Boxes
for b = sB:nBB
    if BBMat(b, 1) ~= oldFrameID
        im = im2single(rgb2gray(imread(strcat(...
                FolderPath, '/I', sprintf('%05d', BBMat(b, 1)), '.jpg'...
                ))));
        oldFrameID = BBMat(b, 1);
    end

    middle = [min(im_y-hBBWidth, max(hBBWidth, floor((BBMat(b,4)+BBMat(b,6))/2))),...
        min(im_x-hBBWidth, max(hBBWidth, floor((BBMat(b,3)+BBMat(b,5))/2)))];
    y = [middle(1)-hBBWidth : middle(1)+hBBWidth];
    x = [middle(2)-hBBWidth : middle(2)+hBBWidth];
    impart = im(y, x);

    hog = vl_hog(impart, wHOGCell);
    hog = reshape(hog, 1, []);
    featureMatrix(b, :) = [hog, imhist(impart)'];
    labelVector(b) = BBMat(b, 2);

end
    libsvmwrite(strcat(bbFileName, '.train'), labelVector, sparse(featureMatrix));
end
