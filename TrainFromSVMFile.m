function MODEL = TrainFromSVMFile(trainFile)

HeaderConfig
global LIBSVM_PATH LLC LLTYPE LLE
addpath(LIBSVM_PATH)

SVMParams = ['-s ', num2str(LLTYPE), ' -c ', num2str(LLC, 3)];
[labelVec, instantMat] = libsvmread(trainFile);

MODEL = train(labelVec, instantMat, SVMParams);

end
