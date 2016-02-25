% See the file 'LICENSE' for the full license governing this code.
function PredictVideo(FolderNumbers, Model, modelname, method)

assert(min(FolderNumbers) >= 0)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER

addpath(LIBSVM_PATH)

for FolderNumber = FolderNumbers
    SeqFolderName = [FOLDERNAMEBASE, sprintf('%04d', FolderNumber), '/'];
    PredictionDir = [DATAFOLDER, 'RESULTS/PREDICTIONS/', modelname, '/', SeqFolderName];

    mkdir([PredictionDir, 'morphed_prediction']);
    mkdir([PredictionDir, 'morphed_prediction/data']);
    mkdir([PredictionDir, 'morphed_prediction/render']);

    mkdir([PredictionDir, 'prediction']);
    mkdir([PredictionDir, 'prediction/data']);
    mkdir([PredictionDir, 'prediction/render']);

    %Iterate over frames in video
    for f = 1:length(dir([DATAFOLDER, 'DATA/', SeqFolderName, '/*jpg'])')
        FrameFileName = ['I', sprintf('%05d', f)];

        %The frame from the video
        FramePath = [DATAFOLDER, 'DATA/', SeqFolderName, FrameFileName, '.jpg'];

        [HeatMap, im] = PredictFrame(FramePath, Model, method);

        %Save the Heat Map
        parsave([PredictionDir, 'prediction/data/', FrameFileName, '.mat'], HeatMap);

        %Save the frame without Morphology applied
        saveOverlay(HeatMap, im, [PredictionDir, 'prediction/render/', FrameFileName, '.png'])

        %Apply the Morphology and save the frame
        saveOverlay(MP2(HeatMap, im), im, [PredictionDir, 'morphed_prediction/render/', FrameFileName, '.png'])
    end
end

end

function parsave(filename, data) %#ok<INUSD>
    save(filename, 'data')
end
