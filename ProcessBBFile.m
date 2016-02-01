% See the file 'LICENSE' for the full license governing this code.
function ProcessBBFile(bbFileName, FolderName, permut)
% Converts the BoundingBoxes on a *.bb file to SVM train data
% ProcessBBFile(bbFileName, FolderName)

HeaderConfig
global LIBSVM_PATH DATAFOLDER HOGCELLSIZE COUNTOFHOG

if nargin < 3
    permut = 0;
end

addpath(LIBSVM_PATH)

FolderPath = [DATAFOLDER, FolderName];
bbFilePath = [DATAFOLDER, bbFileName];

assert(exist(FolderPath, 'dir') == 7)
assert(exist(bbFilePath, 'file') == 2)

%if exist(rjpg8c) ~= 3
%    error('You need the rjpg8c MEX-File on your searchpath.')
%end

%Number of Orientations in a HOG Cell
numOrient = 9;
%Width of a HOG Cell
HOGCellSize = HOGCELLSIZE;
%Width of a normalized Bounding Box in Widthes of a HOG cell
CountOfHOG = COUNTOFHOG;
%Width of a normalized Bounding Box in real pixels
BBWidth = CountOfHOG * HOGCellSize;
HalfBBWidth = floor(BBWidth/2);

%Load and parse all bounding boxes from the *.bb File
BBFile = fopen(bbFilePath);
BBData = textscan(BBFile, 'seq%u16\\I%5u16.jpg    %u16 %u16 %u16 %u16    %1u16');
%[1:FrameID, 2:CatID, 3:left, 4:top, 5:right, 6:bottom]
BBMat  = cell2mat({BBData{2}, BBData{7}, BBData{3}, BBData{4}, BBData{5}, BBData{6}});
BBMat  = unique(sortrows(BBMat), 'rows');
fclose(BBFile);
clear BBData BBFile;

nBB = size(BBMat, 1);

%Assume that we start with the first picture
startBB = 1;

labelVector = zeros(nBB, 1, 'double');
instanceVector = zeros(nBB, 256 + CountOfHOG^2 * (3*numOrient+4), 'double');

%Load first Image
im = im2single(rgb2gray(rjpg8c(...
    [FolderPath, '/I', sprintf('%05d', BBMat(1, 1)), '.jpg']...
)));
oldFrameID = BBMat(1, 1);

%The size of the images, assuming it will not change
[im_y, im_x] = size(im);

%bar = waitbar(0, ['Processing ' bbFileName '...']);

%Iterate over the Bounding Boxes
for b = startBB:nBB
    %waitbar((b-startBB)/nBB)
    %If the Bounding Box is on a different picture, load it
    if BBMat(b, 1) ~= oldFrameID
        im = im2single(rgb2gray(rjpg8c(...
            [FolderPath, '/I', sprintf('%05d', BBMat(b, 1)), '.jpg']...
        )));
        oldFrameID = BBMat(b, 1);
    end

    %Get the y-part of the middle point of this Bounding Box
    y = floor((BBMat(b, 4) + BBMat(b, 6))/2);
    y = max(HalfBBWidth, y);
    y = min(im_y - HalfBBWidth, y);

    %Get the y-part of the middle point of this Bounding Box
    x = floor((BBMat(b, 3) + BBMat(b, 5))/2);
    x = max(HalfBBWidth, x);
    x = min(im_x - HalfBBWidth, x);

    %Get the pixel values of that Bounding Box
    Y = y - HalfBBWidth : y + HalfBBWidth;
    X = x - HalfBBWidth : x + HalfBBWidth;

    %Get the part of the image for the Bounding Box
    try
        impart = im(Y, X);
    catch ME
        if (strcmp(ME.identifier,'MATLAB:badsubscript'))
            warning(['impart subscipts were bad : y=' num2str(y) ' x=' num2str(x)] ' with HalfBBWidth=' num2str(HalfBBWidth))
            continue
        else
            rethrow(ME)
        end
    end

    %Compute the HOG features for that part
    hog = vl_hog(impart, HOGCellSize);

    %If flipping was demanded, permute the HOG features
    if permut ~= 0
        perm = vl_hog('permutation');
        hog = hog(:, end:-1:1, perm);
    end

    %Make floats from HOG features a vector and normalize it
    hog = reshape(hog, 1, []);
    hog = hog/norm(hog);

    %Get color histogram and normalize it
    hist = imhist(impart)';
    hist = hist/norm(hist);

    %Concat HOG features with color histogram and normalize the vector
    instanceVector(b, :) = [hog hist];
    labelVector(b) = BBMat(b, 2);

end

%close(bar)

if permut == 0
    libsvmwrite([bbFileName, '.train'], labelVector, sparse(instanceVector));
else
    libsvmwrite([bbFileName, '-flipped.train'], labelVector, sparse(instanceVector));
end
