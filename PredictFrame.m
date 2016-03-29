% See the file 'LICENSE' for the full license governing this code.
function [hm, im] =  PredictFrame(model, conf, fpath)

LibLinear = 1;
Randforest = 0;

SlideSizeRange = 50:10:90;

% Model is LibLinear
if isstruct(model)
    method = LibLinear;
% Model is Randforest
elseif isobject(model)
    method = Randforest;
end

%Read the image
im = im2single(imread(fpath));
sim = struct('y', size(im, 1), 'x', size(im, 2));

%Dimensions of the feature vector
fdims = 3 * 256 + conf.patchsize^2 * (3 * conf.hogorientations + 4);

%Holds the load HeatMap
hm = zeros(sim.y, sim.x, 'double');


for SlideSize = SlideSizeRange

    %Amount of pixels the window is moved in every step
    step = 10;

    %Get left and top start of the sliding window grid
    x = floor(mod(sim.y, SlideSize) / 2);
    y = floor(mod(sim.x, SlideSize) / 2);

    %To avoid that we start at pixel 0, which doesn't exist
    x = max(1, x);
    y = max(1, y);

    head = struct('y', x, 'x', y);
    clear x y

    %Get the number of windows we will predict for:
    pdims = size(head.y : step : sim.y-head.y-1, 2)...
                   * size(head.x : step : sim.x-head.x-1, 2);

    instances = zeros(pdims, fdims, 'double');
    labels = zeros(pdims, 1, 'double');

    %------------------------------------------------
    %First: Classify for window size
    %------------------------------------------------
    %The index of the instance in the instances vector
    it = 1;
    for y = head.y:step:sim.y-SlideSize
        for x = head.x:step:sim.x-SlideSize

            %The y-values of the sliding window
            Y = y:y+SlideSize-1;
            %The x-values of the sliding window
            X = x:x+SlideSize-1;

            window = im(Y, X, :);

            %Calculate features for the current window and add a random label
            instances(it, :) = GetFeatures(window, conf.patchsize, conf.hogcellsize);
            labels(it) = rand(1) > 0.5;

            %increment the index for the next instance
            it = it + 1;
        end
    end

    switch method
        case LibLinear
            %Make the instances sparse, as liblinear requires just that
            instances = sparse(instances);
            %Predict the labels for all the instances
            [labels] = predict(labels, instances, model);

        case Randforest
            %Predict the labels for all the instances
            [labels] = model.predict(instances);
    end

    %------------------------------------------------
    %Second: Paint prediction on heat map
    %------------------------------------------------
    %The index of the instance in the instances vector
    it = 1;
    for y = head.y:step:sim.y-SlideSize
        for x = head.x:step:sim.x-SlideSize

            %The y-values of the sliding window
            Y = y:y+SlideSize-1;
            %The x-values of the sliding window
            X = x:x+SlideSize-1;

            %randforest returns the label as a string so in this case we convert it to a number
            switch method
                case LibLinear
                    label = labels(it);
                case Randforest
                    label = str2double(labels(it));
            end

            if label == 49
                hm(Y, X) = hm(Y, X) + 1;
            end

            %increment the index for the next instance
            it = it + 1;
        end
    end

end


hm = hm / max(hm(:));

end