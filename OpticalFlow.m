function OpticalFlow(FolderNumbers, windowSize, scalingFactor)

if nargin < 3
    scalingFactor = 0.4;
    if nargin < 2
        windowSize = 10;
    end
end

assert(min(FolderNumbers) >= 0)
assert(max(FolderNumbers) <= 10)
assert(scalingFactor <= 1)
assert(scalingFactor > 0)
assert(windowSize > 1)

HeaderConfig
global FOLDERNAMEBASE

FolderNameAdd = '_opticalflow';

%Iterate through video folders
for FolderNumber = FolderNumbers
    FolderName = strcat(FOLDERNAMEBASE, sprintf('%04d', FolderNumber));

    mkdir(strcat(FolderName, FolderNameAdd));
    frames = dir(strcat(FolderName, '/*png'));

    %Iterate through frames with two iterators
    parfor f = 1:length(frames)-1
        firstframe = frames(f);
        secframe = frames(f+1);
        frameName = strtok(firstframe.('name'), '.');
        if exist(strcat(FolderName, FolderNameAdd, frameName, '_x.png'), 'file') && exist(strcat(FolderName, FolderNameAdd, frameName, '_y.png'), 'file')
           continue
        end
        disp(strcat(FolderName, ': ', frameName));

        %Read images, make them gray doubles and resize with given
        %scalingFactor
        im1 = im2double(imread(strcat(FolderName, '/', firstframe.('name'))));
        im2 = im2double(imread(strcat(FolderName, '/', secframe.('name'))));

        im1 = rgb2gray(imresize(im1, scalingFactor, 'bicubic'));
        im2 = rgb2gray(imresize(im2, scalingFactor, 'bicubic'));

        %Calculate optical flow with the lucaskanade script
        [flow_x, flow_y] = LucasKanade(im1, im2, windowSize);

        %Create indexed pictures
        [flow_x,~] = gray2ind(flow_x);
        [flow_y,~] = gray2ind(flow_y);

        %Write results to images
        imwrite(flow_x, jet, strcat(FolderName, FolderNameAdd, frameName, '_x.png'), 'png');
        imwrite(flow_y, jet, strcat(FolderName, FolderNameAdd, frameName, '_y.png'), 'png');
    end;
end;
