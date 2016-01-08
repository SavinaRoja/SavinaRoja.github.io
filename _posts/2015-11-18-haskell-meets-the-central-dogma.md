---
layout: post
title: Haskell Meets the Central Dogma
---

This post will introduce some Haskell code to perform sequence operations
relevant to the *central dogma of molecular biology*. The code here should be
relatively simple, and I hope I present the concepts in a clear fashion that is
helpful for novices.

If you don't know what *the central dogma of molecular biology* is, or if you
would like a brief review of it, [I have written a post on it](http://savinaroja.github.io/2015/11/17/a-review-of-the-central-dogma/).
It is meant to give a little background for some of the molecular biology terms
used in this post, and to give a little idea of where it fits into the broader
scope of biology today.

For the examples in this post, I will be representing sequences with Haskell
strings. I may write more on this decision later, but it boils down to
readability and simplicity.

## Replication, Replication

I said that I'd be representing sequences as strings, so I might think of
declaring the following (solely for the benefit of helping the code document
itself) type synonyms. In Haskell, a `string` is special case of a list, `[]`, one that
that contains `Char`s: `[Char]`.

{% highlight haskell %}
type Element = Char            -- A unitary object
type Seq     = [Element]       -- An ordered collection of Elements

type DNABase = Char            -- DNA variant of Element
type DNASeq  = [DNABase]       -- DNA variant of Sequence

type RNABase = Char            -- RNA variant of Element
type RNASeq  = [RNABase]       -- RNA variant of Sequence

type AminoAcid  = Char         -- Protein variant of Element
type ProteinSeq = [AminoAcid]  -- Protein variant of Sequence
{% endhighlight %}

So let's get down to replication, one of the basic operations of DNA and RNA
in which an exact copy (in its own medium) is produced. A function to model
perfect (no errors such as skips, repeats, or alterations) replication is a
pretty trivial one. Let's represent the replication of a sequence as the map
of a function that yields its own input over the elements, or nucleotides, of
the sequence.

{% highlight haskell %}
--function that gives whatever sequence element it receives
replicateBase :: Element -> Element
replicateBase x = x

--function that maps the replicateBase function over its input
replication :: Seq -> Seq
replication s = map replicateBase s
{% endhighlight %}

So when we feed a string like  `"GATTACA"` to the `replication` function, we
expect it to evaluate to `"GATTACA"`. Try it out with a few strings, you could
a test function like the following would would tell you
if the results are good.

{% highlight haskell%}
validReplication :: Seq -> Bool
validReplication s = s == replication s
{% endhighlight %}

## Everybody likes complements

So let's take a look at how we can write code to get the complementary sequence
for a DNA or RNA sequence. You recall that DNA and RNA form double stranded
structures according to nucleobase complementarity: `A` pairs with `T` (or `U`
in RNA) and `C` pairs with `G`. Here's how we might represent some of this with code:

{% highlight haskell %}
complementDNABase :: DNABase -> DNABase
complementDNABase 'A' = 'T'
complementDNABase 'C' = 'G'
complementDNABase 'G' = 'C'
complementDNABase 'T' = 'A'
complementDNABase x = x     -- do not change unexpected characters

complementDNA :: DNASeq -> DNASeq
complementDNA s = map complementDNABase s

complementRNABase :: RNABase -> RNABase
complementRNABase 'A' = 'U'
complementRNABase 'C' = 'G'
complementRNABase 'G' = 'C'
complementRNABase 'U' = 'A'
complementRNABase x = x     -- do not change unexpected characters

complementRNA :: RNASeq -> RNASeq
complementRNA s = map complementRNABase s
{% endhighlight%}

These examples leverage pattern matching on their input, we also have the option
of writing it with guards, but I tend to prefer guards when there is a bit more
logic to perform than just pattern matching. Here's `complementDNABase` using
guards just to show how it might be done:

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
corresponding `"GAUUACA"` to `complementRNA` should yield `"CUAAUCU"`. Give it a
try.

DNA and RNA sequences are traditionally presented in a specific direction: 5' to
3' ([details here](https://en.wikipedia.org/wiki/Directionality_%28molecular_biology%29)).
It is important to remember that the complementing strand of DNA or RNA
generally "runs" in the opposite direction. That is to say, if you take `GATTACA`
which is reading 5' to 3', and produce it's complement `CTAATGT`, the complement
produced is reading 3' to 5'. It is common then to refer to the "reverse"
complement of a sequence as the complement read in the conventional 5' to 3'
fashion. Producing a reverse complement function in Haskell is simple:

{% highlight haskell %}
reverseComplementDNA :: DNASeq -> DNASeq
reverseComplementDNA = reverse . complementDNA

reverseComplementRNA :: RNASeq -> RNASeq
reverseComplementRNA = reverse . complementRNA
{% endhighlight %}

Here I've used function composition with Haskell's [`reverse`](http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:reverse)
to define the reverse complement functions.

## Transcription and noitpircsnarT

The process of transcription refers to the production of RNA from a DNA template
and reverse transcription the production of DNA from an RNA template. This is
again mediated by base complementarity, and the code for it can be readily made
by adapting our complementing functions from above. Here we need only replace
`'T'`s with `U`s and vice versa.

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

Since transcription and reverse transcription are symmetrical processes, it
would be good to check that if we pass a string through both functions we get
back what we started with. I'll give the testing functions fun names:

{% highlight haskell %}
pingPong :: DNASeq -> Bool
pingPong s = s == (reverseTranscribe $ transcribe s)

thereAndBackAgain :: RNASeq -> Bool
thereAndBackAgain s = s == transcribe $ reverseTranscribe s
{% endhighlight %}

These of course only really work if the inputs are valid. Passing it a mixed
sequence like "GATUACA" should evaluate False in both functions.

## Translation -> Traducción

Translation is the process of creating proteins from messenger RNA sequences,
where the RNA is read three nucleotides at a time, constituting a codon, to
determine which amino acid to add to a growing protein chain. The ["Genetic Code"](https://en.wikipedia.org/wiki/Genetic_code)
is the (mostly universal) coding scheme used in biology that maps codons to
amino acids. Without further ado, here's the genetic code in haskell:

{% highlight haskell%}
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
geneticCode   x   = '-'   -- Anything else corresponds to nothing
{% endhighlight %}

When it comes to expressing coding schemes, there's just no way to cut corners
so that got a little verbose. Writing that sort of code is no fun, fortunately it
doesn't come up that often. So now that we've got our genetic code, let's put it
to work translating some codons to a protein sequence.

{% highlight haskell %}
import Data.List.Split  -- provides chunksOf function; package: split

translate :: RNASeq -> ProteinSeq
translate s = map geneticCode $ chunksOf 3 s
{% endhighlight %}

`chunksOf 3` creates a function that takes a list, and returns a list of lists
length 3, though the last list might be shorter if the input list is not evenly
divisible by 3. We can feed our sequence string to this, strings are just lists
of characters after all, and get a list of codons back. `chunksOf 3 "GAUUACA"`
would produce `["GAU", "UAC", "A"]`. Mapping the genetic code function over that
list of strings would give `"DY-"`.

If we want to translate DNA sequences, we
could go the hard way and write a new function, or we could go the smart way and
compose a new one:

{% highlight haskell %}
translateDNA :: DNASeq -> ProteinSeq
translateDNA = translate . transcribe
{% endhighlight %}

Now we can do `translateDNA "GATTACA"` to get `"DY-"`.

For a change of pace, let's do something a bit less silly to test our work. We
can go to a [gene I like ](http://www.ncbi.nlm.nih.gov/gene/3933) and snag the
sequence of [an mRNA](http://www.ncbi.nlm.nih.gov/nuccore/NM_001252617.1) and
[the protein it produces](http://www.ncbi.nlm.nih.gov/protein/NP_001239546.1).
For simplicity I'll put them here in FASTA format:

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



## Translation Party: Reverse Translation

## Regarding Strings, ByteStrings, and Text

*The following text is from an earlier draft, and will either be adapted at the
end of this post, or become a short post on its own.*

Let's talk data types for a bit before moving on. In Haskell we have some choice
in readily available frameworks to deal with sequence information, namely
Strings, ByteStrings, and Text. The choice we make depends upon the data with
which we are working, and what we'd like to accomplish. I'll give a short
summary of the concerns, a good starting point for more information is
[Edward Z. Yang's post on *Strings in Haskell*](http://blog.ezyang.com/2010/08/strings-in-haskell/).
[This post on Stack OverFlow is also very helpful](http://stackoverflow.com/questions/7357775/text-or-bytestring).

Strings are a sort of native, legacy type in Haskell, and when used in the
right contexts provide generally cleaner, more concise code. This is a boon when
trying to provide simple examples without the noise of imports and namespaces.
ByteStrings come in both strict (`Data.ByteString`) and lazy
(`Data.ByteString.Lazy`) forms, and can offer high performance when working with
information that doesn't need to be treated as human language. For this reason I
am apt to suggest that one becomes quickly acquainted with ByteStrings for
working with biological sequence data.


