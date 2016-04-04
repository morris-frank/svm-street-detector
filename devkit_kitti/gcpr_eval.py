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

import os
import sys
import evaluateRoad


#########################################################################
# test script to evaluate training data in perspective domain
#########################################################################
def main(argv):
    seq = argv[0]

    print seq
    datasetDir = '/home/morris/var/media/Elements/var/data/KITTI/data_road/training/'
    outputDir = '/home/morris/var/media/Elements/var/data/KITTI/data_road/LibLinear_Results/' + seq + '/grabcut_' + argv[1] + '_' + argv[2] + '_' + argv[3] + '/'
    evaluateRoad.main(outputDir, datasetDir)


if __name__ == "__main__":
    main(sys.argv[1:])