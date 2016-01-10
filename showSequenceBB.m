function showSequenceBB(FolderNumbers)

assert(min(FolderNumbers) >= 0)
assert(max(FolderNumbers) <= 10)

HeaderConfig
global FOLDERNAMEBASE DATAFOLDER

%Iterate through video folders
for FolderNumber = FolderNumbers
    FolderPath = strcat(DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber));

    frames = dir(strcat(FolderPath, '/*jpg'));

    BBFile = fopen(strcat(FolderPath, '.bb'));
    BBData = textscan(BBFile, 'seq%u16\\I%5u16.jpg\t%u16 %u16 %u16 %u16\t%1u16');
    %[1:FrameID, 2:CatID, 3:left, 4:top, 5:right, 6:bottom]
    BBMat = cell2mat({BBData{2}, BBData{7}, BBData{3}, BBData{4}, BBData{5}, BBData{6}});
    BBMat = unique(sortrows(BBMat), 'rows');
    fclose(BBFile);
    clear BBData BBFile;

    %Iterate through frames with two iterators
    for f = 1:length(frames)
        frame = frames(f);
        BBoxes = BBMat(BBMat(:, 1) == f, :);

        %Read image, make them gray singles
        im = im2single(rgb2gray( imread( ...
                                        strcat(FolderPath, '/', frame.('name')) ...
                      )));

        imshow(im), hold on

        for b = 1:size(BBoxes)
            BBox = [BBoxes(b, 3) BBoxes(b, 4) BBoxes(b, 5)-BBoxes(b, 3) BBoxes(b, 6)-BBoxes(b, 4)];
            if(BBoxes(b, 2) == 1)
                rectangle('Position', BBox, 'EdgeColor', 'g');
            else
                rectangle('Position', BBox, 'EdgeColor', 'r');
            end
        end
        hold off
        drawnow
    end
end
