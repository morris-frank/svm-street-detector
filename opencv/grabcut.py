#!/bin/python2.7

import numpy as np
import cv2
from matplotlib import pyplot as plt
import scipy.io as sio
import os

#CONSTANTS
BASE = '/home/morris/var/media/Elements/var/data/KITTI/'

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

    ret,fgd = cv2.threshold(hm, 0.87 * bright, 1 * bright, cv2.THRESH_BINARY)
    fgd[1:size[0]/2] = 0
    fgd[1:size[0], 1:size[1]/4] = 0
    fgd[1:size[0], size[1]*3/4:size[1]] = 0

    ret,pr_fgd = cv2.threshold(hm, 0.8 * bright, 1 * bright, cv2.THRESH_BINARY)
    pr_fgd -= fgd

    ret, bgd = cv2.threshold(hm, 0.05 * bright, 1 * bright, cv2.THRESH_BINARY_INV)
    bgd[size[0]/3:size[0]] = 0

    ret,pr_bgd = cv2.threshold(hm, 0.8 * bright, 1 * bright, cv2.THRESH_BINARY_INV)
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


def grabcutdir(imdir, matdir):
    for i in os.listdir(matdir):
        if i.endswith(".mat"):
            filename = i[:-4]
            print filename
            mat = sio.loadmat(matdir + i)
            mat = mat['yRes'].astype(np.float32, copy=False)
            im = cv2.imread(imdir + filename + '.png')
            mat = normhm(mat)
            mask = grabcuthm(im, mat)
            savesegt(imdir + filename + '_grabcut.png', mask)



def main():
    imdir = BASE + 'validation_svm/images/'
    matdir = BASE + 'validation_svm/predictions/'
    grabcutdir(imdir, matdir)

if __name__ == "__main__":
    main()