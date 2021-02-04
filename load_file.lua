#! /usr/bin/env luajit

require 'torch'
require 'cutorch'
require 'lfs'


math.randomseed(os.time()) -- random initialize
math.random(); math.random(); math.random() -- warming up

function tofile(fname, x)
   tfile = torch.DiskFile(fname .. '.type', 'w')
   if x:type() == 'torch.FloatTensor' then
      
      tfile:writeString('float32')
      torch.DiskFile(fname, 'w'):binary():writeFloat(x:storage())
   elseif x:type() == 'torch.LongTensor' then
      tfile:writeString('int64')
      torch.DiskFile(fname, 'w'):binary():writeLong(x:storage())
   elseif x:type() == 'torch.IntTensor' then
      tfile:writeString('int32')
      torch.DiskFile(fname, 'w'):binary():writeInt(x:storage())
   end
   dimfile = torch.DiskFile(fname .. '.dim', 'w')
   for i = 1,x:dim() do
      dimfile:writeString(('%d\n'):format(x:size(i)))
   end
end

path = '/home/ailab/Desktop/RectificationToolkit/bins_bk/2011_09_26_drive_0001_sync_[180598 2 9 9].bin'

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

print(ctensor:size())


x0 = torch.FloatTensor(ctensor:size(1), 1, 9, 9):zero()
x1 = torch.FloatTensor(ctensor:size(1), 1, 9, 9):zero()
x2 = torch.FloatTensor(ctensor:size(1), 1, 9, 9):zero()

zeros = torch.FloatTensor(1, 9, 9):zero()
print ("The file .bin was found.",ctensor:size(1),x0:size(1))
-- f = torch.FloatTensor(tensor:size(1)*3, 1, 9, 9):zero()

for i = 1, ctensor:size(1) do

    --print(i)
    rand = math.random(1,ctensor:size(1))
    left_pos = ctensor[i][1]:float()
    right_pos = ctensor[i][2]:float()
    left_neg = ctensor[i][1]:float()
    right_neg = ctensor[rand][2]:float()

    a = torch.equal(left_pos,left_pos)
    b = torch.equal(right_pos,right_pos)
    c = torch.equal(right_neg,right_neg)


   -- Check Nans if a or b or c == False
   if a == false then
      left_pos[{}] = zeros[{}]
   end
   if b == false then
      right_pos[{}] = zeros[{}]
   end
   if c == false then
      right_neg[{}] = zeros[{}]
   end                  
   -- New
   x0[{i,1,{}}]:copy(left_pos)
   x1[{i,1,{}}]:copy(right_pos)
   x2[{i,1,{}}]:copy(right_neg)

   
end      
-- print(x0[12])
path = 'data.bins'
--filename = string.sub(file, 7, 9)
--print("COUNT: ",count)
os.execute(('rm -f %s/*.{bin,dim,type}'):format(path))
tofile(('%s/leftpos_%d.bin'):format(path,1), x0)
tofile(('%s/rightpos_%d.bin'):format(path,1), x1)
tofile(('%s/rightneg_%d.bin'):format(path,1), x2)
-- -- tofile(('%s/f_%d.bin'):format(path,count), f)