function PredictVideo(FolderNumbers, Model, wBB)

if nargin < 3
    wBB = 9;
end

assert(min(FolderNumbers) >= 0)
assert(wBB > 0)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER
addpath(LIBSVM_PATH)

%Iterate over video folders
for FolderNumber = FolderNumbers
    FolderPath = [DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    frames = dir([FolderPath, '/*jpg']);

    %Iterate over frames in video
    for f = 1:length(frames)
        PredictFrame(FolderPath, f, Model, wBB)
    end
end

end
