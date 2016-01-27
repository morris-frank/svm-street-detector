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

instanceVector = double(zeros((hog_y-wBB)*(hog_x-wBB), 256 + wBB^2*(numOrient*3+4)));
labelVector = double(zeros((hog_y-wBB)*(hog_x-wBB), 1));

%Slide over image size
for posX = 1:(hog_x - wBB)
   for posY = 1:(hog_y - wBB)
       impart = im((posY-1)*wHOGCell+1 : (posY-1)*wHOGCell + wBB*wHOGCell,...
          (posX-1)*wHOGCell+1 : (posX-1)*wHOGCell + wBB*wHOGCell);
       hog = vl_hog(impart, wHOGCell);
       perm = vl_hog('permutation');
       hog = hog(:, end:-1:1, perm);
       instanceVector(posX*posY, :) = [reshape(hog, 1, []), imhist(impart)']/norm([reshape(hog, 1, []), imhist(impart)']);
       labelVector(posX*posY) = rand(1) > 0.5;
    end
end

instanceVector = sparse(instanceVector);
[labelVector] = predict(labelVector, instanceVector, Model);
clear instanceVector

HeatMapNegativ = zeros(im_y, im_x);
HeatMapPositiv = zeros(im_y, im_x);
for posX = 1:(hog_x - wBB)
   for posY = 1:(hog_y - wBB)
       if labelVector(posX*posY) == 0
           rX = (posX-1)*wHOGCell;
           rY = (posY-1)*wHOGCell;
           rW = wBB*wHOGCell;
           HeatMapNegativ(rY+1:rY+rW, rX+1:rX+rW) = HeatMapNegativ(rY+1:rY+rW, rX+1:rX+rW) + 1;
       end
       if labelVector(posX*posY) == 1
           rX = (posX-1)*wHOGCell;
           rY = (posY-1)*wHOGCell;
           rW = wBB*wHOGCell;
           HeatMapPositiv(rY+1:rY+rW, rX+1:rX+rW) = HeatMapPositiv(rY+1:rY+rW, rX+1:rX+rW) + 1;
       end

   end
end

HeatMapNegativ = HeatMapNegativ / max(HeatMapNegativ(:));
HeatMapPositiv = HeatMapPositiv / max(HeatMapPositiv(:));
Red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im)));
Green = cat(3, zeros(size(im)), ones(size(im)), zeros(size(im)));
figure('WindowStyle', 'docked', 'NumberTitle', 'Off', 'Name', strcat(FolderName, ' ', num2str(f), ' Neg'));
imshow(im, 'InitialMag', 'fit')
hold on
hn = imshow(Red);
hold off
set(hn, 'AlphaData', HeatMapNegativ)
figure('WindowStyle', 'docked', 'NumberTitle', 'Off', 'Name', strcat(FolderName, ' ', num2str(f), ' Pos'));
imshow(im, 'InitialMag', 'fit')
hold on
hp = imshow(Green);
hold off
set(hp, 'AlphaData', HeatMapPositiv)

end
