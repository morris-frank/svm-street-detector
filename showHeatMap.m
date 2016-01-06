function showHeatMap(FolderNumbers, Model, wBB)

if nargin < 3
    wBB = 9;
end

assert(min(FolderNumbers) >= 0)
assert(max(FolderNumbers) <= 10)
assert(wBB > 0)

addpath('./libsvm-3.21/matlab/')
addpath('./liblinear-incdec-2.01/matlab/')

FolderNameBase = 'seq';

%Iterate over video folders
for FolderNumber = FolderNumbers
    FolderName = strcat(FolderNameBase, sprintf('%04d', FolderNumber));

    frames = dir(strcat(FolderName, '/*jpg'));

    %Iterate over frames in video
    for f = 1:length(frames)
        FrameHeatMap(FolderName, frames(f).('name'), Model, wBB)
    end
end

end
