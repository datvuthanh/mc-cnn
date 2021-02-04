#! /usr/bin/env luajit

require 'torch'
require 'cutorch'
require 'lfs'

path = '/home/ailab/Desktop/RectificationToolkit/bins_bk/2011_09_26_drive_0001_sync_[180598 2 9 9].bin'

--left = torch.FloatTensor(torch.FloatStorage(path)):view(180598,2,9,9)

-- s = 180598 * 2 * 9 * 9
-- left = torch.FloatTensor(torch.FloatStorage(s))
-- torch.DiskFile(path,'r'):binary():readFloat(left:storage())


-- function fromfile(fname)
--     local size = io.open(fname):seek('end')
--     local x = torch.FloatTensor(torch.FloatStorage(fname, false, size / 4))
--     local nan_mask = x:ne(x)
--     x[nan_mask] = 1e38
--     return x
--  end


-- left = fromfile(path):view(180598, 2, 9,9 )


-- s = 180598 * 2 * 9 * 9



-- print(left[13][1])
firstIter = true
for file in lfs.dir[[/home/ailab/Desktop/RectificationToolkit/bins_bk]] do
    --print(file)
    if string.find(file, ".bin") then
        --print(file)
        -- processing line
        word = file:match("%[(.-)%]")
        --print(word)
        s = 1
        for token in string.gmatch(word, "[^%s]+") do
            --print(token)
            s = s * tonumber(token)
         end
        --print("S: ",s)
         -- Load file bin here
        path = '/home/ailab/Desktop/RectificationToolkit/bins_bk/' .. file
        tensor = torch.FloatTensor(torch.FloatStorage(s))
        torch.DiskFile(path,'r'):binary():readFloat(tensor:storage())
        tensor = tensor:view(s/162, 2, 9, 9)--:cuda()
        --print(tensor[153][1])
        if firstIter == true then
            ctensor = tensor
            firstIter = false
        else
            ctensor = torch.cat(ctensor,tensor,1)
        end
    end
end

--print(ctensor:size())