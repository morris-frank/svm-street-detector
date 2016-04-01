#!/usr/bin/env python
#
#  THE KITTI VISION BENCHMARK SUITE: ROAD BENCHMARK
#
#  File: simpleExample_transformTestResults2BEV.py
#
#  Copyright (C) 2013
#  Honda Research Institute Europe GmbH
#  Carl-Legien-Str. 30
#  63073 Offenbach/Main
#  Germany
#
#  UNPUBLISHED PROPRIETARY MATERIAL.
#  ALL RIGHTS RESERVED.
#
#  Authors: Tobias Kuehnl <tkuehnl@cor-lab.uni-bielefeld.de>
#           Jannik Fritsch <jannik.fritsch@honda-ri.de>
#

import os, sys
import computingPipeline, transform2BEV

#########################################################################
# test script to process testing data in perspective domain and 
# transform the results to the metric BEV 
#########################################################################

if __name__ == "__main__":
    
    calib = '/home/morris/var/media/Elements/var/data/KITTI/data_road/training/calib/'
    outputDir = '/home/morris/var/media/Elements/var/data/KITTI/validation_svm/predictions/'
    outputDir_bev = '/home/morris/var/media/Elements/var/data/KITTI/validation_svm/obev/'
    
    # Convert baseline in perspective space into BEV space
    # If your algorithm provides results in perspective space,
    # you need to run this script before submission!
    inputFiles = os.path.join(outputDir, '*.png')
    transform2BEV.main(inputFiles, calib, outputDir_bev)

    # now zip the contents in the directory 'outputDir_bev' and upload
    # the zip file to the KITTI server


    
