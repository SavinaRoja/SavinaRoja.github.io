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


