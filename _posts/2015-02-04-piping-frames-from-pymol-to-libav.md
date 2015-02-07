---
layout: post
title: Piping frames from PyMOL to Libav
---

A standard workflow for generating movies with Libav and PyMOL begins with some
preparation of a PyMOL session and/or a script to generate image frames. These
images will later be stitched together into a video using Libav (formerly
ffmpeg).

Suppose you're planning on making 2 minutes of video to visualize your
molecule of choice. You'd like it to look nice on a presentation screen during
your next talk so you decide to make images 1920 by 1080 pixels. Given 30 frames
per second of video and ~1MB per frame image, you are looking at accumulating
~3.6GB of image files which you'll probably have no use for after generating the
video.

This unnecessary disk space consumption annoyed me enough the other day that I
decided to develop a way to work around it. My solution was to use a UNIX named
pipe as a means of input for `avconv`, meanwhile adjusting my rendering script
to pass each image frame into the pipe as they were produced by PyMOL. Hopefully
some others may find this technique interesting, and what I'll illustrate below
applies very broadly.

## A worked example with dsRed

dsRed is a protein found in coral which fluoresces red in the visible spectrum
and forms a homotetramer.
[PDB: 1G7K](http://www.rcsb.org/pdb/explore/explore.do?structureId=1g7k). To get
started, I've [prepared a PyMOL session](assets/dsred.pse) in which preliminary
work has been done and rendering settings have been configured. When loaded it
should present you with the following view:

![dsRed tetramer](/assets/dsred.png)

Here's a script to produce a pre-view video of dsRed with simple actions: tip,
spin, un-tip. We'll build off of this simple foundation.
    
{% highlight python %}
from pymol import cmd

def produce_frame():
    name = 'frame{0:03d}.png'.format(produce_frame.frame_count)
    cmd.png(name, ray=True, width=400, height=300)
    produce_frame.frame_count += 1

produce_frame.frame_count = 0

#Rotate 90 degrees in x over 18 frames
for i in range(18):
    cmd.turn('x', 5)
    produce_frame()

#Rotate 360 degrees in y over 72 frames
for i in range(72):
    cmd.turn('y', 5)
    produce_frame()

#Rotate -90 degrees in x over 18 frames
for i in range(18):
    cmd.turn('x', -5)
    produce_frame()
{% endhighlight %}

Running this script from our PyMOL session should generate 108 different frame
image files. Now we stitch these low resolution images into a video
with the following command:

{% highlight bash %}
avconv -i frame%03d.png -r 30 low_res.mp4
{% endhighlight %}

You should see ~9MB of images become ~500KB of video.

*I was going to use HTML5 video to nicely display the videos provided in this
post, but I haven't worked out the details yet since GitHub Pages doesn't allow
plugins. So for the meantime: [here is the video](/assets/dsred_low_res.mp4).*

Once ready to commit our time and computing to doing a full scale
render, we might use an updated script for
generating higher resolution frames with smoother/slower rotations:

{% highlight python %}
from pymol import cmd

def produce_frame():
    name = 'frame{0:03d}.png'.format(produce_frame.frame_count)
    cmd.png(name, ray=True, width=1920, height=1080)
    produce_frame.frame_count += 1

produce_frame.frame_count = 0

#Rotate 90 degrees in x over 90 frames, 3 seconds
for i in range(90):
    cmd.turn('x', 1)
    produce_frame()

#Rotate 360 degrees in y over 360 frames, 12 seconds
for i in range(360):
    cmd.turn('y', 1)
    produce_frame()

#Rotate -90 degrees in x over 90 frames, 3 seconds
for i in range(90):
    cmd.turn('x', -1)
    produce_frame()
{% endhighlight %}

Assuming that each frame will average ~1MB, these frames will consume ~540MB
for 18 seconds of video. Certainly this is just an annoyance on most systems,
but it could lead to true scaling problems for longer videos. So let's now
introduce piped input as a way to avoid it.

In a terminal window, create a named UNIX pipe and set `avconv` to use this pipe
as its input stream with the following:

{% highlight bash %}
mkfifo my_pipe
avconv -f image2pipe -c:v png -i my_pipe -r 30 low_res_piped.mp4
{% endhighlight %}

Note that I have explicitly set the input format to `image2pipe` so that it
expects a series of images to come through the pipe, and the decoding for the
input to be `png`, as these things can't be inferred by the program. Now for a
short test.

In a separate terminal window, execute the following command to send all of your
low resolution frames into the pipe on which `avconv` is listening.

{% highlight bash %}
cat *.png > my_pipe
{% endhighlight %}

This basically just recapitulated our previous encoding workflow in a piped
form. One thing to be aware of is that whenever the pipe is closed, `avconv`
will receive that indication and stop reading the pipe. So if for instance we
wanted to loop our video twice with this workflow, this would do so:

{% highlight bash %}
cat *.png *.png > my_pipe
{% endhighlight %}

while this would only yield one loop:

{% highlight bash %}
cat *.png > my_pipe; cat *.png > my_pipe
{% endhighlight %}

Here's one last iteration on the script, adapting it for use with pipes.
Prior to the script's execution, `avconv` must be set to
listen to the pipe; 
`avconv -f image2pipe -c:v png -i my_pipe -r 30 output.mp4`.

{% highlight python %}
import os
from pymol import cmd

def produce_frame():
    name = '/tmp/frame.png'
    cmd.png(name, ray=True, width=1920, height=1080)
    with open(name, 'rb') as frame:
        os.write(produce_frame.pipe, frame.read())
    os.remove(name)

produce_frame.pipe = os.open('my_pipe', os.O_WRONLY)

#Rotate 90 degrees in x over 90 frames, 3 seconds
for i in range(90):
    cmd.turn('x', 1)
    produce_frame()

#Rotate 360 degrees in y over 360 frames, 12 seconds
for i in range(360):
    cmd.turn('y', 1)
    produce_frame()

#Rotate -90 degrees in x over 90 frames, 3 seconds
for i in range(90):
    cmd.turn('x', -1)
    produce_frame()

os.close(produce_frame.pipe)
{% endhighlight %}

[Script file](/assets/dsred_video_script.py)

Executing this script will result in generated frames being passed immediately
into `avconv` for encoding and they will not accumulate on the hard disk. Since
the video encoding is being done simultaneously with the rendering, it should
also complete nearly simultaneously.

*I'll update this post tomorrow with a link to the full resolution video output*

### Acknowledging some roughness

I readily dmit that there is one notable disappointment in my technique, which
is that it uses twice the file I/O. I believe the time cost of this is rather
miniscule in comparison to all that spent ray-tracing however. Ultimately,
this is due to the use of the of the standard PyMOL `cmd.png` method. I haven't
studied the PyMOL source enough to know how best to provide a new pipe-friendly
method for producing the PNG files, perhaps that may be a subject for the
future.