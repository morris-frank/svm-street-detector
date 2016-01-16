function MODEL=TrainFromSVMFile(trainFile)

HeaderConfig
global LIBSVM_PATH
addpath(LIBSVM_PATH)

SVMParams = '-s 2 -c 0.5';
[labelVec, instantMat] = libsvmread(trainFile);

MODEL = train(labelVec, instantMat, SVMParams);

end
