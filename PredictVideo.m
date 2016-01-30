function PredictVideo(FolderNumbers, Model, StartFrames)

assert(min(FolderNumbers) >= 0)

if size(StartFrames, 2) ~= 1 && size(StartFrames, 2) ~= numel(FolderNumbers)
	error('You must provide one startframe for all folders or one startframe per folder');
end

if size(StartFrames, 2) == 1
	StartFrames = ones(1, numel(FolderNumbers)) * StartFrames;
end

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER
addpath(LIBSVM_PATH)

%Iterate over video folders
for FolderNumber = FolderNumbers
    FolderPath = [DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    frames = dir([FolderPath, '/*jpg']);

    %Iterate over frames in video
    for f = StartFrames(find(FolderNumbers==FolderNumber)):length(frames)
    	FramePath = [FolderPath, '/I', sprintf('%05d', f), '.jpg'];
        [HeatMap, im] = PredictFrame(FramePath, Model);
        overlayHeatMap(MorphPrediction(HeatMap, im), im, 'green')
        pause
    end
end

end
