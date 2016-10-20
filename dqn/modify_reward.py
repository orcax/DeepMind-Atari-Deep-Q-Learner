#!/usr/bin/python
import glob
import os
import os.path

def modify(act_file, act_idx_file, act_map):
    print act_file
    acts = []
    with open(act_file, 'r') as f:
        acts = [int(l.strip()) for l in f.readlines()]
    if not act_map:
        act_key = sorted(list(set(acts)))
        act_val = range(len(act_key))
        act_map = dict(zip(act_key, act_val))
    with open(act_idx_file, 'w') as f:
        f.writelines([str(act_map[a])+'\n' for a in acts])
    return act_map

def main():
    games = ['breakout']
    for game in games:
        act_map = {}
        train_dirs = glob.glob('./' + game + '/train/*')
        test_dirs = glob.glob('./' + game + '/test/*')
        dirs = train_dirs + test_dirs
        for d in dirs:
            act_file = d + '/act.log'
            act_idx_file = d + '/act_idx.log'
            if not os.path.exists(act_file):
                continue
            act_map = modify(act_file, act_idx_file, act_map)

        with open('./' + game + '/act_map.log', 'w') as f:
            tmp = [(act_map[a], a) for a in act_map]
            tmp = sorted(tmp, key=lambda x:x[0])
            for i in range(len(tmp)):
                line = str(tmp[i][0]) + ',' + str(tmp[i][1]) + '\n'
                f.write(line)


if __name__ == '__main__':
    main()
