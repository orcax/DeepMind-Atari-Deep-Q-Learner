#!/usr/bin/python
import glob
import os
import os.path
import sys
import cv2
import numpy as np
sys.path.append('/home/yikun/Workspaces/nips2015-action-conditional-video-prediction/caffe/python')
import caffe
from caffe.io import array_to_blobproto

def create_act_idx(data_dir):
    print 'create action index...'
    act_map = {}
    for d in glob.glob(data_dir + '/*'):
        act_file = d + '/act.log'
        act_idx_file = d + '/act_idx.log'
        if not os.path.exists(act_file):
            continue
        acts = []
        with open(act_file, 'r') as f:
            acts = [int(l.strip()) for l in f.readlines()]
        act_key = sorted(list(set(acts)))
        act_val = range(len(act_key))
        for i in range(len(act_key)):
            act_map[act_key[i]] = act_val[i]
        with open(act_idx_file, 'w') as f:
            f.writelines([str(act_map[a])+'\n' for a in acts])

    with open(data_dir + '/act_map.log', 'w') as f:
        tmp = [(act_map[a], a) for a in act_map]
        tmp = sorted(tmp, key=lambda x:x[0])
        for i in range(len(tmp)):
            line = str(tmp[i][0]) + ',' + str(tmp[i][1]) + '\n'
            f.write(line)

def compute_mean(data_dir):
    print 'compute mean file...'
    sumfile = np.zeros((210, 160, 3), dtype=np.float)
    count = 0
    for d in glob.glob(data_dir + '/*'):
        for im in glob.glob(d + '/*.png'):
            im = cv2.imread(im, cv2.IMREAD_COLOR)
            sumfile += im
            count += 1

    meanfile = sumfile / count
    np.save(data_dir + '/mean.npy', meanfile)
    cv2.imwrite(data_dir + '/mean.png', meanfile)

    meanblob = np.zeros((1, 3, 210, 160), dtype=np.float)
    meanblob[0,:] = meanfile.transpose((2,0,1))
    meanblob = array_to_blobproto(meanblob)
    with open(data_dir + '/mean.binaryproto', 'wb') as f:
        f.write(meanblob.SerializeToString())
    # [Tips] How to convert string to blob?
    # from caffe.proto import caffe_pb2
    # blob = caffe_pb2.BlobProto()
    # blob.ParseFromString(string)

def main():
    assert len(sys.argv) > 1
    game = sys.argv[1]
    create_act_idx('./%s/train' % game)
    create_act_idx('./%s/test' % game)
    compute_mean('./%s/train' % game)

if __name__ == '__main__':
    main()
