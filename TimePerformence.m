% See the file 'LICENSE' for the full license governing this code.
function Times = TimePerformance(FolderNumber, Model, method)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER

addpath(LIBSVM_PATH)


SeqFolderName = [FOLDERNAMEBASE, sprintf('%04d', FolderNumber), '/'];
bar = waitbar(0, ['Processing ' SeqFolderName '...']);

FrameCount = length(dir([DATAFOLDER, 'DATA/', SeqFolderName, '/*jpg'])');

Times = zeros(FrameCount, 3);

%Iterate over frames in video
for f = 1:FrameCount
    FrameFileName = ['I', sprintf('%05d', f)];

    waitbar(f/FrameCount)

    tic;
    FramePath = [DATAFOLDER, 'DATA/', SeqFolderName, FrameFileName, '.jpg'];

    [HeatMap, im] = PredictFrame(FramePath, Model, method);

    Times(f, 1) = toc;

    HeatMap = MorphHeatMap(HeatMap, im);

    Times(f, 3) = toc;
    Times(f, 2) = Times(f, 3) - Times(f, 1);
end

close(bar)
