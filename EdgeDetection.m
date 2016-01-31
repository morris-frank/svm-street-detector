% See the file 'LICENSE' for the full license governing this code.
function EdgeDetection(FolderNumbers)

assert(min(FolderNumbers) >= 0)

HeaderConfig
global FOLDERNAMEBASE DATAFOLDER

FolderNameAdd = '_edge/';

%Iterate through video folders
for FolderNumber = FolderNumbers
    FolderPath = [DATAFOLDER, FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    mkdir([FolderPath, FolderNameAdd]);

    %Iterate through frames with two iterators
    parfor frame = dir([FolderPath, '/*jpg'])'
        frameName = strtok(frame.('name'), '.');
        if exist([FolderPath, FolderNameAdd, frameName, '_canny.jpg'], 'file') && exist([FolderPath, FolderNameAdd, frameName, '_prewitt.jpg'], 'file')
           continue
        end
        disp([FolderPath, ': ', frameName]);

        %Read image, make them gray doubles
        %and put into gpuarray
        Im = im2single(rgb2gray(imread( ...
                                    [FolderPath, '/', frame.('name')] ...
                     )));

        %Calculate canny and prewitt pictures:
        %canny = edge(gpuIm, 'canny', 3)
        %prewitt = edge(gpuIm, 'prewitt')
        %canny = gather(canny)
        %prewitt = gather(prewitt)

        prewitt = edge(Im, 'prewitt', 0.05)
        canny = edge(Im, 'canny', [0.03, 0.085])

        %Write results to images
        imwrite(canny, [FolderPath, FolderNameAdd, frameName, '_canny.png'], 'png');
        imwrite(prewitt, [FolderPath, FolderNameAdd, frameName, '_prewitt.png'], 'png');
    end;
end;
