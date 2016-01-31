% See the file 'LICENSE' for the full license governing this code.
function featureMat = scaleFeatureMat(featureMat, newSize)

assert(ndims(featureMat) == 3);

[sy, sx, sz] = size(featureMat);

if(sy == newSize && sx == newSize)
    return
end

[X, Y, Z] = meshgrid(linspace(0, 1, sx), linspace(0, 1, sy), linspace(0, 1, sz));
[Xq, Yq, Zq] = meshgrid(linspace(0, 1, newSize), linspace(0, 1, newSize), linspace(0, 1, sz));
featureMat = interp3(X, Y, Z, featureMat, Xq, Yq, Zq);

end
