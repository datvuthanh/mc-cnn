#!/usr/bin/env luajit

require 'image'
require 'nn'
require 'cutorch'
require 'libadcensus'

nchannel = 3
img_0 = image.loadPNG('/home/ailab/Downloads/data/mid2005/Books/view1.png', nchannel, 'byte'):float()
img_1 = image.loadPNG('/home/ailab/Downloads/data/mid2005/Books/view5.png', nchannel, 'byte'):float()

img_0 = image.rgb2y(img_0)
img_1 = image.rgb2y(img_1)

print("IM 0 " ,img_0)
-- preprocess
print("DANG NORMALIZE")
img_0:add(-img_0:mean()):div(img_0:std())
img_1:add(-img_1:mean()):div(img_1:std())

--print("IMG0 nor",img_0)