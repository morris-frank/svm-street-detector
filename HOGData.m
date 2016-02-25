% See the file 'LICENSE' for the full license governing this code.
function HOGData(FolderNumbers, wHOGCell)

if nargin < 2
    wHOGCell = 9;
end

assert(min(FolderNumbers) >= 0)
assert(wHOGCell > 0)

HeaderConfig
global FOLDERNAMEBASE DATAFOLDER

%Iterate through video folders
for FolderNumber = FolderNumbers
    SeqFolderName = [FOLDERNAMEBASE, sprintf('%04d', FolderNumber), '/'];
    ComputationDir = [DATAFOLDER, 'RESULTS/', SeqFolderName];

    mkdir([ComputationDir, 'hog']);
    mkdir([ComputationDir, 'hog/data']);
    mkdir([ComputationDir, 'hog/render']);

    %Iterate over frames in video
    parfor f = 1:length(dir([DATAFOLDER, 'DATA/', SeqFolderName, '/*jpg'])')
        FrameFileName = ['I', sprintf('%05d', f)];

        %The frame from the video
        FramePath = [DATAFOLDER, 'DATA/', SeqFolderName, FrameFileName, '.jpg'];

        %Read image, make them gray doubles
        %and put into gpuarray
        Im = im2single(rgb2gray(imread(FramePath)));

        hog = vl_hog(Im, wHOGCell);
        imhog = vl_hog('render', hog);

        %Write results to image and mat File
        imwrite(imhog, [ComputationDir, 'hog/render/', FrameFileName, '.png'], 'png');
        parsave([ComputationDir, 'hog/data/', FrameFileName, '.mat'], hog);
    end;
end;

end

function parsave(filename, data) %#ok<INUSD>
    save(filename, 'data')
end
