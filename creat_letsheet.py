#!/usr/bin/env python3 
import os, sys, string
from PIL import Image, ImageDraw, ImageFont, ImageOps 
spritesheet = Image.new("1", (273, 10), color=0)
fnt = ImageFont.truetype("Monaco.ttf", 13)
d = ImageDraw.Draw(spritesheet)
lpos = 0
for let in string.digits + string.ascii_uppercase + "$.":
    d.text((lpos- 1,-1), let, font=fnt, fill=1)
    lpos += 7
spritesheet_rsz = spritesheet.resize((380, 20))
with open("spritesheet.png", "wb") as ss_png:
    spritesheet.save(ss_png, "PNG")
data = bytes(spritesheet.getdata())

packed = [] # of bytes
shft=0
byte=0
coe = open("letters.coe", "w")
coe.write("memory_initialization_radix = 16;\nmemory_initialization_vector = ")
for i in range(len(data)):
    if (i%7)==0 and i!=0:
        packed.append(format(byte, "02x"))
        byte=0
    byte+=(data[i]<<(6-(i%7)))

coe.write(", ".join(packed))
coe.close() 

spritesheet = Image.new("1", (640, 480), color=0)
fnt = ImageFont.truetype("Monaco.ttf", 72)
d = ImageDraw.Draw(spritesheet)
spritesheet_mr = ImageOps.mirror(spritesheet)
d.text((10,10), "ARCHEL RISC MACHINE", font=fnt, fill=1)
with open("base.png", "wb") as vga_base:
    spritesheet.save(vga_base, "PNG")
data = bytes(spritesheet_mr.getdata())
with open("vga_coe.coe", "w") as vga_coe:
    vga_coe.write("memory_initialization_radix=16;\nmemory_initialization_vector = ")
    packed = [] 
    shft = 0
    byte = 0
    for i in range(len(data)):
        if (i%640)==0 and i!=0:
            packed.append(format(byte, "02x"))
            byte=0
        byte+=(data[i]<<(639-(i%640)))
    vga_coe.write(", ".join(packed))



