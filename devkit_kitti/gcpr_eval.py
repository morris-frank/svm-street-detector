#!/usr/bin/env python
#
#  THE KITTI VISION BENCHMARK SUITE: ROAD BENCHMARK
#
#  File: simpleExample_evalTrainResults.py
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
import computeBaseline, evaluateRoad

#########################################################################
# test script to evaluate training data in perspective domain
#########################################################################

if __name__ == "__main__":
    
    datasetDir = '/home/morris/var/media/Elements/var/data/KITTI/data_road/training/'
    outputDir = '/home/morris/var/media/Elements/var/data/KITTI/validation_svm/grabcut_lcc/'
    
    # Toy example running evaluation on perspective train data
    # Final evaluation on server is done in BEV space and uses a 'valid_map'
    # indicating the BEV areas that are invalid
    # (no correspondence in perspective space)
    evaluateRoad.main(outputDir, datasetDir)
