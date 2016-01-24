function PredictFrame(FolderName, f, Model, wBB, wHOGCell, numOrient)
%Classify the contents of a Frame with given Model
%PredictFrame(FolderName, FrameID, Model, wBB, wHOGCell, numOrient)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER HOGCELLSIZE BBSIZE
addpath(LIBSVM_PATH)
FolderPath = strcat(DATAFOLDER, FolderName);

if nargin < 6
    numOrient = 9;
    if nargin < 5
        wHOGCell = HOGCELLSIZE;
        if nargin < 4
            wBB = BBSIZE;
        end
    end
end

assert(exist(FolderPath, 'dir') == 7)

%Load the image to paint on
im = im2single(rgb2gray(imread(strcat(FolderPath, '/', strcat('I', sprintf('%05d', f), '.jpg')))));
[im_y, im_x] = size(im);

%Get size of HOG grid
hog_x = floor(im_x/wHOGCell);
hog_y = floor(im_y/wHOGCell);

PredictInstantMat = sparse(double(zeros((hog_y-wBB)*(hog_x-wBB), 256 + wBB^2*(numOrient*3+4))));
PredictLabels = double(zeros((hog_y-wBB)*(hog_x-wBB), 1));

%Slide over image size
for posX = 1:(hog_x - wBB)
   for posY = 1:(hog_y - wBB)
       impart = im((posY-1)*wHOGCell+1 : (posY-1)*wHOGCell + wBB*wHOGCell,...
          (posX-1)*wHOGCell+1 : (posX-1)*wHOGCell + wBB*wHOGCell);
       hog = vl_hog(impart, wHOGCell);
       PredictInstantMat(posX*posY, :) = [reshape(hog, 1, []), imhist(impart)'];
       PredictLabels(posX*posY) = rand(1) > 0.5;
    end
end

[PredictLabels] = predict(PredictLabels, PredictInstantMat, Model);
clear PredictInstantMat

HeatMap = zeros(im_y, im_x);
for posX = 1:(hog_x - wBB)
   for posY = 1:(hog_y - wBB)
       if PredictLabels(posX*posY) == 1
           rX = (posX-1)*wHOGCell;
           rY = (posY-1)*wHOGCell;
           rW = wBB*wHOGCell;
           HeatMap(rY+1:rY+rW, rX+1:rX+rW) = HeatMap(rY+1:rY+rW, rX+1:rX+rW) + 1;
       end
       if PredictLabels(posX*posY) == 0
           rX = (posX-1)*wHOGCell;
           rY = (posY-1)*wHOGCell;
           rW = wBB*wHOGCell;
           HeatMap(rY+1:rY+rW, rX+1:rX+rW) = HeatMap(rY+1:rY+rW, rX+1:rX+rW) - 1;
       end
       
   end
end

HeatMap = HeatMap / max(HeatMap(:));
imshow(im, 'InitialMag', 'fit')
Red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im)));
hold on
h = imshow(Red);
hold off
set(h, 'AlphaData', HeatMap)

end
