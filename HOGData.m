% See the file 'LICENSE' for the full license governing this code.
function HOGData(FolderNumbers, wHOGCell)

if nargin < 2
    wHOGCell = 9;
end

assert(min(FolderNumbers) >= 0)
assert(wHOGCell > 0)

HeaderConfig
global FOLDERNAMEBASE DATAFOLDER
FolderNameAdd = '_hog/';

%Iterate through video folders
for FolderNumber = FolderNumbers
    FolderPath = [DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    mkdir([FolderPath, FolderNameAdd]);

    %Iterate through frames with two iterators
    parfor frame = dir([FolderPath, '/*jpg'])'
        frameName = strtok(frame.('name'), '.');
        if exist([FolderPath, FolderNameAdd, frameName, '_render.png'], 'file') && exist([FolderPath, FolderNameAdd, frameName, '_data.mat'], 'file')
           continue
        end
        disp([FolderPath, ': ', frameName]);

        %Read image, make them gray singles
        im = im2single(rgb2gray( imread( ...
                                        [FolderPath, '/', frame.('name')] ...
                      )));

        hog = vl_hog(im, wHOGCell);
        imhog = vl_hog('render', hog);

        %Write results to image and mat File
        imwrite(imhog, [FolderPath, FolderNameAdd, frameName, '_render.png'], 'png');
        parsave([FolderPath, FolderNameAdd, frameName, '_data.mat'], hog);
    end;
end;

end

function parsave(filename, data) %#ok<INUSD>
    save(filename, 'data')
end
