---
layout: post
title: A Review of the Central Dogma 
---

This post is here to provide a basic overview of the central dogma of molecular
biology, as a introductory foundation for a future post on Haskell functions
pertinent to the central dogma. [Click here to go to that post](http://savinaroja.github.io/2015/11/17/haskell-meets-the-central-dogma/).
If you already steeped in biology and genetics, and are already very familiar
with discussion of the central dogma, please feel free to skip this post. This
review assumes some basic familiarity with the base-pairing nature of nucleic
acids and perhaps some general biology and chemistry.

## What the "central dogma" is all about

The [*central dogma of molecular biology*](https://en.wikipedia.org/wiki/Central_dogma_of_molecular_biology#)
is the codification of how information is transferred between the biopolymers:
DNA, RNA, and protein. It is sometimes given in the most simplistic form:
"DNA proceeds to RNA proceeds to protein". While broadly true, let's take a
moment to elaborate upon this by discussing the "special" model.

This nice public domain graph gives a concise overview of the information
transfer paths between the biopolymers as they are known. I'll focus on each in
turn.

![central dogma graph](/assets/Centraldogma_nodetails.png)

**DNA** information is ubiquitously transferred to further DNA as it is copied
by DNA polymerases, this process is essential for providing the genetic
material for an organism's progeny. In addition, DNA information may be copied
to the chemically similar biopolymer RNA by a process called transcription. RNA
polymerases can produce sequences of RNA which are complementary to the DNA
template they read. RNA utilizes the nucleobase *uracil* in place of the
nucleobase *thymine* which is found in DNA (both are complementary to the
nucleobase *adenosine*) and for this reason where a DNA sequence is transcribed
to RNA one will see the "T"s replaced by "U"s.

**RNA** in the form of messenger RNA, mRNA, is *translated* to protein by a
complex structure of protein and RNA known as the ribosome. The ribosome
produces the protein sequence (a polymer of amino acids) as it mediates the
interaction of the template nucleotides with transfer RNAs, tRNAs; groups of
three nucleotides constitute *codons* which specifically interact with
complementary tRNAs which are in turn linked to specific amino acids.
[More about the genetic code](https://en.wikipedia.org/wiki/Genetic_code).
RNA is also known to be *reverse transcribed* into DNA by RNA-dependent DNA
polymerases, in nature mostly associated with retroviruses whose RNA-based
genome must be first converted to DNA before integrating with the host's own
genome. As in DNA, RNA may be copied into further RNA by [RNA-dependent RNA
polymerases](https://en.wikipedia.org/wiki/RNA-dependent_RNA_polymerase). I
think it should be said that RNA is a very versatile molecule; it's more
flexible folding behavior (compared to DNA) allows it to form enzymes and to
participate in mechanisms that silence, modifify, or enrich the information in
other biopolymers.

**Protein** is a dead-end of the central dogma. No mechanism has been observed
in nature that conveys protein sequence information back to either DNA or RNA.
Even compared to the versatility of RNA, protein is king when it comes to
functional diversity. *Reverse translation* has not been observed in nature,
the discovery of such would be exceedingly momentous and would constitute an
astounding mode of horizontal gene transfer. Prions, proteins which alter the
conformation and function of other proteins to produce new prions, constitute a
mechanism by which information flows protein to protein. [Here's an enlightening
opinion article about prions](https://dx.doi.org/doi:10.1186/1745-6150-7-27)

I'd like to leave off with the comment that there are many mechanisms for
heritable information flow in biology of which we are aware but I did not
mention. Here are a few keywords of interest I can think of to aid further
investigation of biological information flow: epigenetics, gene splicing,
alternative splicing, RNA editing, RNA interference, post-translational
modification, DNA methylation, inteins, riboswitches, horizontal gene transfer,
direct DNA translation. 

At some point in the future, I may return to this post to flesh things out or I
might create a new post with information.
