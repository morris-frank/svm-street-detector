function HeaderConfig()

global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER
LIBSVM_PATH = '/home/morris/var/lib/liblinear-2.1/matlab';
FOLDERNAMEBASE = 'seq';
DATAFOLDER = '/home/morris/var/data/IAP/';

global HOGCELLSIZE
HOGCELLSIZE = 9;

%Size of the Bounding Boxes in multiplies of HOGCELLSIZE:
global BBSIZE
BBSIZE = 3;

%The Options for liblinear
global LLTYPE LLC
LLTYPE = 2;
LLC = 4.8828e-04;



end