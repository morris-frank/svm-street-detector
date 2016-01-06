function EdgeDetection(FolderNumbers)

assert(min(FolderNumbers) >= 0)

HeaderConfig
global FOLDERNAMEBASE

FolderNameAdd = '_edge/';

%Iterate through video folders
for FolderNumber = FolderNumbers
    FolderName = strcat(FOLDERNAMEBASE, sprintf('%04d', FolderNumber));

    mkdir(strcat(FolderName, FolderNameAdd));
    frames = dir(strcat(FolderName, '/*jpg'));

    %Iterate through frames with two iterators
    parfor f = 1:length(frames)
        frame = frames(f)
        frameName = strtok(frame.('name'), '.');
        if exist(strcat(FolderName, FolderNameAdd, frameName, '_canny.jpg'), 'file') && exist(strcat(FolderName, FolderNameAdd, frameName, '_prewitt.jpg'), 'file')
           continue
        end
        disp(strcat(FolderName, ': ', frameName));

        %Read image, make them gray doubles
        %and put into gpuarray
        Im = rgb2gray( imread( ...
                                    strcat(FolderName, '/', frame.('name')) ...
                     ));

        %Calculate canny and prewitt pictures:
        %canny = edge(gpuIm, 'canny', 3)
        %prewitt = edge(gpuIm, 'prewitt')
        %canny = gather(canny)
        %prewitt = gather(prewitt)

        prewitt = edge(Im, 'prewitt', 0.05)
        canny = edge(Im, 'canny', [0.03, 0.085])

        %Write results to images
        imwrite(canny, strcat(FolderName, FolderNameAdd, frameName, '_canny.png'), 'png');
        imwrite(prewitt, strcat(FolderName, FolderNameAdd, frameName, '_prewitt.png'), 'png');
    end;
end;
