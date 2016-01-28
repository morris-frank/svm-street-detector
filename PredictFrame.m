function PredictFrame(FolderName, f, Model, permut)
%Classify the contents of a Frame with given Model
%PredictFrame(FolderName, FrameID, Model)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER HOGCELLSIZE COUNTOFHOG

if nargin < 4
    permut = 0;
end

addpath(LIBSVM_PATH)

FolderPath = strcat(DATAFOLDER, FolderName);

assert(exist(FolderPath, 'dir') == 7)

%Number of Orientations in a HOG Cell
numOrient = 9;
%Width of a HOG Cell
HOGCellSize = HOGCELLSIZE;
%Width of a normalized Bounding Box in Widthes of a HOG cell
CountOfHOG = COUNTOFHOG;
%Width of a normalized Bounding Box in real pixels
BBWidth = CountOfHOG * HOGCellSize;

%Load the image to paint on
im = im2single(rgb2gray(imread(strcat(FolderPath, '/', strcat('I', sprintf('%05d', f), '.jpg')))));

%The size of the image
[im_y, im_x] = size(im);


%With & Height of the sliding window used
SlideSize = 51;

%Get left and top start of the sliding window grid
slide_top = mod(im_y, SlideSize) / 2;
slide_left = mod(im_x, SlideSize) / 2;

%Get the number of windows we will predict for:
NumberOfSlides = size(slide_top : SlideSize : im_y-slide_top-1, 2)...
               * size(slide_left : SlideSize : im_x-slide_left-1, 2);

%--------------------------------------------------------
%First: Get prediction for the labels of a sliding window
%--------------------------------------------------------

instanceVector = double(zeros(NumberOfSlides, 256 + CountfHOG^2*(numOrient*3+4)));
labelVector = double(zeros(NumberOfSlides, 1));

%The index of the instance in the instanceVector
it = 1

%Slide over image
for y = slide_top : SlideSize : im_y-slide_top-1
  for x = slide_left : SlideSize : im_x-slide_left-1

    %The y-values of the sliding window
    Y = y : y+SlideSize-1;
    %The x-values of the sliding window
    X = x : x+SlideSize-1;

    %The image data for this window
    impart = im(Y, X);

    %Resize window to right size of needed
    if BBWidth ~= SlideSize
      impart = imresize(impart, [BBWidth BBWidth]);
    end

    %Compute the HOG features
    hog = vl_hog(impart, HOGCellSize);

    %If flipping is demanded permute the HOG features
    if permut ~= 0
       perm = vl_hog('permutation');
       hog = hog(:, end:-1:1, perm);
    end

    %Make floats from HOG features a vector and normalize it
    hog = reshape(hog, 1, []);
    hog = hog/norm(hog);

    %Get color histogram and normalize it
    hist = imhist(impart)';
    hist = hist/norm(hist);

    %Write the features as a instance
    instanceVector(it, :) = [hog hist];
    %Use a random label, as we don't know the real one
    labelVector(it) = rand(1) > 0.5;

    %increment the index for the next instance
    it = it + 1;

  end
end

%Make the instanceVector sparse, as liblinear requires just that
instanceVector = sparse(instanceVector);

%Predict the labels for all the instances
[labelVector] = predict(labelVector, instanceVector, Model);
clear instanceVector

%-------------------------------------------------
%Second: Draw the HeatMap for the predicted labels
%-------------------------------------------------

%Start with images of the same size as the input image
HeatMapNegativ = zeros(im_y, im_x);
HeatMapPositiv = zeros(im_y, im_x);

%reset the instance index
it = 1;

%Slide over image
for y = slide_top : SlideSize : im_y-slide_top-1
  for x = slide_left : SlideSize : im_x-slide_left-1

    %The y-values of the sliding window
    Y = y : y+SlideSize-1;
    %The x-values of the sliding window
    X = x : x+SlideSize-1;

    %The Model predicted a negativ label, so we increase the Negativ Heat Map
    %for that area
    if labelVector(it) == 0
      HeatMapNegativ(Y, X) = HeatMapNegativ(Y, X) + 1;
    end

    %The Model predicted a positiv label, so we increase the Positiv Heat Map
    %for that area
    if labelVector(it) == 1
      HeatMapPositiv(Y, X) = HeatMapPositiv(Y, X) + 1;
    end

    %increment the index for the next instance
    it = it + 1;

  end
end

%Normalize the HeatMaps
HeatMapNegativ = HeatMapNegativ / max(HeatMapNegativ(:));
HeatMapPositiv = HeatMapPositiv / max(HeatMapPositiv(:));

%The negativ HeatMap will be red, the positiv one green
%so we need rad and green masks
Red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im)));
Green = cat(3, zeros(size(im)), ones(size(im)), zeros(size(im)));

%Make a new figure for the negativ HeatMap
figure('Name', strcat(FolderName, '-', num2str(f), ' Neg'), 'WindowStyle', 'docked', 'NumberTitle', 'Off');
%imshow(im, 'InitialMag', 'fit')
hold on
hn = imshow(Red);
hold off
set(hn, 'AlphaData', HeatMapNegativ)

%Make a new figure for the positiv HeatMap
figure('Name', strcat(FolderName, '-', num2str(f), ' Pos'), 'WindowStyle', 'docked', 'NumberTitle', 'Off');
%imshow(im, 'InitialMag', 'fit')
hold on
hp = imshow(Green);
hold off
set(hp, 'AlphaData', HeatMapPositiv)

end
