#!/bin/python2.7

import numpy as np
import cv2
from matplotlib import pyplot as plt
import scipy.io as sio

#CONSTANTS
BASE = '/home/morris/var/media/Elements/var/data/KITTI/'

BBDIR = BASE + 'kitti_boundingboxes/'
#CONSTANTS END

BBID = 'kitti0019'

BBFILE = BBDIR + BBID + '.sorted.bb'
IMDIR = BASE + 'vid/2011_09_26/2011_09_26_drive_0019_sync/image_02/data/'


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
                grabpic(ind, bbv)
            bbv = [bb[1:6]]
            ind = bb[0]


def grabpic(filename, bbv):
    print 'GrabCut for ' + filename
    im = cv2.imread(IMDIR + filename)
    mask = np.full(im.shape[:2],cv2.GC_PR_BGD,np.uint8)

    fig = plt.figure()

    for bb in bbv:
        if bb[4]:
            cv2.rectangle(mask, (bb[0], bb[1]), (bb[2], bb[3]), int(cv2.GC_FGD), -1)
        else:
            cv2.rectangle(mask, (bb[0], bb[1]), (bb[2], bb[3]), int(cv2.GC_BGD), -1)

    bgdModel = np.zeros((1,65),np.float64)
    fgdModel = np.zeros((1,65),np.float64)

    rect = (0, im.shape[:2][0]/2, im.shape[:2][1], im.shape[:2][0])

    a = fig.add_subplot(2,2,3)
    plt.imshow(mask)
    plt.axis('off')

    cv2.grabCut(im, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_MASK)

    mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')

    a = fig.add_subplot(2,2,1)
    plt.imshow(im)
    plt.axis('off')
    im = im*mask2[:,:,np.newaxis]

    a = fig.add_subplot(2,2,4)
    plt.imshow(im)
    plt.axis('off')
    plt.savefig(BBID + '_' + filename + '.png',bbox_inches='tight')


def prochm(im, hm, name):
    size = hm.shape

    ret,fgd = cv2.threshold(hm, 0.87, 1, cv2.THRESH_BINARY)
    fgd[1:size[0]/2] = 0
    fgd[1:size[0], 1:size[1]/4] = 0
    fgd[1:size[0], size[1]*3/4:size[1]] = 0

    ret,pr_fgd = cv2.threshold(hm, 0.8, 1, cv2.THRESH_BINARY)
    pr_fgd -= fgd

    ret, bgd = cv2.threshold(hm, 0.05, 1, cv2.THRESH_BINARY_INV)
    bgd[size[0]/3:size[0]] = 0

    ret,pr_bgd = cv2.threshold(hm, 0.8, 1, cv2.THRESH_BINARY_INV)
    pr_bgd -= bgd

    mask = cv2.GC_BGD * bgd + cv2.GC_FGD * fgd + cv2.GC_PR_BGD * pr_bgd + cv2.GC_PR_FGD * pr_fgd
    mask = mask.astype(np.uint8, copy=False)

    mmask = np.copy(mask)
    fig = plt.figure()
    a = fig.add_subplot(2,2,3)
    plt.imshow(mmask)
    plt.axis('off')

    bgdModel = np.zeros((1,65),np.float64)
    fgdModel = np.zeros((1,65),np.float64)

    rect = (0, im.shape[:2][0]/2, im.shape[:2][1], im.shape[:2][0])

    cv2.grabCut(im, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_MASK)

    mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')

    a = fig.add_subplot(2,2,1)
    plt.imshow(im)
    plt.axis('off')
    im = im*mask2[:,:,np.newaxis]

    a = fig.add_subplot(2,2,2)
    plt.imshow(hm)
    plt.axis('off')

    a = fig.add_subplot(2,2,4)
    plt.imshow(im)
    plt.axis('off')

    plt.savefig(name + '.png',bbox_inches='tight')


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

    ret,fgd = cv2.threshold(hm, 0.87, 1, cv2.THRESH_BINARY)
    fgd[1:size[0]/2] = 0
    fgd[1:size[0], 1:size[1]/4] = 0
    fgd[1:size[0], size[1]*3/4:size[1]] = 0

    ret,pr_fgd = cv2.threshold(hm, 0.8, 1, cv2.THRESH_BINARY)
    pr_fgd -= fgd

    ret, bgd = cv2.threshold(hm, 0.05, 1, cv2.THRESH_BINARY_INV)
    bgd[size[0]/3:size[0]] = 0

    ret,pr_bgd = cv2.threshold(hm, 0.8, 1, cv2.THRESH_BINARY_INV)
    pr_bgd -= bgd

    mask = cv2.GC_BGD * bgd + cv2.GC_FGD * fgd + cv2.GC_PR_BGD * pr_bgd + cv2.GC_PR_FGD * pr_fgd
    mask = mask.astype(np.uint8, copy=False)

    bgdModel = np.zeros((1,65),np.float64)
    fgdModel = np.zeros((1,65),np.float64)

    rect = (0, im.shape[:2][0]/2, im.shape[:2][1], im.shape[:2][0])
    cv2.grabCut(im, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_MASK)
    mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')

    return mask2


def imshow(im):
    plt.imshow(im),plt.colorbar(),plt.show()


def main():
    for i in range(0, 11):
        name = 'um_' + str(i).zfill(6)
        im = cv2.imread(BASE + 'data_road/testing/image/' + name + '.png')
        mat = sio.loadmat(BASE + 'patrick_test_hm/cnn_' + name + '_yRes.mat')
        mat = mat['yRes'].astype(np.float32, copy=False)
        prochm(im, mat, name)

    #readbb(BBFILE)

if __name__ == "__main__":
    main()