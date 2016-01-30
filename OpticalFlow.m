function OpticalFlow(FolderNumbers, windowSize, scalingFactor)

if nargin < 3
    scalingFactor = 0.4;
    if nargin < 2
        windowSize = 10;
    end
end

assert(min(FolderNumbers) >= 0)
assert(scalingFactor <= 1)
assert(scalingFactor > 0)
assert(windowSize > 1)

HeaderConfig
global FOLDERNAMEBASE DATAFOLDER

FolderNameAdd = '_opticalflow';

%Iterate through video folders
for FolderNumber = FolderNumbers
    FolderPath = [DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    mkdir([FolderPath, FolderNameAdd]);
    frames = dir([FolderPath, '/*png']);

    %Iterate through frames with two iterators
    parfor f = 1:length(frames)-1
        firstframe = frames(f);
        secframe = frames(f+1);
        frameName = strtok(firstframe.('name'), '.');
        if exist([FolderPath, FolderNameAdd, frameName, '_x.png'], 'file') && exist([FolderPath, FolderNameAdd, frameName, '_y.png'], 'file')
           continue
        end
        disp([FolderPath, ': ', frameName]);

        %Read images, make them gray doubles and resize with given
        %scalingFactor
        im1 = rgb2gray(im2single(imread( ...
            [FolderPath, '/', firstframe.('name')] ...
        )));
        im2 = rgb2gray(im2single(imread( ...
            [FolderPath, '/', secframe.('name')] ...
        )));

        im1 = imresize(im1, scalingFactor, 'bicubic');
        im2 = imresize(im2, scalingFactor, 'bicubic');

        %Calculate optical flow with the lucaskanade script
        [flow_x, flow_y] = LucasKanade(im1, im2, windowSize);

        %Create indexed pictures
        [flow_x,~] = gray2ind(flow_x);
        [flow_y,~] = gray2ind(flow_y);

        %Write results to images
        imwrite(flow_x, jet, [FolderPath, FolderNameAdd, frameName, '_x.png'], 'png');
        imwrite(flow_y, jet, [FolderPath, FolderNameAdd, frameName, '_y.png'], 'png');
    end;
end;
