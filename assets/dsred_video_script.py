import os
from pymol import cmd

def produce_frame():
    name = '/tmp/frame.png'
    cmd.png(name, ray=True, width=1920, height=1080)
    with open(name, 'rb') as frame:
        os.write(produce_frame.pipe, frame.read())
    os.remove(name)

produce_frame.pipe = os.open('my_pipe', os.O_WRONLY)

#Rotate 90 degrees in x over 90 frames
for i in range(90):
    cmd.turn('x', 1)
    produce_frame()

#Rotate 360 degrees in y over 360 frames
for i in range(360):
    cmd.turn('y', 1)
    produce_frame()

#Rotate -90 degrees in x over 90 frames
for i in range(90):
    cmd.turn('x', -1)
    produce_frame()

os.close(produce_frame.pipe)
