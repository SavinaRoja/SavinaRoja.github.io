---
layout: post
title: Haskell Meets the Central Dogma
---

This post will introduce some Haskell code to perform sequence operations
relevant to the *central dogma of molecular biology*. The code here is relatively
simple, and I hope I present the concepts in a clear fashion that novices can
comprehend. As a novice Haskeller, maybe that will come naturally.

If you are unfamiliar with *the central dogma of molecular biology*, or you
would like to review the subject, [I have written a short post as a review of the
topic](http://savinaroja.github.io/2015/11/17/a-review-of-the-central-dogma/).
It is meant to provide some background for the terms used in this post, as well
as some motivation for why the code presented matter to biology and
bioinformatics. These are sister posts, and as I work on one, I will likely
adjust the other to match.

## Strings, ByteStrings, and Text


