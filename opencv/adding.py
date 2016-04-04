#!/bin/python2.7

import sys
import os
import numpy as np
import cv2
from matplotlib import pyplot as plt
import scipy.io as sio

#CONSTANTS
BASE = '/home/morris/var/media/Elements/var/data/KITTI/'

def normhm(hm):
    maxs = np.amax(hm)
    mins = np.amin(hm)
    hm = (hm - mins) / (maxs - mins)
    return hm


def savesegt(path, mask):
    cv2.imwrite(path, 255 * mask)


def adddir(mat1dir, mat2dir, outdir):
    for i in os.listdir(mat1dir):
        if i.endswith(".png"):
            filename = i[:-4]
            print filename
            if os.path.exists(outdir + filename + '.png'):
					print '...skipped'
					continue
            mat1 = cv2.imread(mat1dir + i)
            mat1 = mat1[:,:,1]
            mat1 = mat1.astype(np.float32, copy=False)
            mat1 = normhm(mat1)

            mat2 = cv2.imread(mat2dir + i)
            mat2 = mat2[:,:,1]
            mat2 = mat2.astype(np.float32, copy=False)
            mat2 = normhm(mat2)

            savesegt(outdir + filename + '.png', normhm(np.multiply(mat1,mat1)))


def imshow(im):
    plt.imshow(im),plt.colorbar(),plt.show()


def main(argv):
    seq = argv[0]

    print seq

    BASEP = '/home/morris/var/media/Elements/var/data/KITTI/data_road/'

    print 'LibLinear'
    hmp1 = BASEP + 'LibLinear_Results/' + seq + '/predictions/'
    outp1 = BASEP + 'LibLinear_Results/' + seq + '/grabcut_' + argv[1] + '_' + argv[2] + '_' + argv[3] + '/'
    outp2 = BASEP + 'LibLinear_Results/' + seq + '/grabcut_' + argv[1] + '_' + argv[2] + '_' + argv[3] + '_add/'
    adddir(hmp1, outp1, outp2)

if __name__ == "__main__":
    main(sys.argv[1:])
