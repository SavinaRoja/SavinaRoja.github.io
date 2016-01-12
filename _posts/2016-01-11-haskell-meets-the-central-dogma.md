---
layout: post
title: Haskell Meets the Central Dogma
---

This post will introduce some Haskell code to perform sequence operations
relevant to the *central dogma of molecular biology*. The code here should be
relatively simple, but some slight familiarity with Haskell or functional programming
is assumed.

The treatment of biology in this post is also kept simple, though if you don't know
what *the central dogma of molecular biology* is or could do with a brief
review, [I have written a bit on it](http://savinaroja.github.io/2015/11/17/a-review-of-the-central-dogma/);
*it is meant to give a little background for some of the molecular biology terms
used in this post, and to describe its context in the scope of biology today*.

[Here's the code from this post if you'd like to follow along](/assets/centraldogma.hs).
In [`ghci`](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/ghci.html)
you can load the file via `:l centraldogma.hs` to use the functions defined here..

### Some helpful type synonyms

I'll be working with sequences here using Haskell's native `string` type. Though
DNA, RNA, and protein sequences will all share this same underlying type it will
be helpful, in terms of documenting the code, to be able to convey whether a
function is meant to work with a particular kind of sequence or another. To do
this let's make use of the `type` declaration which creates type synonyms. 
These should help clarify the code's intent.
Note that in Haskell a string is a special case of a list, `[]`, one that contains `Char` elements:
`[Char]`. These will be more informative than just `Char` and `string` later on:

{% highlight haskell %}
type Element = Char            -- A unitary object
type Seq     = [Element]       -- An ordered collection of Elements

type DNABase = Element         -- DNA variant of Element
type DNASeq  = [DNABase]       -- DNA variant of Sequence

type RNABase = Element         -- RNA variant of Element
type RNASeq  = [RNABase]       -- RNA variant of Sequence

type AminoAcid  = Element      -- Protein variant of Element
type ProteinSeq = [AminoAcid]  -- Protein variant of Sequence
{% endhighlight %}

## Replication, Replication

So let's get started with replication, one of the basic operations of DNA and RNA
in which an exact copy (in its own medium) is produced. Since replication (when
we ignore the possibility of error) can be modeled by defining a function that
simply returns its own input, it's rather trivial to implement. Here I'll choose
to define a function that works element-wise, and a sequence-wise function which
is the mapping of the element-wise one over all of its elements. This pattern will be
employed throughout.

{% highlight haskell %}
--function that gives whatever sequence element it receives
replicateBase :: Element -> Element
replicateBase x = x

--function that maps the replicateBase function over its input
replication :: Seq -> Seq
replication s = map replicateBase s
{% endhighlight %}

When we supply a sequence string to the `replication` function like
`replication "GATTACA"`, it should give us `"GATTACA"` when it evaluates.
You could try this out with various sequence strings, the empty string is an
important test as well. Here's a little function to help test if the results are good.

{% highlight haskell%}
--True if the result of the replication function is the same as the input
validReplication :: Seq -> Bool
validReplication s = s == replication s
{% endhighlight %}

## Everybody likes complements

Now let's take a look at how we can write code to get the complementary sequence
for a DNA or RNA sequence. Recall that DNA and RNA form double stranded
structures according to nucleobase complementarity: `A` pairs with `T` (or `U`
in RNA) and `C` pairs with `G`. Here's a representation of this in code:

{% highlight haskell %}
complementDNABase :: DNABase -> DNABase
complementDNABase 'A' = 'T'
complementDNABase 'C' = 'G'
complementDNABase 'G' = 'C'
complementDNABase 'T' = 'A'
complementDNABase  x  =  x  -- do not change unexpected characters

complementDNA :: DNASeq -> DNASeq
complementDNA s = map complementDNABase s

complementRNABase :: RNABase -> RNABase
complementRNABase 'A' = 'U'
complementRNABase 'C' = 'G'
complementRNABase 'G' = 'C'
complementRNABase 'U' = 'A'
complementRNABase  x  =  x  -- do not change unexpected characters

complementRNA :: RNASeq -> RNASeq
complementRNA s = map complementRNABase s
{% endhighlight%}

These examples leverage pattern matching on their input. Note that we also have
the option of writing it with guards, though I don't prefer guard syntax for pattern
matching. Here's `complementDNABase` using guards just to demonstrate:

{% highlight haskell %}
complementDNABase :: DNABase -> DNABase
complementDNABase x
  | x == 'A'  = 'T'
  | x == 'C'  = 'G'
  | x == 'G'  = 'C'
  | x == 'T'  = 'A'
  | otherwise = x
{% endhighlight %}

Giving `"GATTACA"`to `complementDNA` should yield `"CTAATGT"` and giving the
corresponding `"GAUUACA"` to `complementRNA` should yield `"CUAAUCU"`.

Complementation is a reciprocal process, meaning that if we produce `s'` as the
complement of `s`, then `s` is also the complement of `s'`. This is an important
property of the function, so let's test it by making sure that if either of the
functions reproduce the input when executed twice in succession.

{% highlight haskell %}
testComplementDNA :: DNASeq -> Bool
testComplementDNA s = s == (complementDNA $ complementDNA s)

testComplementRNA :: RNASeq -> Bool
testComplementRNA s = s == (complementRNA $ complementRNA s)
{% endhighlight %}

Use these functions on any sequence string to see if the function was correctly
written.

DNA and RNA sequences are traditionally presented in a specific direction: 5' to
3' ([details here](https://en.wikipedia.org/wiki/Directionality_%28molecular_biology%29)).
It is important to remember that the complementing strand of DNA or RNA
generally "runs" in the opposite direction. That is to say, if you take `GATTACA`
which is reading 5' to 3', and produce it's complement `CTAATGT`, the complement
produced is reading 3' to 5'. It is common then to refer to the "reverse
complement" of a sequence as the complement read in the conventional 5' to 3'
fashion. Producing such a reverse complement function in Haskell is simple:

{% highlight haskell %}
reverseComplementDNA :: DNASeq -> DNASeq
reverseComplementDNA = reverse . complementDNA

reverseComplementRNA :: RNASeq -> RNASeq
reverseComplementRNA = reverse . complementRNA
{% endhighlight %}

Here I've used function composition with Haskell's
[`reverse`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:reverse)
function to easily define the reverse complement functions. That's pretty handy.

## Transcription and noitpircsnarT

The process of transcription refers to the production of RNA from a DNA template
and reverse transcription the production of DNA from an RNA template. This is
again mediated by base complementarity, and the code for it can be readily made
by adapting our complementing functions from above. When a DNA sequence, `s`, is
transcribed, a copy of that sequence is made in RNA using base complementarity
to the complementing DNA strand, `s'`. Since RNA nucleobases differ in the use
of Uracil instead of Thymine, the matter of transcription involves replacing
our `'T'`s with `'U'`s and vice versa for reverse transcription.

{% highlight haskell %}
transcribeBase :: DNABase -> RNABase
transcribeBase 'T' = 'U'
transcribeBase  x  =  x  -- leave other bases, or unexpected chars, alone

transcribe :: DNASeq -> RNASeq
transcribe s = map transcribeBase s

reverseTranscribeBase :: RNABase -> DNABase
reverseTranscribeBase 'U' = 'T'
reverseTranscribeBase  x  =  x  -- leave other bases, or unexpected chars, alone

reverseTranscribe :: RNASeq -> DNASeq
reverseTranscribe s = map reverseTranscribeBase s
{% endhighlight %}

Transcription and reverse transcription functions should be symmetrical. By
which I mean to say that if one transcribes a DNA sequence and then reverse
transcribes the result, it should reproduce the input. The same is true for
reverse transcription of an RNA sequence then transcription of the result. We can
make some fun functions to test whether this holds true:

{% highlight haskell %}
pingPong :: DNASeq -> Bool
pingPong s = s == (reverseTranscribe $ transcribe s)

thereAndBackAgain :: RNASeq -> Bool
thereAndBackAgain s = s == transcribe $ reverseTranscribe s
{% endhighlight %}

These only really work if the inputs are valid. Passing it a mixed
sequence like "GATUACA" should evaluate False in both functions.

## Translation -> Traducción

Translation is the process of creating proteins from messenger RNA sequences.
RNA is read in chunks of three nucleotides, which constitute a codon, to
determine which amino acid to add to a growing protein chain. The ["Genetic Code"](https://en.wikipedia.org/wiki/Genetic_code)
is the (*mostly* universal) coding scheme used in biology that maps codons to
amino acids. Without further ado, here's the genetic code in haskell:

{% highlight haskell %}
--Codons are just special cases (length 3) of their basic types
type DNACodon = DNASeq
type RNACodon = RNASeq

--Using RNA codons, if we want to use DNA, we can just transcribe first
--There are 4^3 = 64 combinations, so 64 codons. 
geneticCode :: RNACodon -> AminoAcid
geneticCode "AAA" = 'K'  -- Lysine
geneticCode "AAC" = 'N'  -- Asparagine
geneticCode "AAG" = 'K'  -- Lysine
geneticCode "AAU" = 'N'  -- Asparagine
geneticCode "ACA" = 'T'  -- Threonine
geneticCode "ACC" = 'T'  -- Threonine
geneticCode "ACG" = 'T'  -- Threonine
geneticCode "ACU" = 'T'  -- Threonine
geneticCode "AGA" = 'R'  -- Arginine
geneticCode "AGC" = 'S'  -- Serine
geneticCode "AGG" = 'R'  -- Arginine
geneticCode "AGU" = 'S'  -- Serine
geneticCode "AUA" = 'I'  -- Isoleucine
geneticCode "AUC" = 'I'  -- Isoleucine
geneticCode "AUG" = 'M'  -- Methionine
geneticCode "AUU" = 'I'  -- Isoleucine
geneticCode "CAA" = 'Q'  -- Glutamine
geneticCode "CAC" = 'H'  -- Histidine
geneticCode "CAG" = 'Q'  -- Glutamine
geneticCode "CAU" = 'H'  -- Histidine
geneticCode "CCA" = 'P'  -- Proline
geneticCode "CCC" = 'P'  -- Proline
geneticCode "CCG" = 'P'  -- Proline
geneticCode "CCU" = 'P'  -- Proline
geneticCode "CGA" = 'R'  -- Arginine
geneticCode "CGC" = 'R'  -- Arginine
geneticCode "CGG" = 'R'  -- Arginine
geneticCode "CGU" = 'R'  -- Arginine
geneticCode "CUA" = 'L'  -- Leucine
geneticCode "CUC" = 'L'  -- Leucine
geneticCode "CUG" = 'L'  -- Leucine
geneticCode "CUU" = 'L'  -- Leucine
geneticCode "GAA" = 'E'  -- Glutamate
geneticCode "GAC" = 'D'  -- Aspartate
geneticCode "GAG" = 'E'  -- Glutamate
geneticCode "GAU" = 'D'  -- Aspartate
geneticCode "GCA" = 'A'  -- Alanine
geneticCode "GCC" = 'A'  -- Alanine
geneticCode "GCG" = 'A'  -- Alanine
geneticCode "GCU" = 'A'  -- Alanine
geneticCode "GGA" = 'G'  -- Glycine
geneticCode "GGC" = 'G'  -- Glycine
geneticCode "GGG" = 'G'  -- Glycine
geneticCode "GGU" = 'G'  -- Glycine
geneticCode "GUA" = 'V'  -- Valine
geneticCode "GUC" = 'V'  -- Valine
geneticCode "GUG" = 'V'  -- Valine
geneticCode "GUU" = 'V'  -- Valine
geneticCode "UAA" = '*'  -- Stop (Ochre)
geneticCode "UAC" = 'Y'  -- Tyrosine
geneticCode "UAG" = '*'  -- Stop (Amber)
geneticCode "UAU" = 'Y'  -- Tyrosine
geneticCode "UCA" = 'S'  -- Serine
geneticCode "UCC" = 'S'  -- Serine
geneticCode "UCG" = 'S'  -- Serine
geneticCode "UCU" = 'S'  -- Serine
geneticCode "UGA" = '*'  -- Stop (Opal)
geneticCode "UGC" = 'C'  -- Cysteine
geneticCode "UGG" = 'W'  -- Tryptophan
geneticCode "UGU" = 'C'  -- Cysteine
geneticCode "UUA" = 'L'  -- Leucine
geneticCode "UUC" = 'F'  -- Phenylalanine
geneticCode "UUG" = 'L'  -- Leucine
geneticCode "UUU" = 'F'  -- Phenylalanine
geneticCode   x   = '-'  -- Anything else corresponds to nothing
{% endhighlight %}

When it comes to expressing coding schemes, there's just no way to cut corners
so that got a little verbose. Writing that sort of code is no fun, but there was
no way around it[<sup>1</sup>](#IUPAC_compression). So now that we've got our genetic code, let's put it
to work translating some codons to a protein sequence.

{% highlight haskell %}
import Data.List.Split  -- provides chunksOf function; package: split

translate :: RNASeq -> ProteinSeq
translate s = map geneticCode $ chunksOf 3 s
{% endhighlight %}

`chunksOf 3` creates a function that takes a list, and returns a list of lists
of length 3, though the last item might be shorter if the input list is not evenly
divisible by 3. We can feed our sequence string to this, strings are just lists
of characters after all, and get a list of codons back. `chunksOf 3 "GAUUACA"`
would produce `["GAU", "UAC", "A"]`. Mapping the genetic code function over that
list of strings would give `"DY-"`.

If we want to translate DNA sequences, we
could go the hard way and write a new function, or we could go the smart way and
create easily with function composition:

{% highlight haskell %}
translateDNA :: DNASeq -> ProteinSeq
translateDNA = translate . transcribe
{% endhighlight %}

Now we can do `translateDNA "GATTACA"` to get `"DY-"`.

For a change of pace, let's do something a bit less frivolous to test our work.
Let's visit the [NCBI Gene page of a gene I like](http://www.ncbi.nlm.nih.gov/gene/3933)
and snag the sequences of [an mRNA](http://www.ncbi.nlm.nih.gov/nuccore/NM_001252617.1) and
[the protein it produces](http://www.ncbi.nlm.nih.gov/protein/NP_001239546.1).
Here's [the mRNA sequence file](/assets/lipocalin1_mRNA.fa) and
[the protein sequence file](/assets/lipocalin1_protein.fa). For simplicity I'll
put them here:

    >gi|357933616|ref|NM_001252617.1| Homo sapiens lipocalin 1 (LCN1), transcript variant 2, mRNA
    ACAGCCTCTCCCAGCCCCAGCAAGCGACCTGTCAGGCGGCCGTGGACTCAGACTCCGGAGATGAAGCCCC
    TGCTCCTGGCCGTCAGCCTTGGCCTCATTGCTGCCCTGCAGGCCCACCACCTCCTGGCCTCAGACGAGGA
    GATTCAGGATGTGTCAGGGACGTGGTATCTGAAGGCCATGACGGTGGACAGGGAGTTCCCTGAGATGAAT
    CTGGAATCGGTGACACCCATGACCCTCACGACCCTGGAAGGGGGCAACCTGGAAGCCAAGGTCACCATGC
    TGATAAGTGGCCGGTGCCAGGAGGTGAAGGCCGTCCTGGAGAAAACTGACGAGCCGGGAAAATACACGGC
    CGACGGGGGCAAGCACGTGGCATACATCATCAGGTCGCACGTGAAGGACCACTACATCTTTTACTGTGAG
    GGCGAGCTGCACGGGAAGCCGGTCCGAGGGGTGAAGCTCGTGGGCAGAGACCCCAAGAACAACCTGGAAG
    CCTTGGAGGACTTTGAGAAAGCCGCAGGAGCCCGCGGACTCAGCACGGAGAGCATCCTCATCCCCAGGCA
    GAGCGAAACCTGCTCTCCAGGGAGCGATTAGGGGGACACCTTGGCTCCTCAGCAGCCCAAGGACGGCACC
    ATCCAGCACCTCCGTCATTCACAGGGACATGGAAAAAGCTCCCCACCCCTGCAGAACGCGGCTGGCTGCA
    CCCCTTCCTACCACCCCCCGCCTTCCCCCTGCCCTGCGCCCCCTCTCCTGGTTCTCCATAAAGAGCTTCA
    GCAGTTCCCAGTGA

    >gi|357933617|ref|NP_001239546.1| lipocalin-1 isoform 1 precursor [Homo sapiens]
    MKPLLLAVSLGLIAALQAHHLLASDEEIQDVSGTWYLKAMTVDREFPEMNLESVTPMTLTTLEGGNLEAK
    VTMLISGRCQEVKAVLEKTDEPGKYTADGGKHVAYIIRSHVKDHYIFYCEGELHGKPVRGVKLVGRDPKN
    NLEALEDFEKAAGARGLSTESILIPRQSETCSPGSD

The idea now is to make sure that the results of our translation function when
fed the mRNA sequence jives with the reference implementation's results. Let's
get down to work! I don't want to have to type or copy the sequence into the
source, so let's make a function to read the sequences out of the files.

{% highlight haskell %}
--A very simple, non-general function to get the sequence
simpleSeqGetter :: FilePath -> IO Seq
simpleSeqGetter fp = do
  unmunged <- readFile fp
  let linedropped = drop 1 $ lines unmunged
  return $ foldr (++) "" linedropped
{% endhighlight %}

This is not a proper FASTA parsing job, but it serves for now. I've dropped the
first line describing the sequence and gotten rid of the newline characters. So
now I can do the following in `ghci`:

{% highlight haskell %}
ghci> mrna <- simpleSeqGetter "lipocalin_mRNA.fa"
ghci> prot <- simpleSeqGetter "lipocalin_protein.fa"
ghci> translateDNA mrna
"TASPSPSKRPVRRPWTQTPEMKPLLLAVSLGLIAALQAHHLLASDEEIQDVSGTWYLKAMTVDREFPEMNLESVTPMTLTTLEGGNLEAKVTMLISGRCQEVKAVLEKTDEPGKYTADGGKHVAYIIRSHVKDHYIFYCEGELHGKPVRGVKLVGRDPKNNLEALEDFEKAAGARGLSTESILIPRQSETCSPGSD*GDTLAPQQPKDGTIQHLRHSQGHGKSSPPLQNAAGCTPSYHPPPSPCPAPPLLVLHKELQQFPV-"
ghci> prot == translate mrna
False
{% endhighlight %}

It's pretty clear that our results don't match. Some readers might have seen
this coming, because I've not prepared to handle an important detail! If you
look carefully you'll see that the expected sequence **is** there, but sandwiched
between some other protein sequence. Without getting into specifics, mRNA sequences
contain untranslated regions (UTRs) at both the 5' and 3'
ends of the sequence. These untranslated regions are a part of the sequence file;
to figure out what the ribosome would actually produce from this particular
mRNA we'll need to know how to drop them (UTRs are totally interesting in their
own right, but that's a story for another time). 

To determine where the translated section begins, we must look for the first (5'
most) `AUG` codon, this is the start codon and codes for Methionine.
Everything from that point on is
translated until we reach a stop codon: one of `UAA`, `UAG`, `UGA`. The region
from the start codon to the stop codon is the coding region.
Let's implement these rules in code now:

{% highlight haskell %}
translateCodingRegion :: RNASeq -> ProteinSeq
translateCodingRegion s = takeWhile ('*'/=) $ dropWhile ('M'/=) $ translateDNA s
{% endhighlight %}

This now drops everything before the start codon, and keeps everything until the
stop codon. Now we can try this function out and test its results in `ghci`:

{% highlight haskell %}
ghci> mrna <- simpleSeqGetter "lipocalin_mRNA.fa"
ghci> prot <- simpleSeqGetter "lipocalin_protein.fa"
ghci> translateCodingRegion mrna
"MKPLLLAVSLGLIAALQAHHLLASDEEIQDVSGTWYLKAMTVDREFPEMNLESVTPMTLTTLEGGNLEAKVTMLISGRCQEVKAVLEKTDEPGKYTADGGKHVAYIIRSHVKDHYIFYCEGELHGKPVRGVKLVGRDPKNNLEALEDFEKAAGARGLSTESILIPRQSETCSPGSD"
ghci> prot == translateCodingRegion mrna
True
{% endhighlight %}

Tada! We can translate a given DNA or RNA sequence as well as fish out the first coding
region from a sequence. By the way, have you thought it's weird that I've been
using `translateDNA` on an RNA sequence? Yeah, it's not just you. Nucleic acid
sequences are often stored in the DNA alphabet, regardless of whether it makes
more physical/biological sense as RNA. It's a bit odd, but common enough to
gloss over transcription and reverse transcription since they directly correlate.

## Translation Party: Reverse Translation

In my [previous post](http://savinaroja.github.io/2015/11/17/a-review-of-the-central-dogma/),
I made something of a big deal about how reverse
translation (also sometimes called "back translation")
has never been observed and we've got pretty good reasons to never
expect it to occur. But it turns out that there are plenty of times where we
might want to address reverse translation computationally.

Most amino acids have more than one codon that codes for them, but no codon
codes for more than one amino acid. In this way, the genetic code is degenerate
but not ambiguous. In other words, a given nucleic acid sequence passed through
the genetic code will only produce one protein sequence, but a given protein
sequence could be decoded to multiple nucleic acid sequences.

This leads to a *very hard* problem in trying to represent all the possible
encoding sequences. Only for rather short protein sequences is it computationally
feasible to consider representing all the combinations in memory or storage, or
to iteratively consider all of the possibilities.

I think that looking deeper into reverse translation applications is worthy of
one or more focused posts, but it'd be good to give a short treatment here. I'll
define a function that decodes a protein sequence to its possible DNA sequences.
Might get a little lengthy again...

{% highlight haskell %}
codonsFor :: AminoAcid -> [DNACodon]
codonsFor 'A' = ["GCA","GCC","GCG","GCT"]              -- Alanine
codonsFor 'C' = ["TGC","TGT"]                          -- Cysteine
codonsFor 'D' = ["GAC","GAT"]                          -- Aspartate
codonsFor 'E' = ["GAA","GAG"]                          -- Glutamate
codonsFor 'F' = ["TTC","TTT"]                          -- Phenylalanine
codonsFor 'G' = ["GGA","GGC","GGG","GGT"]              -- Glycine
codonsFor 'H' = ["CAC","CAT"]                          -- Histidine
codonsFor 'I' = ["ATA","ATC","ATT"]                    -- Isoleucine
codonsFor 'K' = ["AAA","AAG"]                          -- Lysine
codonsFor 'L' = ["CTA","CTC","CTG","CTT","TTA","TTG"]  -- Leucine
codonsFor 'M' = ["ATG"]                                -- Methionine
codonsFor 'N' = ["AAC","AAT"]                          -- Asparagine
codonsFor 'P' = ["CCA","CCC","CCG","CCT"]              -- Proline
codonsFor 'Q' = ["CAA","CAG"]                          -- Glutamine
codonsFor 'R' = ["AGA","AGG","CGA","CGC","CGG","CGT"]  -- Arginine
codonsFor 'S' = ["AGC","AGT","TCA","TCC","TCG","TCT"]  -- Serine
codonsFor 'T' = ["ACA","ACC","ACG","ACT"]              -- Threonine
codonsFor 'V' = ["GTA","GTC","GTG","GTT"]              -- Valine
codonsFor 'W' = ["TGG"]                                -- Tryptophan
codonsFor 'Y' = ["TAC","TAT"]                          -- Tyrosine
codonsFor '*' = ["TAA","TAG","TGA"]                    -- Stop
codonsFor  x  = [] -- If for some reason we get bad input, treat as empty
{% endhighlight %}

With this element-wise function in hand, we can create a reverse translation
function to work on a protein sequence:

{% highlight haskell %}
reverseTranslate :: ProteinSeq -> [[DNACodon]]
reverseTranslate s = map codonsFor s
{% endhighlight%}

For each amino acid in the protein sequence this function will produce a list
of the codons that can code for it, resulting in a list of codon options. If we
wanted to ask how many different ways the protein sequence could be encoded, we
could do the following:

{% highlight haskell %}
import Data.List

uniqueCodingsCount :: ProteinSeq -> Integer
uniqueCodingsCount s = foldr (\x -> (*) genericLength x) 1 $ reverseTranslate s
{% endhighlight %}

This folds our list up by taking the length of each sub-list and multiplying it
by the accumulated value which I initiated at `1`. Note that I used `genericLength`
from `Data.List` so that it would return the length as type `Integer` which can
hold an arbitrarily large number (these numbers get **big**). Let's give it a couple tries:

{% highlight haskell%}
ghci> uniqueCodingsCount ""
1
ghci> uniqueCodingsCount "V"
4
ghci> uniqueCodingsCount "VR"
24
ghci> prot <- simpleSeqGetter "lipocalin1_protein.fa"
ghci> uniqueCodingsCount prot
179208254265065853973421853282336100254440836495296107948284025895512055446786937609781248
ghci> uniqueCodingsCount "ABCDE"
0
{% endhighlight%}

Damn, that's a lot of ways that this short sequence (only 176 amino acids) could be
represented in DNA. Also interesting is that giving `uniqueCodingsCount` a sequence
with an invalid amino acid such as `'B'` correctly reports that there are `0`
ways to encode this protein.

Now let's set to work creating a function that will actually generate the
unique DNA sequence combinations that can code for a protein sequence. The
signature for this function should look like this:

{% highlight haskell %}
uniqueCodings :: ProteinSeq -> [DNASeq]
{% endhighlight %}

It's clear that this function will make use of `reverseTranslate` whose result
type is `[[DNACodon]]`, so we can begin to think how we might convert that to
`[DNASeq]`. To do this we can make use of a fold function (like I have already
above) with a function and an accumulator to reduce the list. So what kind of
function might we be interested in? Consider the behavior of list comprehensions:

{% highlight haskell %}
ghci> [ x + y | x <- [10,20,30], y <- [1,2,3]]
[11,12,13,21,22,23,31,32,33]
ghci> [ x y | x <- [(*1), (*2), (*3)], y <- [10, 15]]
[10,15,20,30,40,60]
ghci> [ (,) x y | x <- ["x1", "x2"], y <- ["y1", "y2", "y3", "y4"]]
[("x1","y1"),("x1","y2"),("x1","y3"),("x2","y1"),("x2","y2"),("x2","y3")]
{% endhighlight %}

When we draw from two lists in the creation of a new list, the list is produced
as an operation with all the combinations of the elements in the drawn lists.
To help illustrate how we can make use of this, here's one more example:

{% highlight haskell%}
ghci> [ x ++ y | x <- ["orange", "apple"], y <- [" juice", " concentrate"]]
["orange juice","orange concentrate","apple juice","apple concentrate"]
{% endhighlight %}

Putting the pieces together:

{% highlight haskell%}
uniqueCodings :: ProteinSeq -> [DNASeq]
uniqueCodings s = foldl combine [""] $ reverseTranslate s where
                    combine xs ys = [ x ++ y | x <- xs, y <- ys]
{% endhighlight %}

Remember that massive number we got from `uniqueCodingsCount` on the lipocalin
protein sequence? We really don't want to go printing that many of anything...
let's keep the tests small and reasonable.

{% highlight haskell%}
ghci> uniqueCodings ""
[""]
ghci> uniqueCodings "H"
["CAC","CAT"]
ghci> uniqueCodings "HAM"
["CACGCAATG","CACGCCATG","CACGCGATG","CACGCTATG","CATGCAATG","CATGCCATG","CATGCGATG","CATGCTATG"]
ghci> uniqueCodings "HAMBO"
[]
{% endhighlight %}

Pretty cool, the empty protein sequence can only be encoded as an empty DNA
sequence. For a lone histidine `"H"` we essentially get `codonsFor 'H'` and for
`"HAM"` we get a list of 9 unique combinations of codons. When I gave it
bad amino acids it tells me there is no way to encode such a sequence. We should
expect `length uniqueCodings s` should be equal to `uniqueCodingsCount s`:

{% highlight haskell %}
ghci> let testCounts s = (uniqueCodingsCount s) == (length $ uniqueCodings s)
ghci> testCounts ""
True
ghci> testCounts "MARCELINE"
True
ghci> testCounts "BMO" -- Not valid protein sequence
True
{% endhighlight %}

It looks like our function checks out, we now have a way to work with the DNA
sequences that can code for a specified protein. To wrap this post up, I'll put
that function to work solving a real world problem (I've done this in my own
research).

### Storytime

*Imagine you are a scientist who has a protein you would like to produce
and study. You know the amino acid sequence for the protein and you are
ordering the synthesis of a DNA sequence to code for your protein. For reasons
you try valiantly (but unsuccessfully) to explain to your great uncle Max during Thanksgiving
dinner, you wish to incorporate a specific DNA sequence in a particular segment
of your protein's coding region. This is to allow a restriction enzyme to cut
your DNA sequence for important and inscrutable purposes.*

*Now your DNA sequence design has a constraint. If you can help it, you'd
prefer not to mutate the protein sequence. Perhaps you can take advantage of
the degeneracy of the genetic code to choose codons that provide your restriction
enzyme site without modifying any amino acids.*

*You select a small region of your protein that is suitable for the site: "ALGYL"*

*You ask, "Can I put an `EcoRI` or `EcoRV` site in here?"*

### The solution

You're smart; you decide to let a computer do the investigation.

{% highlight haskell %}
--produce only the possible coding DNA sequences that contain the constraint
constrainedUniqueEncodings :: ProteinSeq -> [DNASeq]
constrainedUniqueEncodings s constraint = filter (isInfixOf constraint) $ uniqueEncodings s
{% endhighlight %}

{% highlight haskell%}
ghci> let ecoRISeq = "GAATTC"
ghci> let ecoRVSeq = "GATATC"
ghci> let proteinSegment = "ALGYL"
ghci> constrainedUniqueEncodings proteinSeqment ecoRISeq
[]
ghci> constrainedUniqueEncodings proteinSeqment ecoRVSeq
["GCACTAGGATATCTA","GCACTAGGATATCTC", ... ,"GCTTTGGGATATCTG","GCTTTGGGATATCTT"]
{% endhighlight%}

Sadly you can't put in an EcoRI site without changing amino acids, but you *can*
choose your codons to incorporate the EcoRV site. I greatly abbreviated the
output of that final evaluation, it actually gives 96 result sequences! If the
sequence search space were much larger, it could be hard to even find the codons
of note. A good way to improve the code would be to have the code identify them.
In this case the EcoRV site spans three codons for "GYL". If we narrow the
search to exactly those three we get an exact notion of our options:

{% highlight haskell%}
ghci> constrainedUniqueEncodings "GYL" ecoRVSeq
["GGATATCTA","GGATATCTC","GGATATCTG","GGATATCTT"]
{% endhighlight %}

With that bit of practical problem solving, we conclude our demonstration.

### Footnotes

<a name="IUPAC_compression"></a>**1**: I could employ the IUPAC compression
format to make this shorter, but that would just pass the buck and I'd have to
write the details in an IUPAC function. It *would* be reusable though, and might
be worth doing for that.
