function CatFrames(FolderNumbers, modelname)

HeaderConfig
global FOLDERNAMEBASE DATAFOLDER

for FolderNumber = FolderNumbers
    SeqFolderName = [FOLDERNAMEBASE, sprintf('%04d', FolderNumber), '/'];
    PredictionDir = [DATAFOLDER, 'RESULTS/PREDICTIONS/', modelname, '/', SeqFolderName];

    mkdir([PredictionDir, 'result']);

    %Iterate over frames in video
    parfor f = 1:length(dir([DATAFOLDER, 'DATA/', SeqFolderName, '/*jpg'])')
        FrameFileName = ['I', sprintf('%05d', f)];

        %The frame from the video
        FramePath = [DATAFOLDER, 'DATA/', SeqFolderName, FrameFileName, '.jpg'];

        %The prediction for that frame without applied Morphology
        PredFramePath = [PredictionDir, 'prediction/', FrameFileName, '.png'];

        %The HeatMap for that frame
        PredMorphFramePath = [PredictionDir, 'morphed_prediction/', FrameFileName, '.png'];

        %The path for the result
        SavePath = [PredictionDir, 'result/', FrameFileName, '.png'];

        Normal = (rgb2gray(rjpg8c(FramePath)));
        Prediction = imread(PredFramePath);
        PredictionMorphed = imread(PredMorphFramePath);

        %Detect the edges
        Edges = edge(Image, 'canny', [0.01, 0.07]);
        Edges = imclose(Edges, strel('disk', 5));

        %Make the Edges and the frame rgb pictures
        Edges = 255 * Edges;
        Edges = cat(3, Edges, Edges, Edges);
        Normal = cat(3, Normal, Normal, Normal);

        %Cat the four pictures into a grid
        result = [Normal, Prediction; Edges, PredictionMorphed];

        imwrite(result, SavePath)
    end
end
