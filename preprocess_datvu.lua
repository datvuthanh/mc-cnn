#! /usr/bin/env luajit

require 'torch'
require 'image'
npy4th = require 'npy4th'
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

count = 1
for file in lfs.dir[[/home/ailab/Desktop/utils/npy]] do
   print(file)
   if string.find(file, ".npy") then
      tensor = npy4th.loadnpy('/home/ailab/Desktop/utils/npy/' .. file)
      x0 = torch.FloatTensor(tensor:size(1), 1, 9, 9):zero()
      x1 = torch.FloatTensor(tensor:size(1), 1, 9, 9):zero()
      x2 = torch.FloatTensor(tensor:size(1), 1, 9, 9):zero()

      zeros = torch.FloatTensor(1, 9, 9):zero()
      print ("The file .npy was found.",tensor:size(1),x0:size(1))
      -- f = torch.FloatTensor(tensor:size(1)*3, 1, 9, 9):zero()

      for i = 1, tensor:size(1) do
   
          --print(i)
          rand = math.random(1,tensor:size(1))
          left_pos = tensor[i][1]:float()
          right_pos = tensor[i][2]:float()
          left_neg = tensor[i][1]:float()
          right_neg = tensor[rand][2]:float()

          -- Transpose to (channel,height,width)

          left_pos = left_pos:transpose(3,1,2)
          right_pos = right_pos:transpose(3,1,2)
          left_neg = left_neg:transpose(3,1,2)
          right_neg = right_neg:transpose(3,1,2)
   
          -- Convert to grayscale
          left_pos = image.rgb2y(left_pos)
          right_pos = image.rgb2y(right_pos)
          left_neg = image.rgb2y(left_neg)
          right_neg = image.rgb2y(right_neg)
          
          -- Normalization
          left_pos:add(-left_pos:mean()):div(left_pos:std())
          right_pos:add(-right_pos:mean()):div(right_pos:std())
          left_neg:add(-left_neg:mean()):div(left_neg:std())
          right_neg:add(-right_neg:mean()):div(right_neg:std())
      
          -- Insert to Tensor
         --  f[{i,{}}]:copy(left_pos)
         --  f[{i+1,{}}]:copy(right_pos)
         --  f[{i+2,{}}]:copy(left_neg)
         --  f[{i+3,{}}]:copy(right_neg)

         -- if left_pos != left_pos then
         --    print("NAN")
         -- end
         a = torch.equal(left_pos,left_pos)
         b = torch.equal(right_pos,right_pos)
         c = torch.equal(right_neg,right_neg)

         -- if c == false then
         --    right_neg = tensor[rand][2]:float()
         --    right_neg = image.rgb2y(right_neg)
         --    print(right_neg)

         --    right_neg:add(-right_neg:mean()):div(right_neg:std())

         --    print(right_neg)
         -- end

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
         x0[{i,{}}]:copy(left_pos)
         x1[{i,{}}]:copy(right_pos)
         x2[{i,{}}]:copy(right_neg)

         
      end      
      path = 'data.patch9x9'
      --filename = string.sub(file, 7, 9)
      --print("COUNT: ",count)
      os.execute(('rm -f %s/*.{bin,dim,type}'):format(path))
      tofile(('%s/leftpos_%d.bin'):format(path,count), x0)
      tofile(('%s/rightpos_%d.bin'):format(path,count), x1)
      tofile(('%s/rightneg_%d.bin'):format(path,count), x2)
      -- tofile(('%s/f_%d.bin'):format(path,count), f)

      count = count + 1
    else
      print ("The word .npy was not found.")
    end
end
