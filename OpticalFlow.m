% See the file 'LICENSE' for the full license governing this code.
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

%Iterate through video folders
for FolderNumber = FolderNumbers
    SeqFolderName = [FOLDERNAMEBASE, sprintf('%04d', FolderNumber), '/'];
    ComputationDir = [DATAFOLDER, 'RESULTS/', SeqFolderName];

    mkdir([ComputationDir, 'opticalflow']);
    mkdir([ComputationDir, 'opticalflow/x']);
    mkdir([ComputationDir, 'opticalflow/y']);

    %Iterate over frames in video
    parfor f = 1:length(dir([DATAFOLDER, 'DATA/', SeqFolderName, '/*jpg'])')-1
        FrameFileName = ['I', sprintf('%05d', f)];
        NextFrameFileName = ['I', sprintf('%05d', f)];

        %The frame from the video
        FramePath = [DATAFOLDER, 'DATA/', SeqFolderName, FrameFileName, '.jpg'];
        %The next frame from the video
        NormalNextFramePath = [DATAFOLDER, 'DATA/', SeqFolderName, NextFrameFileName, '.jpg'];

        %Read images, make them gray doubles and resize with given
        %scalingFactor
        im1 = rgb2gray(im2single(imread(FramePath)));
        im2 = rgb2gray(im2single(imread(NormalNextFramePath)));

        im1 = imresize(im1, scalingFactor, 'bicubic');
        im2 = imresize(im2, scalingFactor, 'bicubic');

        %Calculate optical flow with the lucaskanade script
        [flow_x, flow_y] = LucasKanade(im1, im2, windowSize);

        %Create indexed pictures
        [flow_x,~] = gray2ind(flow_x);
        [flow_y,~] = gray2ind(flow_y);

        %Write results to images
        imwrite(flow_x, jet, [ComputationDir, 'opticalflow/x/', FrameFileName, '.png'], 'png');
        imwrite(flow_y, jet, [ComputationDir, 'opticalflow/y/', FrameFileName, '.png'], 'png');
    end;
end;
