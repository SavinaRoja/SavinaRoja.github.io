---
layout: post
title: Haskell Revisits the Central Dogma
---

This post will recap the previous,
[Haskell Meets the Central Dogma](http://savinaroja.github.io/2016/01/11/haskell-meets-the-central-dogma),
with the intent to introduce [algebraic data
types](https://en.wikipedia.org/wiki/Algebraic_data_type).
Using these will allow
refinement of the design and gradually present some more features of Haskell.
The first in this series, [A Review of the Central Dogma](http://savinaroja.github.io/2015/11/17/a-review-of-the-central-dogma/),
reviews the biological context of the functions presented.

[Here's my code for this post](/assets/centraldogma_algebraic.hs).

### Limitations of type synonyms

I previously began by declaring some type synonyms in my code so that I could
then differentiate between functions meant to operate with DNA (`DNASeq`),
RNA (`RNASeq`), or protein (`ProteinSeq`). The type synonyms were all equivalent
to Haskell's `String` type: `[Char]`. Here is that code for quick reference:

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
since these declarations are fundamentally the same, we are still able to do
some weird things that it might be best to prevent:

{% highlight haskell %}
ghci> let mydna = "GATTACA" :: DNASeq
ghci> let mypro = "ALGLYSW" :: ProteinSeq
ghci> mydna ++ mypro  -- we can concatenate, but what kind of molecule is that?!
"GATTACAALGYLSW"
ghci> :t mydna ++ mypro  -- result type of concatenation in ghci?
mydna ++ mypro :: [DNABase]
ghci> :t mypro ++ mydna  -- it depends on the order!
mypro ++ mydna :: [AminoAcid]
ghci> :t reverseTranslate
reverseTranslate :: ProteinSeq -> [[DNACodon]]
ghci> reverseTranslate mydna  -- The base Chars in DNA can interpreted as valid amino acids
[["GGA","GGC","GGG","GGT"],["GCA","GCC","GCG","GCT"],["ACA","ACC","ACG","ACT"],["ACA","ACC","ACG","ACT"],["GCA","GCC","GCG","GCT"],["TGC","TGT"],["GCA","GCC","GCG","GCT"]]
{% endhighlight %}

The takeaway lesson here is that while using `type` to create synonyms can help
with code readability where you'd like to tersely annotate something with a
comment (it's like laying a comment on top of your type), they don't
meaningfully change anything below the surface.
Let's explore using some algebraic data types to represent our
data which will simultaneously improve the performance, clarity, and rigor of
the code.

## Algebraic types with `data`

So let's begin by intoducing some custom data types to represent nucleic acid
sequences and protein sequences. I will not preserve the conceptual distinction
between DNA and RNA at the type level as I did before; because they are 
directly correlated (to the extent that we are concerned here), it makes sense
to think of DNA and RNA as simply *different representations of the same
underlying nucleic acid sequence*. This is a common convention in
bioinformatics, and it will help to keep reduce the amount and complexity of our
code. I will not cover ambiguous nucleotide or amino acids here.

{% highlight haskell %}
--A Nucleotide may be either Adenine, Cytosine, Guanosine, or Thymine/Uracil
--Thymine is Uracil in RNA
data Nucleotide = Adenine | Cytosine | Guanosine | Thymine
  deriving (Eq, Show)

--An AminoAcid may be one of the 20 standard amino acids, or a Stop
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
data types have their own unique value constructors. The type synonyms
`NucleicSeq` and `ProteinSeq` suggest my intent to work with these sequences as
lists of their respective subunits. 

Let's get a quick feel for this system:

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

Because lists in Haskell are homogenous structures, we are now sure that we
cannot compile some code in which we've accidentally tried to combine the types
into one value. Since the types are distinct, it is now clear to both the reader
and the compiler that `translate :: NucleicSeq -> ProteinSeq` uses
`[Nucleotide]` as its input type.

It looks like working with this system could get a little cumbersome in terms of
typing: `"GATTACA"` was much easier to type than `[Guanosine, Adenine, Thymine,
Thymine, Adenine, Cytosine, Adenine]`. Let's take a moment to write some helpful
functions for nicely inputting to and outputting from this model:

{% highlight haskell %}
charToNuc :: Char -> Nucleotide
charToNuc 'A' = Adenine
charToNuc 'C' = Cytosine
charToNuc 'G' = Guanosine
charToNuc 'T' = Thymine
charToNuc 'U' = Thymine
charToNuc  x  = error $ x:" is not a valid nucleotide character"

stringToNucleicSeq :: String -> NucleicSeq
stringToNucleicSeq = map charToNuc

dnaSymbol :: Nucleotide -> Char
dnaSymbol Adenine   = 'A'
dnaSymbol Cytosine  = 'C'
dnaSymbol Guanosine = 'G'
dnaSymbol Thymine   = 'T'

rnaSymbol :: Nucleotide -> Char
rnaSymbol Thymine   = 'U'
rnaSymbol x = dnaSymbol x

representAsDNA :: NucleicSeq -> String
representAsDNA = map dnaSymbol

representAsRNA :: NucleicSeq -> String
representAsRNA = map rnaSymbol

aaSymbolTable = [(Alanine    , 'A'), (Arginine      , 'R'), (Asparagine , 'N'),
                 (Aspartate  , 'D'), (Cysteine      , 'C'), (Glutamate  , 'E'),
                 (Glutamine  , 'Q'), (Glycine       , 'G'), (Histidine  , 'H'),
                 (Isoleucine , 'I'), (Leucine       , 'L'), (Lysine     , 'K'),
                 (Methionine , 'M'), (Phenylalanine , 'F'), (Proline    , 'P'),
                 (Serine     , 'S'), (Threonine     , 'T'), (Tryptophan , 'W'),
                 (Tyrosine   , 'Y'), (Valine        , 'V'), (Stop       , '*')]

representProtein :: ProteinSeq -> String
representProtein = map fetchAA where
                    fetchAA x = fromJust $ lookup x aaSymbolTable

stringToProteinSeq :: String -> ProteinSeq
stringToProteinSeq = map fetchSymbol where
                       fetchSymbol x = fromJust $ lookup x $ invert aaSymbolTable
                       invert = map swap
                       swap (x, y) = (y, x)
{% endhighlight%}

So now where it is more convenient we have the ability to make sequences from
`String`s and to produce `String`s from our sequences like so:

{% highlight haskell%}
ghci> let nseq = stringToNucleicSeq "GATTACA"
ghci> representAsRNA nseq
"GAUUACA"
ghci> let pseq = stringToProteinSeq "AVSLGL"
ghci> pseq
[Alanine,Valine,Serine,Leucine,Glycine,Leucine]
{% endhighlight %}

### Re-implementation of Complementation

With this new data model in place, let's implement the central dogma functions
agin. Since replication is so trivial (I'll say a little more on this at the
end), I'll move right into complementation. This is exactly the same
as before but with `Nucleotide` values instead of `Char` values.

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
ghci> complement $ stringToNucleicSeq "GATTACA" 
[Cytosine,Thymine,Adenine,Adenine,Thymine,Guanosine,Thymine]
ghci> reverseComplement $ stringToNucleicSeq "GATTACA"
[Thymine,Guanosine,Thymine,Adenine,Adenine,Thymine,Cytosine]
ghci> reverseComplement [Glutamate]  -- Disallowed
--    Couldn't match expected type ‘Nucleotide’
--                with actual type ‘AminoAcid’
--    In the expression: Glutamate
--    In the first argument of ‘reverseComplement’, namely ‘[Glutamate]’
{% endhighlight %}

### Translation

The previous implementation for the `geneticCode` function was written to
pattern match on strings of three characters which representing a codon. If the
function was given a string of a different length and/or a string containing an
invalid character, it would produce `'-'` to denote that it is not meaningful.

Here is the first two lines of my previous definition of `geneticCode`:

{% highlight haskell %}
geneticCode :: RNACodon -> AminoAcid
geneticCode "AAA" = 'K'  -- Lysine
{% endhighlight %}

Here is a direct re-implementation using the new algebraic types.

{% highlight haskell %}
geneticCode :: NucleicSeq -> AminoAcid
geneticCode [Adenine, Adenine, Adenine] = Lysine
{% endhighlight %}

In the former there is no guarantee whether the characters in the input
are valid while in the latter we have that assurance. Yet in both functions
there is the possibility for lists of incorrect length; I would like to fix that
so I will formalize a codon data type and write the function to fit.

{% highlight haskell %}
data Codon = Codon Nucleotide Nucleotide Nucleotide
  deriving (Show)
{% endhighlight %}

Now I have a new data type called `Codon` whose values can be created using the
type constructor `Codon` (same name in this case, but it's good to remember the
distinction between types and their constructors) which takes three and only
three `Nucleotide` values and holds them as an ordered triplet.

This provides the basis of the new definition of `geneticCode`:

{% highlight haskell%}
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

Thanks to some help from vim, I didn't have to invest much time into retyping
that. Now to create the new `translate` function:

{% highlight haskell %}
--Convert a [Nucleotide] to [Codon], trimming possible remainder
asCodons :: NucleicSeq -> [Codon]
asCodons s = mapMaybe toCodon (chunksOf 3 s) where
               toCodon [i,j,k] = Just (Codon i j k)
               toCodon    _    = Nothing

translate :: NucleicSeq -> ProteinSeq
translate s = map geneticCode $ asCodons s 
{% endhighlight %}

`translate :: NucleicSeq -> ProteinSeq` makes use of `asCodons` to convert the 
nucleotides to codons and maps `geneticCode` over the result. `asCodons` does
the conversion by chunking the input into triplet lists whose values are then
used to construct a `Codon` in `toCodon`. If `toCodon` gets a list of length
other than 3, because the number of input `Nucleotide` values was an integer
multiple of 3, it produces a `Nothing`. The `mapMaybe` in `asCodons` discards
`Nothing` values and extracts the values from the `Just`.

Let's try the functions out:

{% highlight haskell %}
ghci> asCodons [Adenine, Thymine]
[]
ghci> asCodons [Adenine, Thymine, Cytosine]
[Codon Adenine Thymine Cytosine]
ghci> asCodons [Adenine, Thymine, Cytosine, Guanosine]
[Codon Adenine Thymine Cytosine]
ghci> translate $ stringToNucleicSeq "GATTACA"
[Aspartate,Tyrosine]
{% endhighlight %}

To give it a more in depth test application, I'll adjust `simpleSeqGetter` and
`translateCodingRegion` to then translate the mRNA from the before.

{% highlight haskell %}
simpleSeqGetter :: FilePath -> IO NucleicSeq
simpleSeqGetter fp = do
  unmunged <- readFile fp
  let linedropped = drop 1 $ lines unmunged
  return $ foldr ((++) . stringToNucleicSeq) ([] :: NucleicSeq) linedropped

translateCodingRegion :: NucleicSeq -> ProteinSeq
translateCodingRegion s = takeWhile (Stop /=) $ dropWhile (Methionine/=) $ translate s
{% endhighlight %}

{% highlight haskell %}
ghci> myseq <- simpleSeqGetter "lipocalin1_mRNA.fa"
ghci> representProtein $ translateCodingRegion myseq
"MKPLLLAVSLGLIAALQAHHLLASDEEIQDVSGTWYLKAMTVDREFPEMNLESVTPMTLTTLEGGNLEAKVTMLISGRCQEVKAVLEKTDEPGKYTADGGKHVAYIIRSHVKDHYIFYCEGELHGKPVRGVKLVGRDPKNNLEALEDFEKAAGARGLSTESILIPRQSETCSPGSD"
{% endhighlight %}

### Reverse Translation

The first key to the puzzle of computing reverse translation will be a
function that maps each `AminoAcid` to its corresponding list of coding
`Codon`s. I'll also define a convenience function `mkCodon` ("make Codon") to
help keep the lines a little shorter.

{% highlight haskell %}
mkCodon :: String -> Codon
mkCodon [f,s,t] = Codon (charToNuc f) (charToNuc s) (charToNuc t)
mkCodon _ = error "Incorrect number of characters to make Codon"

codonsFor :: AminoAcid -> [Codon]
codonsFor Alanine       = [mkCodon "GCA", mkCodon "GCC", mkCodon "GCG", mkCodon "GCT"]
codonsFor Cysteine      = [mkCodon "TGC", mkCodon "TGT"]
codonsFor Aspartate     = [mkCodon "GAC", mkCodon "GAT"]
codonsFor Glutamate     = [mkCodon "GAA", mkCodon "GAG"]
codonsFor Phenylalanine = [mkCodon "TTC", mkCodon "TTT"]
codonsFor Glycine       = [mkCodon "GGA", mkCodon "GGC", mkCodon "GGG", mkCodon "GGT"]
codonsFor Histidine     = [mkCodon "CAC", mkCodon "CAT"]
codonsFor Isoleucine    = [mkCodon "ATA", mkCodon "ATC", mkCodon "ATT"]
codonsFor Lysine        = [mkCodon "AAA", mkCodon "AAG"]
codonsFor Leucine       = [mkCodon "CTA", mkCodon "CTC", mkCodon "CTG", mkCodon "CTT", mkCodon "TTA", mkCodon "TTG"]
codonsFor Methionine    = [mkCodon "ATG"]
codonsFor Asparagine    = [mkCodon "AAC", mkCodon "AAT"]
codonsFor Proline       = [mkCodon "CCA", mkCodon "CCC", mkCodon "CCG", mkCodon "CCT"]
codonsFor Glutamine     = [mkCodon "CAA", mkCodon "CAG"]
codonsFor Arginine      = [mkCodon "AGA", mkCodon "AGG", mkCodon "CGA", mkCodon "CGC", mkCodon "CGG" , mkCodon "CGT"]
codonsFor Serine        = [mkCodon "AGC", mkCodon "AGT", mkCodon "TCA", mkCodon "TCC", mkCodon "TCG" , mkCodon "TCT"]
codonsFor Threonine     = [mkCodon "ACA", mkCodon "ACC", mkCodon "ACG", mkCodon "ACT"]
codonsFor Valine        = [mkCodon "GTA", mkCodon "GTC", mkCodon "GTG", mkCodon "GTT"]
codonsFor Tryptophan    = [mkCodon "TGG"]
codonsFor Tyrosine      = [mkCodon "TAC", mkCodon "TAT"]
codonsFor Stop          = [mkCodon "TAA", mkCodon "TAG", mkCodon "TGA"]
{% endhighlight %}

The reverse translation operation can just be the application of `codonsFor` to
each `AminoAcid` in a `ProteinSeq`:

{% highlight haskell %}
reverseTranslate :: ProteinSeq -> [[Codon]]
reverseTranslate = map codonsFor
{% endhighlight %}

{% highlight haskell %}
ghci> reverseTranslate [Phenylalanine, Isoleucine, Glutamine, Glutamine]
[[Codon Thymine Thymine Cytosine,Codon Thymine Thymine Thymine],[Codon Adenine Thymine Adenine,Codon Adenine Thymine Cytosine,Codon Adenine Thymine Thymine],[Codon Cytosine Adenine Adenine,Codon Cytosine Adenine Guanosine],[Codon Cytosine Adenine Adenine,Codon Cytosine Adenine Guanosine]]
{% endhighlight %}

Now let's create `uniqueCodings :: ProteinSeq -> [NucleicSeq]` which will
produce all of the possible nucleic acid sequences which could code for the
protein. I'll have to add an intermediate step to unpack the `Nucleotide`
components from a `Codon`.
Beware: the size of the output increases exponentially with the
size of the input (unless you only have `Methionine` or `Tryptophan` in the
sequence).

{% highlight haskell %}
-- Unpack the Codons in [Codon] to get [NucleicSeq]
unCodons :: [Codon] -> [NucleicSeq]
unCodons = map unCodon where
             unCodon (Codon f s t) = [f,s,t]

--produce all the ways the protein sequence could be encoded
uniqueCodings :: ProteinSeq -> [NucleicSeq]
uniqueCodings s = foldr (combine . unCodons) ([[]] :: [NucleicSeq]) $ reverseTranslate s where
                    combine xs ys = [ x ++ y | x <- xs, y <- ys]

--Count up all the ways the protein sequence could be encoded
uniqueCodingsCount :: ProteinSeq -> Integer
uniqueCodingsCount s = foldr ((*) . genericLength) 1 $ reverseTranslate s
{% endhighlight %}

Let's do a few tests:

{% highlight haskell %}
ghci> uniqueCodingsCount ([] :: ProteinSeq)
1
ghci> uniqueCodingsCount [Alanine]
4
ghci> uniqueCodingscount [Alanine, Aspartate]
8
ghci> map representAsDNA $ uniqueCodings [Alanine, Aspartate]
["GCAGAC","GCAGAT","GCCGAC","GCCGAT","GCGGAC","GCGGAT","GCTGAC","GCTGAT"]
{% endhighlight%}

With the appropriate adjustment to `constrainedUniqueCodings` I can repeat my
previous work on finding out whether a certain `NucleicSeq` can be found among
the reverse translated `NucleicSeq`s from a given `ProteinSeq`.

{% highlight haskell %}
constrainedUniqueCodings :: ProteinSeq -> NucleicSeq -> [NucleicSeq]
constrainedUniqueCodings s constraint = filter (isInfixOf constraint) $ uniqueCodings s
{% endhighlight %}

{% highlight haskell %}
ghci> let ecoRISeq = stringToNucleicSeq "GAATTC"
ghci> let ecoRVSeq = stringToNucleicSeq "GATATC"
ghci> let proteinSegment = stringToProteinSeq "ALGYLSW"
ghci> map representAsDNA$ constrainedUniqueCodings proteinSegment ecoRISeq
[]
ghci> map representAsDNA $ constrainedUniqueCodings proteinSegment ecoRISeq
["GCACTAGGATATCTA","GCACTAGGATATCTC", ... ,"GCTTTGGGATATCTG","GCTTTGGGATATCTT"]
{% endhighlight %}

### What about replication?

Fidelitous (error-free) replication is such a trivial problem that we needn't
hardly think about it. The function which always gives back the value it was
given is known as the [identity function](http://mathworld.wolfram.com/IdentityFunction.html).
The replication of a sequence can then be expressed by using the Haskell
identity function `id`, which is:

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
