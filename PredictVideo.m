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

if strcmp(method, 'treebagger')
    FolderNameAdd = '_prediction_treebagger';
    FolderNameAddPre = '_prediction_treebagger_unmorphed';
else
    FolderNameAdd = '_prediction_liblinear';
    FolderNameAddPre = '_prediction_liblinear_unmorphed';
end
  
addpath(LIBSVM_PATH)

%Iterate over video folders
for FolderNumber = FolderNumbers
    FolderPath = [DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    mkdir([FolderPath FolderNameAdd]);
    mkdir([FolderPath FolderNameAddPre]);

    frames = dir([FolderPath, '/*jpg']);
    StartFrame = StartFrames(find(FolderNumbers==FolderNumber));
    %parpool(2)
    %Iterate over frames in video
    for f = StartFrame:length(frames)
    	FramePath = [FolderPath, '/I', sprintf('%05d', f), '.jpg'];
        [HeatMap, im] = PredictFrame(FramePath, Model, method);
        
        %Save the Heat Map
        parsave([FolderPath FolderNameAddPre '/I' sprintf('%05d', f) '.mat'],'HeatMap');
        
        %Save the frame without Morphology applied
        saveOverlay(HeatMap, im, [FolderPath FolderNameAddPre '/I' sprintf('%05d', f) '.png'])
        
        %Apply the Morphology and save the frame
        saveOverlay(MP2(HeatMap, im), im, [FolderPath FolderNameAdd '/I' sprintf('%05d', f) '.png'])
    end
end

end

function parsave(filename, data) %#ok<INUSD>
    save(filename, 'data')
end
