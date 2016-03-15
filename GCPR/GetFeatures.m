function fvec = GetFeatures(patch, patchsize, hogcellsize)

%Resize patch to aimed at size
[weights, indices] = fast_imresize_contributions(length(patch), patchsize*hogcellsize, 4, true);
patch = imresizemex(patch, weights, indices, 1);
patch = imresizemex(patch, weights, indices, 2);

%Compute and normalize HOG feature
hog = vl_hog(patch, hogcellsize);
hog = reshape(hog, 1, []);
hog = hog/norm(hog);

fvec = [hog];

%Compute and normalize histogram for each channel
for c = 1:3
	hist = imhist(patch(:, :, c))';
	hist = hist/norm(hist);
	fvec = [fvec hist];
end

end