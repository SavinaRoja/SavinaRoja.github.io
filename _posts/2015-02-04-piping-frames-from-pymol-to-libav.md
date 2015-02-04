---
layout: post
title: Piping frames from PyMOL to Libav
---

Yesterday I wanted to make some new videos to visualize aspects of a protein I am studying, and I was struck with an idea for how I might address a particular point of annoyance in this job. Namely, the invasion of my hard drive by massive amounts of image files.

To start, let's take a look at how this job was traditionally done. This post will take a very broad view of its topics; the techniques I'll outline apply broadly, not specifically to python, PyMOL, or even structural biology.

  1. Launch PyMOL
  2. Prepare a session for visualization/prepare a script to generate image frames.
  3. Execute script to generate **LOTS** of images for each frame of video.
  4. Do something else productive, the above will take a while...
  5. Create your video using `avconv` (formerly `ffmpeg`); command backbone generally looks like `avconv -i frame%0<n>d.png my_video.mp4`.
  6. Throw all of those images away! (Depending on your needs, these could be anywhere from 10MB to 10GB and up)


