--[[
Copyright (c) 2014 Google Inc.
See LICENSE file for full terms of limited license.
]]

gd = require "gd"
require "lfs"

if not dqn then
    require "initenv"
end

local cmd = torch.CmdLine()
cmd:text()
cmd:text('Train Agent in Environment:')
cmd:text()
cmd:text('Options:')

cmd:option('-framework', '', 'name of training framework')
cmd:option('-env', '', 'name of environment to use')
cmd:option('-game_path', '', 'path to environment file (ROM)')
cmd:option('-env_params', '', 'string of environment parameters')
cmd:option('-pool_frms', '',
           'string of frame pooling parameters (e.g.: size=2,type="max")')
cmd:option('-actrep', 1, 'how many times to repeat action')
cmd:option('-random_starts', 0, 'play action 0 between 1 and random_starts ' ..
           'number of times at the start of each training episode')

cmd:option('-name', '', 'filename used for saving network and training history')
cmd:option('-network', '', 'reload pretrained network')
cmd:option('-agent', '', 'name of agent file to use')
cmd:option('-agent_params', '', 'string of agent parameters')
cmd:option('-seed', 1, 'fixed input seed for repeatable experiments')

cmd:option('-verbose', 2,
           'the higher the level, the more information is printed to screen')
cmd:option('-threads', 1, 'number of BLAS threads')
cmd:option('-gpu', -1, 'gpu flag')
cmd:option('-gif_file', '', 'GIF path to write session screens')
cmd:option('-csv_file', '', 'CSV path to write session data')

cmd:text()

local opt = cmd:parse(arg)

--- General setup.
local game_env, game_actions, agent, opt = setup(opt)

-- override print to always flush the output
local old_print = print
local print = function(...)
    old_print(...)
    io.flush()
end

-- file names from command line
local gif_filename = opt.gif_file
local gamename = opt.env

for i=0,12 do
    print("Start playing episode " .. i)
    -- start a new game
    local screen, reward, terminal = game_env:newGame()
    -- compress screen to JPEG with 100% quality
    local jpg = image.compressJPG(screen:squeeze(), 100)
    -- create gd image from JPEG string
    local im = gd.createFromJpegStr(jpg:storage():string())
    -- convert truecolor to palette
    im:trueColorToPalette(false, 256)
    -- write GIF header, use global palette and infinite looping
    im:gifAnimBegin(gif_filename, true, 0)
    -- write first frame
    -- im:gifAnimAdd(gif_filename, false, 0, 0, 7, gd.DISPOSAL_NONE)

    -- remember the image and show it first
    local previm = im
    -- local win = image.display({image=screen})
    lfs.mkdir(string.format("./%s/%04d", gamename, i))
    action_hist = {}
    reward_hist = {}
    life_hist = {}
    n = 0
    while not terminal do
        -- if action was chosen randomly, Q-value is 0
        agent.bestq = 0
        
        -- choose the best action
        local action_index = agent:perceive(reward, screen, terminal, true, 0.3)
        table.insert(action_hist, game_actions[action_index])

        -- play game in test mode (episodes don't end when losing a life)
        screen, reward, terminal = game_env:step(game_actions[action_index], false)
        table.insert(reward_hist, reward)
        table.insert(life_hist, game_env:getLives())

        -- save snapshot at time t not t+1
        imagename = string.format("./%s/%04d/%05d.png", gamename, i, n)
        im:png(imagename)

        -- display screen
        -- image.display({image=screen, win=win})

        -- create gd image from tensor
        jpg = image.compressJPG(screen:squeeze(), 100)
        im = gd.createFromJpegStr(jpg:storage():string())
        
        -- use palette from previous (first) image
        im:trueColorToPalette(false, 256)
        im:paletteCopy(previm)

        -- write new GIF frame, no local palette, starting from left-top, 7ms delay
        -- im:gifAnimAdd(gif_filename, false, 0, 0, 7, gd.DISPOSAL_NONE)
        -- remember previous screen for optimal compression
        previm = im
        n = n + 1
    end

    -- save actions and rewards
    local filename = string.format("./%s/%04d/act.log", gamename, i)
    local file, err = io.open(filename, "w")
    file:write(table.concat(action_hist, "\n"))
    file:close()

    local filename = string.format("./%s/%04d/reward.log", gamename, i)
    local file, err = io.open(filename, "w")
    file:write(table.concat(reward_hist, "\n"))
    file:close()

    local filename = string.format("./%s/%04d/life.log", gamename, i)
    local file, err = io.open(filename, "w")
    file:write(table.concat(life_hist, "\n"))
    file:close()
end

-- end GIF animation and close CSV file
--gd.gifAnimEnd(gif_filename)

print("Finished playing, close window to exit!")
