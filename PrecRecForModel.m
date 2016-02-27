% See the file 'LICENSE' for the full license governing this code.
function PrecRecForModel(bbFileName, FolderName, ModelNames, Models, ModelTypes)

HeaderConfig
global LIBSVM_PATH DATAFOLDER HOGCELLSIZE COUNTOFHOG

addpath(LIBSVM_PATH)

FolderPath = [DATAFOLDER, 'DATA/', FolderName];
bbFilePath = [DATAFOLDER, 'DATA/', bbFileName];

assert(exist(FolderPath, 'dir') == 7)
assert(exist(bbFilePath, 'file') == 2)
assert(size(Models)==size(ModelNames))
assert(size(ModelTypes)==size(ModelNames))

ResultPaths={}
for m=length(Models)
    ResultPaths(m)=[DATAFOLDER, 'RESULTS/PREDICTIONS/', ModelNames(m), '/', FolderName, '_pr.mat'];
end

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

labels = zeros(nBB, 1, 'double');
scores = zeros(nBB, length(Models), 'double');
instances = zeros(nBB, 256 + CountOfHOG^2 * (3*numOrient+4), 'double');

%Load first Image
im = im2single(rgb2gray(rjpg8c(...
    [FolderPath, '/I', sprintf('%05d', BBMat(1, 1)), '.jpg']...
)));
oldFrameID = BBMat(1, 1);

%The size of the images, assuming it will not change
[im_y, im_x] = size(im);

%Iterate over the Bounding Boxes
for b = 1:nBB

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
            warning(['impart subscipts were bad : y=' num2str(y) ' x=' num2str(x) ' with HalfBBWidth=' num2str(HalfBBWidth)])
            continue
        else
            rethrow(ME)
        end
    end

    %Compute the HOG features for that part
    hog = vl_hog(impart, HOGCellSize);

    %Make floats from HOG features a vector and normalize it
    hog = reshape(hog, 1, []);
    hog = hog/norm(hog);

    %Get color histogram and normalize it
    hist = imhist(impart)';
    hist = hist/norm(hist);

    %Concat HOG features with color histogram and normalize the vector
    instances(b, :) = [hog hist];
    labels(b) = BBMat(b, 2);

end

clear BBMat

for m=length(Models)
    switch ModelTypes(m)
        case 1
            instances = sparse(instances);
            scores(m) = predict(labels, instances, Models(m));
        case 0
            scores(m) = Models(m).predict(instances);
    end

    [recall, precision] = vl_pr(labels, scores(m));

    save ResultPaths(m) [labels; scores(m); recall; precision]
end
