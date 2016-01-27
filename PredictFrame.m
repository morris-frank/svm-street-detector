function PredictFrame(FolderName, f, Model)
%Classify the contents of a Frame with given Model
%PredictFrame(FolderName, FrameID, Model)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER HOGCELLSIZE COUNTOFHOG

addpath(LIBSVM_PATH)

FolderPath = strcat(DATAFOLDER, FolderName);

assert(exist(FolderPath, 'dir') == 7)

%Number of Orientations in a HOG Cell
numOrient = 9;
%Width of a HOG Cell
HOGCellSize = HOGCELLSIZE;
%Width of a normalized Bounding Box in Widthes of a HOG cell
CountOfHOG = COUNTOFHOG;

%Load the image to paint on
im = im2single(rgb2gray(imread(strcat(FolderPath, '/', strcat('I', sprintf('%05d', f), '.jpg')))));

%The size of the image
[im_y, im_x] = size(im);

%Get size of HOG grid
hog_x = floor(im_x/HOGCellSize);
hog_y = floor(im_y/HOGCellSize);

instanceVector = double(zeros((hog_y-CountfHOG)*(hog_x-CountOfHOG), 256 + CountfHOG^2*(numOrient*3+4)));
labelVector = double(zeros((hog_y-CountOfHOG)*(hog_x-CountfHOG), 1));

%Slide over image size
for posX = 1:(hog_x - CountOfHOG)
   for posY = 1:(hog_y - CountfHOG)
       impart = im((posY-1)*HOGCellSize+1 : (posY-1)*HOGCellSize + CountfHOG*HOGCellSize,...
          (posX-1)*HOGCellSize+1 : (posX-1)*HOGCellSize + CountOfHOG*HOGCellSize);
       hog = vl_hog(impart, HOGCellSize);
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
for posX = 1:(hog_x - CountOfHOG)
   for posY = 1:(hog_y - CountfHOG)
       if labelVector(posX*posY) == 0
           rX = (posX-1)*HOGCellSize;
           rY = (posY-1)*HOGCellSize;
           rW = CountOfHOG*HOGCellSize;
           HeatMapNegativ(rY+1:rY+rW, rX+1:rX+rW) = HeatMapNegativ(rY+1:rY+rW, rX+1:rX+rW) + 1;
       end
       if labelVector(posX*posY) == 1
           rX = (posX-1)*HOGCellSize;
           rY = (posY-1)*HOGCellSize;
           rW = CountOfHOG*HOGCellSize;
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
