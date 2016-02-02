---
layout: post
title: Haskell Revisits the Central Dogma
---

In this post I'll be going over some of the ideas from the previous,
[Haskell Meets the Central Dogma](http://savinaroja.github.io/2016/01/11/haskell-meets-the-central-dogma),
and introduce some additional concepts for refinement. If you
are new to Haskell, you may want to read that one before this one. This post will
add some intermediate concepts in Haskell code and hopefully the transition
will feel suitably gradual for novices.

### Limitations of type synonyms

I previously began by declaring some type synonyms so that in my code
I could differentiate between functions meant to operate with DNA (`DNASeq`),
RNA (`RNASeq`), or protein (`ProteinSeq`). The type synonyms were all tied to
Haskell's `String` type (a synonym itself for `[Char]`) so under the hood
they were of identical type. Here is that code for quick reference:

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

With these in place I could declare `translate :: RNASeq -> ProteinSeq` in lieu
of `translate :: String -> String` to indicate that the expected behavior is
meaningful for particular `Strings` values, not `String` values in general. Yet
since these type declarations are fundamentally equvialent there is no impediment
to using just any `String` value: Here's some weird behavior that is possible
using our type synonym system:

{% highlight haskell %}
ghci> let mydna = "GATTACA" :: DNASeq
ghci> let mypro = "ALGLYSW" :: ProteinSeq
ghci> mydna ++ mypro  -- we can concatenate, but what does it mean?
"GATTACAALGYLSW"
ghci> :t mydna ++ mypro  -- how does ghci repesent the result type?
mydna ++ mypro :: [DNABase]
ghci> :t mypro ++ mydna  -- it depends on the order!
mypro ++ mydna :: [AminoAcid]
ghci> :t reverseTranslate
reverseTranslate :: ProteinSeq -> [[DNACodon]]
ghci> reverseTranslate mydna  -- The base Chars in DNA can interpreted as valid amino acids
[["GGA","GGC","GGG","GGT"],["GCA","GCC","GCG","GCT"],["ACA","ACC","ACG","ACT"],["ACA","ACC","ACG","ACT"],["GCA","GCC","GCG","GCT"],["TGC","TGT"],["GCA","GCC","GCG","GCT"]]
{% endhighlight %}

Type synonyms help with the goal of enhancing code readability, which they do by
essentially conveniently laying a comment on top of a type. However they are
clearly limited in that the associations they convey are tenuous. While it
sufficed for the previous post where I represented all sequences as strings,
I'll explore how to enhance the clarity and rigor of the code in this post.

## Using `data`

So let's begin by introducing a new data type system using algebraic data types.
In a departure from the format of the previous work, I'll not be
making a type distinction between RNA and DNA in this post. This is to keep
the complexity down and reduce the amount of code since interconversion is quite
simple.

{% highlight haskell %}
--Note that Thymine is Uracil in RNA context
data Nucleotide = Adenine | Cytosine | Guanosine | Thymine
  deriving (Eq, Show)

--The 20 standard amino acids, plus Stop
data AminoAcid = Alanine
               | Arginine
               | Asparagine
               | Aspartate
               | Cysteine
               | Glutamate
               | Glutamine
               | Glycine
               | Histidine
               | Isoleucine
               | Leucine
               | Lysine
               | Methionine
               | Phenylalanine
               | Proline
               | Serine
               | Threonine
               | Tryptophan
               | Tyrosine
               | Valine
               | Stop
  deriving (Eq, Show)

type NucleicSeq = [Nucleotide]  -- Nucleic Acid Sequence
type ProteinSeq = [AminoAcid]   -- Protein Sequence
{% endhighlight %}

Here I've created two new data types: `Nucleotide`, and `AminoAcid`. These new
data types have their own value constructors. The type synonyms `NucleicSeq`,
`ProteinSeq` declare my intent to work with these sequences as lists of their
respective building blocks.

Let's get a quick feel for this system and how it prevents some of the weirdness
from before:

{% highlight haskell %}
ghci> let mydna = [Guanosine, Adenine, Thymine, Thymine, Adenine, Cytosine, Adenine]
ghci> let mypro = [Alanine, Leucine, Glycine, Tyrosine, Leucine, Serine, Tryptophan]
ghci> show mydna
"[Guanosine,Adenine,Thymine,Thymine,Adenine,Cytosine,Adenine]"
ghci> show mypro
"[Alanine,Leucine,Glycine,Tyrosine,Leucine,Serine,Tryptophan]"
ghci> mydna ++ mypro -- Lists are homogenous, we can't mix types in a sequence
--    Couldn't match type ‘AminoAcid’ with ‘Nucleotide’
--    Expected type: [Nucleotide]
--      Actual type: [AminoAcid]
--    In the second argument of ‘(++)’, namely ‘mypro’
--    In the expression: mydna ++ mypro
ghci> Thymine : mydna -- Prepend Thymine
[Thymine,Guanosine,Adenine,Thymine,Thymine,Adenine,Cytosine,Adenine]
{% endhighlight %}

### An aside about replication

Fidelitous (error-free) replication is such a trivial problem that we needn't
overthink it. The function which always gives back the value it was given is
known as the [identity function](http://mathworld.wolfram.com/IdentityFunction.html).
The replication of a sequence can then be performed, if there is indeed a need to do
so, by using the Haskell identity function `id`, which is quite simple:

{% highlight haskell %}
id :: a -> a
id x = x
{% endhighlight %}

So if we cared to, an alias for `id` could be made like so:

{% highlight haskell %}
replication = id
{% endhighlight %}

The story of replication probably won't get interesting again until we consider
infidelity (scandalous!).

### Re-implementation of Complementation... Proclamation

This is pretty short and sweet. 

{% highlight haskell %}
complementNucleotide :: Nucleotide -> Nucleotide
complementNucleotide Adenine   = Thymine
complementNucleotide Cytosine  = Guanosine
complementNucleotide Guanosine = Cytosine
complementNucleotide Thymine   = Adenine

complement :: NucleicSeq -> NucleicSeq
complement s = map complementNucleotide s

reverseComplement = reverse . complement
{% endhighlight %}

`complementNucleotide` expresses the `Nucleotide`-wise rules of complementation
and `complement` maps it over a list to generate the complementary list.
`reverseComplement` uses function composition to create a function that returns
the reverse result of the `complement` function (putting it into the standard 5'
to 3' orientation). Put in practice:

{% highlight haskell %}
ghci> complement [Thymine, Adenine, Cytosine, Guanosine]
[Adenine,Thymine,Guanosine,Cytosine]
ghci> reverseComplement [Thymine, Adenine, Cytosine, Guanosine]
[Cytosine,Guanosine,Thymine,Adenine]
ghci> reverseComplement [Glutamate]  -- Disallowed
--    Couldn't match expected type ‘Nucleotide’
--                with actual type ‘AminoAcid’
--    In the expression: Glutamate
--    In the first argument of ‘reverseComplement’, namely ‘[Glutamate]’
{% endhighlight %}

### Translation

The first thing I'll do as I tackle translation once more is create a new data
type to represent a codon.

{% highlight haskell %}
data Codon = Codon Nucleotide Nucleotide Nucleotide
  deriving (Show)
{% endhighlight %}

It's important to observe here that a `Codon` type value is constructed using
three `Nucleotide` type values. Using this definition enforces the "shape" of a
codon as a three-membered, ordered collection of `Nucleotide`s.

The next important job is to redo our `geneticCode` function from earlier to
work with the new `Codon` type. There are ways of writing this
function that require less typing (great for saving time and avoiding typos) but
are somewhat more arcane (less great for starting out), so I'll wait before
demonstrating such.

{% highlight haskell %}
geneticCode :: Codon -> AminoAcid
geneticCode (Codon Adenine   Adenine   Adenine  ) = Lysine
geneticCode (Codon Adenine   Adenine   Cytosine ) = Asparagine
geneticCode (Codon Adenine   Adenine   Guanosine) = Lysine
geneticCode (Codon Adenine   Adenine   Thymine  ) = Asparagine
geneticCode (Codon Adenine   Cytosine  Adenine  ) = Threonine
geneticCode (Codon Adenine   Cytosine  Cytosine ) = Threonine
geneticCode (Codon Adenine   Cytosine  Guanosine) = Threonine
geneticCode (Codon Adenine   Cytosine  Thymine  ) = Threonine
geneticCode (Codon Adenine   Guanosine Adenine  ) = Arginine
geneticCode (Codon Adenine   Guanosine Cytosine ) = Serine
geneticCode (Codon Adenine   Guanosine Guanosine) = Arginine
geneticCode (Codon Adenine   Guanosine Thymine  ) = Serine
geneticCode (Codon Adenine   Thymine   Adenine  ) = Isoleucine
geneticCode (Codon Adenine   Thymine   Cytosine ) = Isoleucine
geneticCode (Codon Adenine   Thymine   Guanosine) = Methionine
geneticCode (Codon Adenine   Thymine   Thymine  ) = Isoleucine
geneticCode (Codon Cytosine  Adenine   Adenine  ) = Glutamine
geneticCode (Codon Cytosine  Adenine   Cytosine ) = Histidine
geneticCode (Codon Cytosine  Adenine   Guanosine) = Glutamine
geneticCode (Codon Cytosine  Adenine   Thymine  ) = Histidine
geneticCode (Codon Cytosine  Cytosine  Adenine  ) = Proline
geneticCode (Codon Cytosine  Cytosine  Cytosine ) = Proline
geneticCode (Codon Cytosine  Cytosine  Guanosine) = Proline
geneticCode (Codon Cytosine  Cytosine  Thymine  ) = Proline
geneticCode (Codon Cytosine  Guanosine Adenine  ) = Arginine
geneticCode (Codon Cytosine  Guanosine Cytosine ) = Arginine
geneticCode (Codon Cytosine  Guanosine Guanosine) = Arginine
geneticCode (Codon Cytosine  Guanosine Thymine  ) = Arginine
geneticCode (Codon Cytosine  Thymine   Adenine  ) = Leucine
geneticCode (Codon Cytosine  Thymine   Cytosine ) = Leucine
geneticCode (Codon Cytosine  Thymine   Guanosine) = Leucine
geneticCode (Codon Cytosine  Thymine   Thymine  ) = Leucine
geneticCode (Codon Guanosine Adenine   Adenine  ) = Glutamate
geneticCode (Codon Guanosine Adenine   Cytosine ) = Aspartate
geneticCode (Codon Guanosine Adenine   Guanosine) = Glutamate
geneticCode (Codon Guanosine Adenine   Thymine  ) = Aspartate
geneticCode (Codon Guanosine Cytosine  Adenine  ) = Alanine
geneticCode (Codon Guanosine Cytosine  Cytosine ) = Alanine
geneticCode (Codon Guanosine Cytosine  Guanosine) = Alanine
geneticCode (Codon Guanosine Cytosine  Thymine  ) = Alanine
geneticCode (Codon Guanosine Guanosine Adenine  ) = Glycine
geneticCode (Codon Guanosine Guanosine Cytosine ) = Glycine
geneticCode (Codon Guanosine Guanosine Guanosine) = Glycine
geneticCode (Codon Guanosine Guanosine Thymine  ) = Glycine
geneticCode (Codon Guanosine Thymine   Adenine  ) = Valine
geneticCode (Codon Guanosine Thymine   Cytosine ) = Valine
geneticCode (Codon Guanosine Thymine   Guanosine) = Valine
geneticCode (Codon Guanosine Thymine   Thymine  ) = Valine
geneticCode (Codon Thymine   Adenine   Adenine  ) = Stop -- Ochre
geneticCode (Codon Thymine   Adenine   Cytosine ) = Tyrosine
geneticCode (Codon Thymine   Adenine   Guanosine) = Stop -- Amber 
geneticCode (Codon Thymine   Adenine   Thymine  ) = Tyrosine
geneticCode (Codon Thymine   Cytosine  Adenine  ) = Serine
geneticCode (Codon Thymine   Cytosine  Cytosine ) = Serine
geneticCode (Codon Thymine   Cytosine  Guanosine) = Serine
geneticCode (Codon Thymine   Cytosine  Thymine  ) = Serine
geneticCode (Codon Thymine   Guanosine Adenine  ) = Stop -- Opal
geneticCode (Codon Thymine   Guanosine Cytosine ) = Cysteine
geneticCode (Codon Thymine   Guanosine Guanosine) = Tryptophan
geneticCode (Codon Thymine   Guanosine Thymine  ) = Cysteine
geneticCode (Codon Thymine   Thymine   Adenine  ) = Leucine
geneticCode (Codon Thymine   Thymine   Cytosine ) = Phenylalanine
geneticCode (Codon Thymine   Thymine   Guanosine) = Leucine
geneticCode (Codon Thymine   Thymine   Thymine  ) = Phenylalanine
{% endhighlight %}

*Don't pity my poor typing fingers, I just copied the old function and used a few
vim substitutions to make the new one* Now I need to find a way to use this
function so that I can convert a `NucleicSeq` to `ProteinSeq`; since I'm being
stricter about using codon representation and `NucleicSeq` doesn't directly
contain `Codon`s, it's slightly more complicated.

Let's start at the top with what our `translate` function should be:

{% highlight haskell %}
translate :: NucleicSeq -> Protein
translate s = map geneticCode $ asCodons s
{% endhighlight %}

`asCodons` is a hypothetical function that takes a `NucleicSeq` and produces
a `[Codon]` so that we can map `geneticCode` over it to make a `ProteinSeq`.
Now to fill in that hypothetical:

{% highlight haskell %}
asCodons :: NucleicSeq -> [Codon]
asCodons s = catMaybes $ map toCodons $ chunksOf 3 s

toCodons :: NucleicSeq -> Maybe Codon
toCodons (f:s:t:[]) = Just (Codon f s t)  -- Just Codon if list has three elements
toCodons _ = Nothing  -- Nothing if anything else
{% endhighlight %}

`asCodons` makes use of `chunksOf 3` to turn its input sequence, `s`, from
`[Nucleotide]` into `[[Nucleotide]]` where the inner lists have a length of 3.
The last list may have a length of less than 3 if `s` has a number of elements
not evenly divisible by 3.
That caveat presents a problem in that a `Codon` may only be constructed if we
have the full 3 elements. To handle this problem we make use of `Maybe`, a
data type frequently used to work with the concept of possible failure. A value
of type `Maybe a` may be either `Nothing` (failure) or `Just a` (success).

`toCodons` was written with pattern matching so that if it gets a list with a length
other than 3, it yields `Nothing` indicating failure. If it succeeds, it
constructs a `Codon` and returns it "wrapped" in `Just`. When `asCodons` passes
the result of `map toCodons $ chunksOf 3 s` (which has the type `[Maybe Codon]`)
to `catMaybes`, it filters out all of the `Nothing`s that might be in the list
and unwraps the values contained in `Just`s.

Thus our sequence gets neatly interpreted as codons while ignoring possible
trailing nucleotides before being translated to amino acids. Let's put it to
some use:

{% highlight haskell %}
ghci> asCodons [Adenine, Thymine]
[]
ghci> asCodons [Adenine, Thymine, Cytosine]
[Codon Adenine Thymine Cytosine]
ghci> translate [Cytosine, Adenine, Thymine, Thymine, Guanosine, Guanosine]
[Histidine,Tryptophan]
ghci> translate [Cytosine, Adenine, Thymine, Thymine, Guanosine, Guanosine, Adenine]
[Histidine,Tryptophan]`
layout{% endhighlight %}


