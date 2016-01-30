function [weights, indices] = fast_imresize_contributions(in_length, out_length, kernel_width, antialiasing)

scale = out_length / in_length;

if (scale < 1) && (antialiasing)
    % Use a modified kernel to simultaneously interpolate and
    % antialias.
    h = @(x) scale * cubic(scale * x);
    kernel_width = kernel_width / scale;
else
    % No antialiasing; use unmodified kernel.
    h = @cubic;
end

% Output-space coordinates.
x = (1:out_length)';

% Input-space coordinates. Calculate the inverse mapping such that 0.5
% in output space maps to 0.5 in input space, and 0.5+scale in output
% space maps to 1.5 in input space.
u = x/scale + 0.5 * (1 - 1/scale);

% What is the left-most pixel that can be involved in the computation?
left = floor(u - kernel_width/2);

% What is the maximum number of pixels that can be involved in the
% computation?  Note: it's OK to use an extra pixel here; if the
% corresponding weights are all zero, it will be eliminated at the end
% of this function.
P = ceil(kernel_width) + 2;

% The indices of the input pixels involved in computing the k-th output
% pixel are in row k of the indices matrix.
indices = bsxfun(@plus, left, 0:P-1);

% The weights used to compute the k-th output pixel are in row k of the
% weights matrix.
weights = h(bsxfun(@minus, u, indices));

% Normalize the weights matrix so that each row sums to 1.
weights = bsxfun(@rdivide, weights, sum(weights, 2));

% Mirror out-of-bounds indices; equivalent of doing symmetric padding
aux = [1:in_length,in_length:-1:1];
indices = aux(mod(indices-1,length(aux)) + 1);

% If a column in weights is all zero, get rid of it.
kill = find(~any(weights, 1));
if ~isempty(kill)
    weights(:,kill) = [];
    indices(:,kill) = [];
end

weights = weights';
indices = indices';
%---------------------------------------------------------------------

%=====================================================================
function f = cubic(x)
% See Keys, "Cubic Convolution Interpolation for Digital Image
% Processing," IEEE Transactions on Acoustics, Speech, and Signal
% Processing, Vol. ASSP-29, No. 6, December 1981, p. 1155.

absx = abs(x);
absx2 = absx.^2;
absx3 = absx.^3;

f = (1.5*absx3 - 2.5*absx2 + 1) .* (absx <= 1) + ...
                (-0.5*absx3 + 2.5*absx2 - 4*absx + 2) .* ...
                ((1 < absx) & (absx <= 2));
%---------------------------------------------------------------------