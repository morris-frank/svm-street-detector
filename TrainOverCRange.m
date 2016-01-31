% See the file 'LICENSE' for the full license governing this code.
function TrainOverCRange(trainFile, range)

if nargin < 2
	range = logspace(-4, 6, 11);
end

HeaderConfig
global LIBSVM_PATH LLC LLTYPE LLE
addpath(LIBSVM_PATH)

for c = range
	disp(['Training for c = ', num2str(c)])
	[labelVector, instanceVector] = libsvmread(trainFile);

	modelName = genvarname(['Model_' num2str(c)]);

	eval([modelName ' = train(labelVector, instanceVector, [''-s 2 -c '' num2str(c)])']);

	eval(['save(''' modelName ''', ''' modelName ''')']);

end

end
