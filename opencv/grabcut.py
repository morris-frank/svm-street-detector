#!/bin/python2.7

import sys
import os
import numpy as np
import cv2
from matplotlib import pyplot as plt
import scipy.io as sio

#CONSTANTS
BASE = '/home/morris/var/media/Elements/var/data/KITTI/'

#Lower confidence bound for positive seeds
FGD_BOUND = 0.5
#Upper confidence bound for negative seeds
BGD_BOUND = 0.4
#Seperating confidence bound between probable positive and negative
FGD_BGD_SEP = 0.5

def readbb(bbfile):
    fid = open(bbfile, 'r')

    ind = ''
    bbv = []

    while True :
        bb = fid.readline()
        bb = bb.rstrip()
        if not bb: break
        bb = bb.split()

        #Bounding Box
        for i in [1,2,3,4]:
            bb[i] = int(bb[i])

        #Label
        bb[5] = bb[5] == '1' and True or False

        if bb[0] == ind:
            bbv .append(bb[1:6])
        else:
            if ind:
                grabcutbb(ind, bbv)
            bbv = [bb[1:6]]
            ind = bb[0]


def grabcutbb(im, bbv):
    mask = np.full(im.shape[:2],cv2.GC_PR_BGD,np.uint8)

    for bb in bbv:
        if bb[4]:
            cv2.rectangle(mask, (bb[0], bb[1]), (bb[2], bb[3]), int(cv2.GC_FGD), -1)
        else:
            cv2.rectangle(mask, (bb[0], bb[1]), (bb[2], bb[3]), int(cv2.GC_BGD), -1)

    bgdModel = np.zeros((1,65),np.float64)
    fgdModel = np.zeros((1,65),np.float64)

    rect = (0, im.shape[:2][0]/2, im.shape[:2][1], im.shape[:2][0])

    cv2.grabCut(im, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_MASK)

    mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')

    return mask2


def grabcuthm(im, hm):
    size = hm.shape

    bright = np.amax(hm)

    ret,fgd = cv2.threshold(hm, FGD_BOUND * bright, 1 * bright, cv2.THRESH_BINARY)
    fgd[1:size[0]/2] = 0
    fgd[1:size[0], 1:size[1]/4] = 0
    fgd[1:size[0], size[1]*3/4:size[1]] = 0

    ret,pr_fgd = cv2.threshold(hm, FGD_BGD_SEP * bright, 1 * bright, cv2.THRESH_BINARY)
    pr_fgd -= fgd

    ret, bgd = cv2.threshold(hm, BGD_BOUND * bright, 1 * bright, cv2.THRESH_BINARY_INV)
    bgd[size[0]/3:size[0]] = 0

    ret,pr_bgd = cv2.threshold(hm, FGD_BGD_SEP * bright, 1 * bright, cv2.THRESH_BINARY_INV)
    pr_bgd -= bgd

    mask = cv2.GC_BGD * bgd + cv2.GC_FGD * fgd + cv2.GC_PR_BGD * pr_bgd + cv2.GC_PR_FGD * pr_fgd
    mask = mask.astype(np.uint8, copy=False)

    bgdModel = np.zeros((1,65),np.float64)
    fgdModel = np.zeros((1,65),np.float64)

    rect = (0, im.shape[:2][0]/2, im.shape[:2][1], im.shape[:2][0])

    cv2.grabCut(im, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_MASK)
    mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')

    return mask2


def savesegt(path, mask):
    cv2.imwrite(path, 255 * mask)


def imshow(im):
    plt.imshow(im),plt.colorbar(),plt.show()


def normhm(hm):
    maxs = np.amax(hm)
    mins = np.amin(hm)
    hm = (hm - mins) / (maxs - mins)
    return hm


def grabcutdir(imdir, matdir, outdir):
    for i in os.listdir(matdir):
        if i.endswith(".mat"):
            filename = i[:-4]
            print filename
            if os.path.exists(outdir + filename + '.png'):
					print '...skipped'
					continue

            mat = sio.loadmat(matdir + i)
            if 'yRes' in mat:
                mat = mat['yRes'].astype(np.float32, copy=False)
            elif 'data' in mat:
                mat = mat['data'].astype(np.float32, copy=False)
            if os.path.exists(imdir + filename + '.png'):
                im = cv2.imread(imdir + filename + '.png')
            else:
                im = cv2.imread(imdir + filename + '.jpg')
            mat = normhm(mat)
            mask = grabcuthm(im, mat)
            savesegt(outdir + filename + '.png', mask)
        if i.endswith(".png"):
            filename = i[:-4]
            print filename
            if os.path.exists(outdir + filename + '.png'):
					print '...skipped'
					continue
            mat = cv2.imread(matdir + i)
            mat = mat[:,:,1]
            mat = mat.astype(np.float32, copy=False)
            if os.path.exists(imdir + filename + '.png'):
                im = cv2.imread(imdir + filename + '.png')
            else:
                im = cv2.imread(imdir + filename + '.jpg')
            mat = normhm(mat)
            mask = grabcuthm(im, mat)
            savesegt(outdir + filename + '.png', mask)


def main(argv):
    seq = argv[0]

    print seq

    #Lower confidence bound for positive seeds
    if int(argv[1] > 9):
        FGD_BOUND = int(argv[1]) / 100
    else:
        FGD_BOUND = int(argv[1]) / 10
    #Upper confidence bound for negative seeds
    if int(argv[1] > 9):
        BGD_BOUND = int(argv[2]) / 100
    else:
        BGD_BOUND = int(argv[2]) / 10
    #Seperating confidence bound between probable positive and negative
    if int(argv[1] > 9):
        FGD_BGD_SEP = int(argv[3]) / 100
    else:
        FGD_BGD_SEP = int(argv[3]) / 10

    BASEP = '/home/morris/var/media/Elements/var/data/KITTI/data_road/'

    print 'LibLinear'
    hmp1 = BASEP + 'LibLinear_Results/' + seq + '/predictions/'
    imp1 = BASEP + seq + '/image/'
    outp1 = BASEP + 'LibLinear_Results/' + seq + '/grabcut_' + argv[1] + '_' + argv[2] + '_' + argv[3] + '/'
    grabcutdir(imp1, hmp1, outp1)

if __name__ == "__main__":
    main(sys.argv[1:])
