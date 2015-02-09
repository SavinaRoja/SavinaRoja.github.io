---
layout: post
title: Piping frames from PyMOL to Libav
---

This post explains how to combine use of piped input for the Libav `avconv`
program with a separate program generating frame data; one advantage of which is
that video may be encoded as frames are generated without accumulating (perhaps
extremely large) frame data. I'll be illustrating it with a basic example using
molecular visualization software PyMOL though the technique is quite general.

It is my intention that this post be accessible to beginners
(PyMOL/Python/Libav).

A common workflow for those generating movies from molecular visualization
programs such as PyMOL is to script the creation of video frames in one step
followed by conversion of frames to video with Libav in a subsequent step.

One downside to this process is that keeping each individual frame on disk may
be problematic. 2 minutes worth of 1920px1080p image frames can readily weigh in
at ~3GB.

One way to work around this is to pipe the frames into `avconv` as they are
created and discarding them instead of accumulating them.

## A worked example with dsRed

For this post's example molecule I chose dsRed. dsRed is a coral protein which
fluoresces red in the visible spectrum. In [PDB: 1G7K](http://www.rcsb.org/pdb/explore/explore.do?structureId=1g7k)
we see it crystallized in its homotetrameric state.

To keep the scripts simple, I did all of my configuration in the
[prepared PyMOL session](assets/dsred.pse). Here's the view upon initialization:

![dsRed tetramer](/assets/dsred.png)

The following script produces a small number of low resolution frames meant to
provide a pre-view of the video's action:
    
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

We can stitch these low resolution images into a video with the following:

{% highlight bash %}
avconv -i frame%03d.png low_res.mp4
{% endhighlight %}

This is [the result](/assets/dsred_low_res.mp4).

When ready to commit the time to a full render, the script is then updated for
appropriate number of frames and resolution:

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

Now let's do a quick test of the piped input using our preview frame images. In
a terminal window, create a named UNIX pipe and set `avconv` to use this pipe as
its input, like so:

{% highlight bash %}
mkfifo my_pipe
avconv -f image2pipe -c:v png -i my_pipe low_res_piped.mp4
{% endhighlight %}

I have explicitly set the input format to `image2pipe` and the decoder to `png`,
as these things cannot be inferred in this context.

In a separate terminal window, execute the following command to send all of your
low resolution frames into the pipe on which `avconv` is listening.

{% highlight bash %}
cat *.png > my_pipe
{% endhighlight %}

This is the piped form of the workflow. **Notes:** `avconv` will listen until
indicated to stop or close. So if for instance we wanted to loop our video
twice with this workflow, this would do so:

{% highlight bash %}
cat *.png *.png > my_pipe
{% endhighlight %}

while this would only yield one loop:

{% highlight bash %}
cat *.png > my_pipe; cat *.png > my_pipe
{% endhighlight %}

The script is thus adapted for use with pipes.
Prior to the script's execution, `avconv` must be set to
listen to the pipe; 
`avconv -f image2pipe -c:v png -i my_pipe dsred_high_res.mp4`.

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
into `avconv` for encoding. Video encoding is also encoded simultaneously and
will conclude immediately after the frames are done being created andthe pipe is
closed. [Here's the full size render](/assets/dsred_high_res.mp4).

### Acknowledging some roughness

The script as presented for PyMOL results in double the file IO when adapted for
pipes. This is due to the use of the of the standard PyMOL `cmd.png` method. I
haven't studied the PyMOL source enough to know how best to provide a new 
pipe-friendly method for producing the PNG files, perhaps that may be a subject
for the future.