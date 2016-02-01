% See the file 'LICENSE' for the full license governing this code.
function PredictVideo(FolderNumbers, Model, method, StartFrames)

if nargin < 4
    StartFrames = 1;
end

assert(min(FolderNumbers) >= 0)

if size(StartFrames, 2) ~= 1 && size(StartFrames, 2) ~= numel(FolderNumbers)
	error('You must provide one startframe for all folders or one startframe per folder');
end

if size(StartFrames, 2) == 1
	StartFrames = ones(1, numel(FolderNumbers)) * StartFrames;
end

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER
FolderNameAdd = '_prediction/';
addpath(LIBSVM_PATH)

%Iterate over video folders
for FolderNumber = FolderNumbers
    FolderPath = [DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    mkdir([FolderPath FolderNameAdd]);

    frames = dir([FolderPath, '/*jpg']);
    StartFrame = StartFrames(find(FolderNumbers==FolderNumber));

    bar = waitbar(0, ['Processing ' FolderPath '...']);

    %Iterate over frames in video
    parfor f = StartFrame:length(frames)
        waitbar((f-StartFrame)/length(frames))
    	FramePath = [FolderPath, '/I', sprintf('%05d', f), '.jpg'];
        [HeatMap, im] = PredictFrame(FramePath, Model, method);
        saveOverlay(MorphPrediction(HeatMap, im), im, [FolderPath FolderNameAdd '/I' sprintf('%05d', f) '.png'])
    end

    close(bar)
end

end
