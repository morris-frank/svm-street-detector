function showHeatMap(FolderNumbers, Model, wBB)

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
    FolderPath = strcat(DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber));

    frames = dir(strcat(FolderPath, '/*jpg'));

    %Iterate over frames in video
    for f = 1:length(frames)
        FrameHeatMap(FolderPath, f, Model, wBB)
    end
end

end
