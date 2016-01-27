function MODEL=TrainFromSVMFile(trainFile)

HeaderConfig
global LIBSVM_PATH LLC LLTYPE LLE
addpath(LIBSVM_PATH)

SVMParams = strcat('-s ', num2str(LLTYPE),...
                   ' -c ', num2str(LLC, 3));
[labelVec, instantMat] = libsvmread(trainFile);

MODEL = train(labelVec, instantMat, '-s 2 -c 0.5');

end
