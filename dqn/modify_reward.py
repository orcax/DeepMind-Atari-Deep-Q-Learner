#!/usr/bin/python
import glob
import os

def modify(filename):
    oldname = filename + '.bak'
    os.rename(filename, oldname)
    actions = []
    with open(oldname) as f:
        actions = [int(l.strip())-1 for l in f.readlines()]
    with open(filename, 'w') as f:
        f.writelines([str(a)+'\n' for a in actions])

def main():
    games = ['breakout', 'enduro', 'pong', 'seaquest']
    for game in games:
        dirs = glob.glob('./' + game + '/test/*')
        for d in dirs:
            print d
            modify(d + '/act.log')

if __name__ == '__main__':
    main()
