#!/bin/python2.7

import numpy as np
import cv2
from matplotlib import pyplot as plt
import scipy.io as sio
import os


#CONSTANTS
BASE = '/home/morris/var/media/Elements/var/data/KITTI/data_road/'

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
            if heatmap.shape != image.shape:
                print 'Shape not equal'
                continue

            heatmap_jet = cv2.applyColorMap(heatmap, cv2.COLORMAP_WINTER)
            heatmap = heatmap/255

            for c in range(0,3):
                #image[:,:,c] = image[:,:,c] + (0.1 + 0.9* heatmap[:,:,c]) * heatmap_jet[:,:,c]
                image[:, :, c] = heatmap_jet[:,:,c] +  np.multiply(image[:,:, c] , (1.0 - heatmap[:,:,c]))
            cv2.imwrite(hdir + filename + '_overlay.png', image)

def main():
    resdir = BASE + 'LibLinear_Results/training/predictions/'
    grabdir = BASE + 'LibLinear_Results/training/grabcut_5_4_5/ao/cut/'

    imdir = BASE + 'training/image/'

    addHeatMaps(imdir, grabdir)
   # matDirToPng(resdir)



if __name__ == "__main__":
    main()
