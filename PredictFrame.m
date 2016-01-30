function [HeatMapPositiv, HeatMapNegativ] =  PredictFrame(FolderName, f, Model, permut, modus)
%Classify the contents of a Frame with given Model
%PredictFrame(FolderName, FrameID, Model)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER HOGCELLSIZE COUNTOFHOG

if nargin < 4
    permut = 0;
    if nargin < 5
        modus = 'pos';
    end
end

if ~strcmp(modus, 'pos') && ~strcmp(modus, 'neg') && ~strcmp(modus, 'both')
    error('The modus has to be pos, neg or both.')
end
if strcmp(modus, 'pos'); modus = 1; end
if strcmp(modus, 'neg'); modus = 0; end
if strcmp(modus, 'both'); modus = 2; end

addpath(LIBSVM_PATH)

FolderPath = [DATAFOLDER, FolderName];

assert(exist(FolderPath, 'dir') == 7)

%Number of Orientations in a HOG Cell
numOrient = 9;
%Width of a HOG Cell
HOGCellSize = HOGCELLSIZE;
%Width of a normalized Bounding Box in Widthes of a HOG cell
CountOfHOG = COUNTOFHOG;
%Width of a normalized Bounding Box in real pixels
BBWidth = CountOfHOG * HOGCellSize;
%The range of sliding window sizes
SlideSizeRange = 40:10:100;

%Load the image to paint on
im = im2single(rgb2gray(imread( ...
    [FolderPath, '/I', sprintf('%05d', f), '.jpg'] ...
)));

%The size of the image
[im_y, im_x] = size(im);

%The HeatMaps we will use later to draw the results
if modus == 1 || modus == 2
    HeatMapPositiv = zeros(im_y, im_x, 'single');
end
if modus == 0 || modus == 2
    HeatMapNegativ = zeros(im_y, im_x, 'single');
end


for SlideSize = SlideSizeRange

    %With & Height of the sliding window used
    %SlideSize = 51;
    
    %Amount of pixels the window is moved in every step
    SliderStep = floor(SlideSize/2);
    
    assert(SliderStep <= SlideSize)
    
    %Get left and top start of the sliding window grid
    slide_top = floor(mod(im_y, SlideSize) / 2);
    slide_left = floor(mod(im_x, SlideSize) / 2);
    
    %To avoid that we start at pixel 0, which doesn't exist
    slide_top = max(1, slide_top);
    slide_left = max(1, slide_left);
    
    %Get the number of windows we will predict for:
    NumberOfSlides = size(slide_top : SlideSize : im_y-slide_top-1, 2)...
                   * size(slide_left : SlideSize : im_x-slide_left-1, 2);
    
    %--------------------------------------------------------
    %First: Get prediction for the labels of a sliding window
    %--------------------------------------------------------
    
    instanceVector = zeros(NumberOfSlides, 256 + CountOfHOG^2*(numOrient*3+4), 'double');
    labelVector = zeros(NumberOfSlides, 1, 'double');
    
    %The index of the instance in the instanceVector
    it = 1;
    
    %Slide over image
    for y = slide_top : SliderStep : im_y-SlideSize
        for x = slide_left : SliderStep : im_x-SlideSize

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
    
    %------------------------------------------------
    %Second: Add the predicted labels to the HeatMaps
    %------------------------------------------------
    
    %reset the instance index
    it = 1;
    
    %Slide over image
    for y = slide_top : SliderStep : im_y-SlideSize
        for x = slide_left : SliderStep : im_x-SlideSize
    
            %The y-values of the sliding window
            Y = y : y+SlideSize-1;
            %The x-values of the sliding window
            X = x : x+SlideSize-1;
    
            %The Model predicted a negativ label, so we increase the Negativ Heat Map
            %for that area
            if modus == 0 || modus == 2
                if labelVector(it) == 0
                    HeatMapNegativ(Y, X) = HeatMapNegativ(Y, X) + 1;
                end
            end
    
            %The Model predicted a positiv label, so we increase the Positiv Heat Map
            %for that area
            if modus == 1 || modus == 2
                if labelVector(it) == 1
                    HeatMapPositiv(Y, X) = HeatMapPositiv(Y, X) + 1;
                end
            end
    
            %increment the index for the next instance
            it = it + 1;
    
        end
    end
end




if modus == 0 || modus == 2
    HeatMapNegativ = HeatMapNegativ / max(HeatMapNegativ(:));
    showHeatMap(im, HeatMapNegativ, 'red');
end

if modus == 1 || modus == 2
    HeatMapPositiv = HeatMapPositiv / max(HeatMapPositiv(:));
    showHeatMap(im, HeatMapPositiv, 'green')
end


end
