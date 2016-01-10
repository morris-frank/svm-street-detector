function HOGData(FolderNumbers, wHOGCell)

if nargin < 2
    wHOGCell = 9;
end

assert(min(FolderNumbers) >= 0)
assert(wHOGCell > 0)

HeaderConfig
global VLFEAT_PATH FOLDERNAMEBASE DATAFOLDER
FolderNameAdd = '_hog/';
cd(VLFEAT_PATH)
vl_setup
cd ../../

%Iterate through video folders
for FolderNumber = FolderNumbers
    FolderPath = strcat(DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber));

    mkdir(strcat(FolderPath, FolderNameAdd));
    frames = dir(strcat(FolderPath, '/*jpg'));

    %Iterate through frames with two iterators
    parfor f = 1:length(frames)
        frame = frames(f)
        frameName = strtok(frame.('name'), '.');
        if exist(strcat(FolderPath, FolderNameAdd, frameName, '_render.png'), 'file') && exist(strcat(FolderPath, FolderNameAdd, frameName, '_data.mat'), 'file')
           continue
        end
        disp(strcat(FolderPath, ': ', frameName));

        %Read image, make them gray singles
        im = im2single(rgb2gray( imread( ...
                                        strcat(FolderPath, '/', frame.('name')) ...
                      )));

        hog = vl_hog(im, wHOGCell);
        imhog = vl_hog('render', hog);

        %Write results to image and mat File
        imwrite(imhog, strcat(FolderPath, FolderNameAdd, frameName, '_render.png'), 'png');
        parsave(strcat(FolderPath, FolderNameAdd, frameName, '_data.mat'), hog);
    end;
end;

end

function parsave(filename, data) %#ok<INUSD>
    save(filename, 'data')
end
