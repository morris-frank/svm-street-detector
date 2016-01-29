function HeaderConfig()

global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER
LIBSVM_PATH = '/home/morris/var/lib/liblinear-2.1/matlab';
FOLDERNAMEBASE = 'seq';
DATAFOLDER = '/home/morris/var/data/IAP/';

global HOGCELLSIZE
HOGCELLSIZE = 17;

%Size of the Bounding Boxes in multiplies of HOGCELLSIZE:
global COUNTOFHOG
COUNTOFHOG = 3;

%The Options for liblinear
global LLTYPE LLC LLE
LLTYPE = 2;
LLC = 1e2;



end