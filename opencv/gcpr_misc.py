#!/bin/python2.7

import numpy as np
import cv2
from matplotlib import pyplot as plt
import scipy.io as sio
import os


#CONSTANTS
BASE = '/home/morris/var/media/Elements/var/data/KITTI/'

def matDirToPng(path):
    print 'matDirToPng: ' + pat
    for i in os.listdir(path):
        if i.endswith(".mat"):
            filename = i[:-4]
            print filename
            mat = sio.loadmat(path + i)
            mat = mat['yRes'].astype(np.float32, copy=False)
            cv2.imwrite(path + filename + '.png', 255 * mat)

def addHeatMaps(idir, hdir):
    print 'addHeatMaps: ' + hdir
    for i in os.listdir(hdir):
        if i.endswith(".png") and not i.endswith("_overlay.png"):
            filename = i[:-4]
            print filename
            heatmap = cv2.imread(hdir + i)
            image = cv2.imread(idir + i)

            heatmap_jet = cv2.applyColorMap(heatmap, cv2.COLORMAP_WINTER)
            heatmap = heatmap/255

            for c in range(0,3):
                #image[:,:,c] = image[:,:,c] + (0.1 + 0.9* heatmap[:,:,c]) * heatmap_jet[:,:,c]
                image[:, :, c] = heatmap_jet[:,:,c] +  np.multiply(image[:,:, c] , (1.0 - heatmap[:,:,c]))
            cv2.imwrite(hdir + filename + '_overlay.png', image)

def main():
    resdir = BASE + 'validation_svm/predictions/'

    grabdir = BASE + 'validation_svm/grabcut/'
    grabaodir = BASE + 'validation_svm/grabcut_ao/'
    grabcutdir = BASE + 'validation_svm/grabcut_cut/'
    grablccdir = BASE + 'validation_svm/grabcut_lcc/'

    imdir = BASE + 'data_road/training/image/'

    addHeatMaps(imdir, resdir)
    addHeatMaps(imdir, grabdir)
    addHeatMaps(imdir, grabaodir)
    addHeatMaps(imdir, grabcutdir)
    addHeatMaps(imdir, grablccdir)
   # matDirToPng(resdir)



if __name__ == "__main__":
    main()
