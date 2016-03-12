function SampleHM(im, hm, patchfolder, basename)

assert(islogical(hm))

HMs = size(hm);

NumPos = 40;
MinsP = 30;
MaxsP = 70;

NumNeg = 30;
MinsN = 50;
MaxsN = 70;

PatchID = 1;

PosSampleSizes = randi(MaxsP-MinsP, NumPos, 1) + MinsP-1;
erodeHm = imerode(hm, strel('square', MinsP));
for S=MinsP+10:10:MaxsP
    erodeHm = remBorder(erodeHm, max(PosSampleSizes));
    SizeInd = find(PosSampleSizes < S);
    Sizes = PosSampleSizes(SizeInd);
    PosSampleSizes(SizeInd) = [];

    %Get indices of all street points
    Street = find(erodeHm);

    %Sample for all sizes random street pixels
    AimMiddleInd = randperm(length(Street), length(Sizes));
    MiddleInd = Street(AimMiddleInd);
    
    clear Street
    
    for B = 1:length(MiddleInd)
        BBi = MiddleInd(B);
        BBs = floor(Sizes(B)/2);

        row = mod(BBi, HMs(1));
        col = floor(BBi/HMs(1)) + 1;
        
        rows = row-BBs : row+BBs;
        cols = col-BBs : col+BBs;
        
        imwrite(im(rows, cols, :), [patchfolder '/pos/' basename '_' sprintf('%06d', PatchID) '.png']);
        PatchID = PatchID + 1;
    end
    erodeHm = imerode(erodeHm, strel('square', 10));
end

hm = imcomplement(hm);

NegSampleSizes = randi(MaxsN-MinsN, NumNeg, 1) + MinsN-1;
erodeHm = imerode(hm, strel('square', MinsN));
for S=MinsN+5:5:MaxsN
    erodeHm = remBorder(erodeHm, max(NegSampleSizes));
    SizeInd = find(NegSampleSizes < S);
    Sizes = NegSampleSizes(SizeInd);
    NegSampleSizes(SizeInd) = [];

    %Get indices of all non street points
    NotStreet = find(erodeHm);

    %Sample for all sizes random Notstreet pixels
    AimMiddleInd = randperm(length(NotStreet), length(Sizes));
    MiddleInd = NotStreet(AimMiddleInd);

    clear NotStreet
    
    for B = 1:length(MiddleInd)
        BBi = MiddleInd(B);
        BBs = floor(Sizes(B)/2);

        row = mod(BBi, HMs(1));
        col = floor(BBi/HMs(1)) + 1;

        rows = row-BBs : row+BBs;
        cols = col-BBs : col+BBs;
        
        imwrite(im(rows, cols, :), [patchfolder '/neg/' basename '_' sprintf('%06d', PatchID) '.png']);
        PatchID = PatchID + 1;
    end
    erodeHm = imerode(erodeHm, strel('square', 5));
end

end

function hm = remBorder(hm, b)
    s = size(hm);
    hm([1:b s(1)-b:s(1)], :) = 0;
    hm(:, [1:b s(2)-b:s(2)]) = 0;
end