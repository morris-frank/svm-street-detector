function calcSVM(FolderNumbers)

assert(min(FolderNumbers) >= 0)

HeaderConfig
global LIBSVM_PATH FOLDERNAMEBASE
addpath(LIBSVM_PATH)

%Size of a HOG Cell:
wHOGCell = 9;
%Maximal with of a Bounding Box
MwBB = 11;
global x y MODEL

TrainParams = '';

%Iterate over video folders
for FolderNumber = FolderNumbers
    FolderName = strcat(FOLDERNAMEBASE, sprintf('%04d', FolderNumber));

    frames = dir(strcat(FolderName, '/*jpg'));

    %Load and parse all bounding boxes for that video
    BBFile = fopen(strcat(FolderName, '.bb'));
    BBData = textscan(BBFile, 'seq%u16\\I%5u16.jpg    %u16 %u16 %u16 %u16    %1u16');
    %[1:FrameID, 2:CatID, 3:left, 4:top, 5:right, 6:bottom]
    BBMat  = cell2mat({BBData{2}, BBData{7}, BBData{3}, BBData{4}, BBData{5}, BBData{6}});
    BBMat  = unique(sortrows(BBMat), 'rows');
    fclose(BBFile);
    clear BBData BBFile;

    i = 1;
    Size_All_BBoxes = size(BBMat, 1);
    MODEL;

    %Iterate over frames in a video
    for f = 1:length(frames)

        %Get all bounding boxes on that frame
        BBoxes = BBMat(BBMat(:, 1) == f, :);
        Size_BBoxes = size(BBoxes, 1);

        %Load HOG features for this frame
        load(strcat(FolderName, '_hog/I', sprintf('%05d', f), '_data.mat'));
        HOG = data; clear data
        [yHOG, xHOG, ~] = size(HOG);

        y = zeros(Size_BBoxes);
        x = {};

        %Iterate over Bounding Boxes of that frame
        for b = 1:Size_BBoxes;

            %Most left HOG cell overlapping BBox:
            l = idivide(BBoxes(b, 3), wHOGCell, 'floor') + 1;
            %Most right HOG cell overlapping BBox:
            r = idivide(BBoxes(b, 5), wHOGCell, 'floor') + 2;
            r = min(r, xHOG);
            %Highest HOG cell overlapping BBox:
            o = idivide(BBoxes(b, 4), wHOGCell, 'floor') + 1;
            %Lowest HOG cell overlapping BBox:
            u = idivide(BBoxes(b, 6), wHOGCell, 'floor') + 2;
            u = min(u, yHOG);

            y(b) = BBoxes(b, 2);
            x{b} = zeros(MwBB, MwBB, wHOGCell * 3 + 4);
            x{b}(1:(u-o+1), 1:(r-l+1), :) = HOG(o:u, l:r, :);

            i = i + 1;
        end
        try
            x = cat(4, x{:});
            x = sparse(reshape(x, [], size(x, 4)).');
            if isempty(MODEL)
                %MODEL = train(y, x, '-s 2');
                MODEL = svmtrain(y, x);
            else
                %MODEL = train(y, x, '-s 2 -i MODEL');
                MODEL = svmtrain(y, x);
            end
        catch
            disp(strcat('Not using: ', i))
            continue
        end
        disp(strcat(num2str(i/Size_All_BBoxes*100), '%'));
    end

    pause
end
