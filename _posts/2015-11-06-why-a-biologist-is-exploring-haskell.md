---
layout: post
title: Why A Biologist is Exploring Haskell
---

Haskell is something I've always wanted to explore more deeply. I suppose that
it might be more fair to say that I really want to explore functional
programming, and Haskell currently has my attention. I believe that it holds a
lot of promise for working in bioinformatics and computational biology, for
reasons explored below.

When  someone sets out to write some code to solve a problem, there's a peristent
tradeoff decision that one generally will need to make. The following statements
are meant to be taken as painting with broad strokes. Choosing an abstract
language like Python will buy yourself reduced developer time, increased
flexibility, and more accessible code, at the expense of reduced computational
efficiency. Choosing a more "gritty" language like C will instead provide
great computational efficiency at the expense of developer time, specialization
over generalization, and less reader-friendly code.

If your problem is relatively computationally simple, you may never need to care
about computational efficiency, so you stick with the nice abstract code. If 
the problem is computationally complex, you may have no other choice than to
ditch the handy abstraction and start thinking in bits and bytes. Performance
(computationally speaking) and progress (in development terms) are thus often
opposing objectives in a project. The world of programming has produced a lot of
hybrid approaches such as fast libraries of code written "close to the metal"
which can be employed by the abstract languages, or abstract languages being
used to munge data or "glue" together the pipelines of fast but inflexible
computation.

This is all well and good, and I bet it's been summarized a gajillion times
before, so why go through all of that? Haskell is an abstract language which can
perform comparably (within an order of magnitude in many cases) to C. So perhaps
it can occupy a realm where the code can benefit from both speed of execution and
development. Haskell appears to offer decent modularity, clarity, and rapid
iterative development while also being fast and amenable to parallelization. In
terms of style, mathematical literacy translates very well to literacy in
Haskell, so computational biologists should be pretty well off.

I've done some fun things with Haskell; I've solved some Euler and Rosalind
problems, I've tinkered with some fun geometry, and I am literate enough now to
generally make sense of other people's code. Yet I can't say I've really done
anything particularly impressive, which is a shame. So I've resolved to spend
some of my free time developing my Haskell and computational biology skills, and
hope that in the future, I'll begin a series to illustrate and share my
experiences.

I'll leave off with a relevant publication worth reading:
[Experience Report: Haskell in Computational Biology (Gallant, Daniels, Ramsay)](https://www.cs.tufts.edu/~nr/pubs/mrfy-abstract.html)
