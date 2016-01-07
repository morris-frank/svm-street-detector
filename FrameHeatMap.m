function FrameHeatMap(FolderName, f, Model, wBB, wHOGCell, numOrient)

if nargin < 6
    numOrient = 9;
    if nargin < 5
        wHOGCell = 9;
        if nargin < 4
            wBB = 9;
        end
    end
end

assert(exist(FolderName, 'dir') == 7)
assert(exist(strcat(FolderName, '_hog/'), 'dir') == 7)

%Load HOG features for this frame
load(strcat(FolderName, '_hog/I', sprintf('%05d', f), '_data.mat'));
HOG = data; clear data
[yHOG, xHOG, ~] = size(HOG);

%Load the image to paint on
Im = rgb2gray(imread(strcat(FolderName, '/', strcat('I', sprintf('%05d', f), '.jpg'))));
[IM_Y, IM_X] = size(Im);

PredictInstantMat = double(zeros((yHOG-wBB)*(xHOG-wBB), wBB^2*(numOrient*3+4)));
PredictLabels = double(zeros((yHOG-wBB)*(xHOG-wBB), 1));

%Slide over image size
for posX = 1:(xHOG - wBB)
   for posY = 1:(yHOG - wBB)
       x = HOG(posY:(posY + wBB-1), posX:(posX + wBB-1), :);
       PredictInstantMat(posX*posY, :) = reshape(x, [], 1).';
       PredictLabels(posX*posY) = rand(1) > 0.5;
    end
end

[PredictLabels] = svmpredict(PredictLabels, PredictInstantMat, Model);
clear PredictInstantMat

HeatMap = zeros(IM_Y, IM_X);
for posX = 1:(xHOG - wBB)
   for posY = 1:(yHOG - wBB)
       if PredictLabels(posX*posY) == 1
           rX = (posX-1)*wBB+1;
           rY = (posY-1)*wBB+1;
           rW = wBB*wHOGCell;
           HeatMap(rY:rY+rW, rX:rX+rW) = HeatMap(rY:rY+rW, rX:rX+rW) + 1;
       end
   end
end

HeatMap = HeatMap / max(HeatMap(:));
imshow(Im, 'InitialMag', 'fit')
Red = cat(3, ones(size(Im)), zeros(size(Im)), zeros(size(Im)));
hold on
h = imshow(Red);
hold off
set(h, 'AlphaData', HeatMap)

end
