% See the file 'LICENSE' for the full license governing this code.
function [HeatMap, im] =  PredictFrame(FramePath, Model, method, modus, permut)
%Classify the contents of a Frame with given Model
%PredictFrame(FolderName, FrameID, Model)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER HOGCELLSIZE COUNTOFHOG

if nargin < 5
    permut = 0;
    if nargin < 4
        modus = 'pos';
        if nargin < 3
            method = 'liblinear';
        end
    end
end

if strcmp(modus, 'pos') == 0 && strcmp(modus, 'neg') == 0
    error('The modus has to be pos, neg.')
end
if strcmp(modus, 'pos'); modusID = 1; end
if strcmp(modus, 'neg'); modusID = 0; end

if strcmp(method, 'liblinear') == 0 && strcmp(method, 'treebagger') == 0
    error('The method has to be liblinear, treebagger.')
end
if strcmp(method, 'liblinear')
    addpath(LIBSVM_PATH)
    methodID = 1;
end
if strcmp(method, 'treebagger'); methodID = 0; end


assert(exist(FramePath, 'file') == 2)

%Number of Orientations in a HOG Cell
numOrient = 9;
%Width of a HOG Cell
HOGCellSize = HOGCELLSIZE;
%Width of a normalized Bounding Box in Widthes of a HOG cell
CountOfHOG = COUNTOFHOG;
%Width of a normalized Bounding Box in real pixels
BBWidth = CountOfHOG * HOGCellSize;
%The range of sliding window sizes
SlideSizeRange = 50:10:70;

%Load the image to paint on
im = im2single(rgb2gray(rjpg8c(FramePath)));

%The size of the image
[im_y, im_x] = size(im);

%The HeatMaps we will use later to draw the results
HeatMap = zeros(im_y, im_x, 'single');

for SlideSize = SlideSizeRange

    %Compute the contributions for the resize call,
    %as the SlideSize doesn't change in the inner for loop the weights and indices
    %are the same and should only be computed on time, what we are doing here...
    [resizeWeights, resizeIndices] = fast_imresize_contributions(SlideSize, BBWidth, 4, true);
    
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
                impart = imresizemex(impart, resizeWeights, resizeIndices, 1);
                impart = imresizemex(impart, resizeWeights, resizeIndices, 2);
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
    

    switch methodID
        %First case: We use the liblinear to predict
        case 1
            %Make the instanceVector sparse, as liblinear requires just that
            instanceVector = sparse(instanceVector);
            %Predict the labels for all the instances
            [labelVector] = predict(labelVector, instanceVector, Model);
    
        %Second case: We use the TreeBagger to predict
        case 0
            %Predict the labels for all the instances
            [labelVector] = Model.predict(instanceVector);
    end
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

            %Treebagger returns the label as a string so in this case we convert it to a number
            switch methodID
                case 1
                    label = labelVector(it);
                case 0
                    label = str2double(labelVector(it));
            end
    
            %If we want the positiv HeatMap modusID is 1 and label has to be 1
            %if we want the negativ one modusID is 0 and label has to be 0
            if modusID == label
                HeatMap(Y, X) = HeatMap(Y, X) + 1;
            end
    
            %increment the index for the next instance
            it = it + 1;
    
        end
    end
end

HeatMap = HeatMap / max(HeatMap(:));

end