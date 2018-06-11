#!/usr/bin/env python3 
import os, sys, string
from PIL import Image, ImageDraw, ImageFont, ImageOps 
#bg = Image.open("bg.xbm")
#data = bytes(bg.getdata())
#with open("bg_coe.coe", "w") as bg_coe:
#    bg_coe.write("memory_initialization_radix=16;\nmemory_initialization_vector = ")
#    packed = [] 
#    shft = 0
#    byte = 0
#    for i in range(len(data)):
#        if (i%640)==0 and i!=0:
#            packed.append(format(byte, "02x"))
#           byte=0
#       byte+=((1 if data[i] == 0 else 0)<<(639-(i%640)))
#    bg_coe.write(", ".join(packed))
spritesheet = Image.new("1", (273, 10), color=0)
fnt = ImageFont.truetype("Monaco.ttf", 13)
d = ImageDraw.Draw(spritesheet)
lpos = 0
for let in string.digits + string.ascii_uppercase + "$.":
    d.text((lpos- 1,-1), let, font=fnt, fill=1)
    lpos += 7
with open("spritesheet.png", "wb") as ss_png:
    spritesheet.save(ss_png, "PNG")
data = bytes(spritesheet.getdata())

packed = [] # of bytes
shft=0
byte=0
m = open("spritesheet_bits.txt", "w")
coe = open("letters.coe", "w")
coe.write("memory_initialization_radix = 16;\nmemory_initialization_vector = ")
for i in range(len(data)):
    if (i%7)==0 and i!=0:
        packed.append(format(byte, "02x"))
        byte=0
        m.write(" ")
    if (i)%(39*7) == 0:
        m.write("\n")
    byte+=(data[i]<<(6-(i%7)))
    m.write(" " + format(data[i],"d"))

coe.write(", ".join(packed))
coe.write(", 00")
coe.close() 

m.close()

spritesheet = Image.new("1", (640, 480), color=0)
monaco_36 = ImageFont.truetype("Monaco.ttf", 36)
monaco_24 = ImageFont.truetype("Monaco.ttf", 24)
monaco_13 = ImageFont.truetype("Monaco.ttf", 13)
d = ImageDraw.Draw(spritesheet)
#spritesheet_mr = ImageOps.mirror(spritesheet)
d.text((10,10), "ARCHEL RISC MACHINE", font=monaco_36, fill=1)

d.text((5, 50), "IF", font=monaco_24, fill=1)
d.text((135, 50), "ID", font=monaco_24, fill=1)
d.text((270, 50), "EXE", font=monaco_24, fill=1)
d.text((405, 50), "MEM", font=monaco_24, fill=1)
d.text((540, 50), "WB", font=monaco_24, fill=1)

#arrow is 3 lines
# line starts at the end of the previous polygon and ends at the next polygon

# REGS->IF
d.line([(505,345),(505,335), (25,335), (25,230)], fill=1, width=2)
d.line([(20,235), (25,230), (30,235)], fill=1, width=2)
d.rectangle([(5,130),(105,230)], fill=1)
d.text((10,140), "IM", font=monaco_24, fill=0)

# IF->ID
d.line([(105,135), (125,135)], fill=1, width=2)
d.line([(120,130), (125,135), (120,140)], fill=1, width=2)

# REGS->ID
d.line([(145,230), (145,335)], fill=1, width=2)
d.line([(140, 235), (145,230), (150,235)], fill=1, width=2)
d.rectangle([(125,130),(225,230)], fill=1)
d.text((135,140), "REG", font=monaco_24, fill=0)

# ID->EX
d.line([(225,135), (245,135)], fill=1, width=2)
d.line([(240,130),(245,135),(240,140)], fill=1, width=2)


d.polygon([(245,130), (320, 166), (320,197), (245,230), (245,190), (250,180), (245,170)], fill=1)

# EX->MEM
d.line([(320,181), (365,181)], fill=1, width=2)
d.line([(360,176),(365,181), (360,186)], fill=1, width=2)


d.rectangle([(365,130),(465,230)], fill=1)
d.text((375,140), "DM", font=monaco_24, fill=0)

d.line([(465,135),(485,135)], fill=1, width=2)
d.line([(480,130),(485,135), (480,140)], fill=1, width=2)

# MEM->REGS
# MEM->WB
d.rectangle([(485,130),(585,230)], fill=1)
d.text((495,140), "REG", font=monaco_24, fill=0)
d.line([(515,230), (515,345)], fill=1, width=2)
d.line([(510,340), (515,345), (520,340)], fill=1, width=2) 


#d.line([(60,140),
with open("bg.png", "wb") as vga_base:
    spritesheet.save(vga_base, "PNG")
data = bytes(spritesheet.getdata())
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
