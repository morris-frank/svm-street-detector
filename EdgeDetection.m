% See the file 'LICENSE' for the full license governing this code.
function EdgeDetection(FolderNumbers)

assert(min(FolderNumbers) >= 0)

HeaderConfig
global FOLDERNAMEBASE DATAFOLDER

%Iterate through video folders
for FolderNumber = FolderNumbers
    SeqFolderName = [FOLDERNAMEBASE, sprintf('%04d', FolderNumber), '/'];
    ComputationDir = [DATAFOLDER, 'RESULTS/', SeqFolderName];

    mkdir([ComputationDir, 'edge']);
    mkdir([ComputationDir, 'edge/canny']);
    mkdir([ComputationDir, 'edge/prewitt']);

    %Iterate over frames in video
    parfor f = 1:length(dir([DATAFOLDER, 'DATA/', SeqFolderName, '/*jpg'])')
        FrameFileName = ['I', sprintf('%05d', f)];

        %The frame from the video
        FramePath = [DATAFOLDER, 'DATA/', SeqFolderName, FrameFileName, '.jpg'];

        %Read image, make them gray doubles
        %and put into gpuarray
        Im = im2single(rgb2gray(imread(FramePath)));

        %Calculate canny and prewitt pictures:
        %canny = edge(gpuIm, 'canny', 3)
        %prewitt = edge(gpuIm, 'prewitt')
        %canny = gather(canny)
        %prewitt = gather(prewitt)

        prewitt = edge(Im, 'prewitt', 0.05)
        canny = edge(Im, 'canny', [0.01, 0.07])

        %Write results to images
        imwrite(canny, [ComputationDir, 'edge/canny/', FrameFileName, '.png'], 'png');
        imwrite(prewitt, [ComputationDir, 'edge/prewitt/', FrameFileName, '.png'], 'png');
    end;
end;
