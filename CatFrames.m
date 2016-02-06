function CatFrames(FolderNumbers, method)

HeaderConfig
global FOLDERNAMEBASE DATAFOLDER

if strcmp(method, 'treebagger')
    SaveAdd = '_result_treebagger';
    FolderNameAdd = '_prediction_treebagger';
    FolderNameAddPre = '_prediction_treebagger_unmorphed';
else
    SaveAdd = '_result_liblinear';
    FolderNameAdd = '_prediction_liblinear';
    FolderNameAddPre = '_prediction_liblinear_unmorphed';
end

for FolderNumber = FolderNumbers
    FolderPath = [DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    frames = dir([FolderPath, '/*jpg']);
    
    mkdir([FolderPath SaveAdd]);

    %Iterate over frames in video
    parfor f = 1:length(frames)
        %The frame from the video
        NormalFramePath = [FolderPath, '/I', sprintf('%05d', f), '.jpg'];
        
        %The prediction for that frame with applied Morphology
        PredFramePath = [FolderPath, FolderNameAddPre, '/I', sprintf('%05d', f), '.png'];
        
        %The HeatMap for that frame
        PredMorphFramePath = [FolderPath, FolderNameAdd, '/I', sprintf('%05d', f), '.png'];
        
        %The path for the result
        SavePath = [FolderPath, SaveAdd, '/I', sprintf('%05d', f), '.png'];
      
        Normal = (rgb2gray(rjpg8c(NormalFramePath)));
        Prediction = imread(PredFramePath);
        PredictionMorphed = imread(PredMorphFramePath);
    
        %Calculate the edges
        Edges = edge(Normal, 'canny', [0.03, 0.085]);

        %Thicken the detected edges
        Edges = bwmorph(Edges, 'thicken', 7);
        
        %Make the Edges and the frame rgb pictures
        Edges = 255 * Edges;
        Edges = cat(3, Edges, Edges, Edges);
        Normal = cat(3, Normal, Normal, Normal);
    
        %Cat the four pictures into a grid
        result = [Normal, Prediction; Edges, PredictionMorphed];
    
        imwrite(result, SavePath)
    end
end
