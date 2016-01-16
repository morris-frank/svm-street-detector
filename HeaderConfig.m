function HeaderConfig()

global LIBSVM_PATH FOLDERNAMEBASE DATAFOLDER HOGCELLSIZE BBSIZE

LIBSVM_PATH = '/home/morris/var/lib/liblinear-2.1/matlab';
FOLDERNAMEBASE = 'seq';
DATAFOLDER = '/home/morris/var/data/IAP/';

HOGCELLSIZE = 9;

%Size of the Bounding Boxes in multiplies of HOGCELLSIZE:
BBSIZE = 3;



end