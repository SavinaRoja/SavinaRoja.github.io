--A collection of the code presented in "Haskell Meets the Central Dogma"
--This time making use of algebraic data types
--By Paul Barton

import Data.List
import Data.List.Split
import Data.Maybe

--Note that Thymine is Uracil in RNA context
data Nucleotide = Adenine | Cytosine | Guanosine | Thymine
  deriving (Eq, Show)

--The 20 standard amino acids and Stop
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

-----------------
-- Replication --
-----------------

replication = id

---------------------
-- Complementation --
---------------------

complementNucleotide :: Nucleotide -> Nucleotide
complementNucleotide Adenine   = Thymine
complementNucleotide Cytosine  = Guanosine                                                   
complementNucleotide Guanosine = Cytosine
complementNucleotide Thymine   = Adenine

complement :: NucleicSeq -> NucleicSeq
complement = map complementNucleotide

reverseComplement = reverse . complement

-----------------
-- Translation --
-----------------

data Codon = Codon Nucleotide Nucleotide Nucleotide
  deriving (Show)

-- Conveniences --
--Convert a Char to a Nucleotide
--This is forgiving, it will not care if U and T are mixed
--One could easily write unforgiving versions if so inclined
charToNuc :: Char -> Nucleotide
charToNuc 'A' = Adenine
charToNuc 'C' = Cytosine
charToNuc 'G' = Guanosine
charToNuc 'T' = Thymine
charToNuc 'U' = Thymine
charToNuc  x  = error $ x:" is not a valid nucleotide character" 

--Convert a string of three characters to a codon
mkCodon :: String -> Codon
mkCodon [f,s,t] = Codon (charToNuc f) (charToNuc s) (charToNuc t)
mkCodon _ = error "Incorrect number of characters to make string"

--Could consider using mkCodon in this function as well, though it's just simple
--enough that I think it's best serving as an example of pattern matching
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

asCodons :: NucleicSeq -> [Codon]
asCodons s = mapMaybe toCodons (chunksOf 3 s)

toCodons :: NucleicSeq -> Maybe Codon
toCodons [f,s,t] = Just (Codon f s t)
toCodons _ = Nothing

translate :: NucleicSeq -> ProteinSeq
translate s = map geneticCode $ asCodons s

-------------------------
-- Reverse Translation --
-------------------------

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

reverseTranslateToCodons :: ProteinSeq -> [[Codon]]
reverseTranslateToCodons = map codonsFor

--That was super simple, but it will take a little more work to recapture our
--previous function: uniqueCodings :: ProteinSeq -> [NucleicSeq]
--Let's babystep through it

--A deconstructor for Codon
unCodon :: Codon -> NucleicSeq
unCodon (Codon f s t) = [f,s,t]

--Apply the deconstructor to a list of Codons
unCodons :: [Codon] -> [NucleicSeq]
unCodons = map unCodon

--Compare to reverseTranslateToCodons
reverseTranslate :: ProteinSeq -> [[NucleicSeq]]
reverseTranslate = map (unCodons . codonsFor)

--Count up all the ways the protein sequence could be coded for
uniqueCodingsCount :: ProteinSeq -> Integer
uniqueCodingsCount s = foldr ((*) . genericLength) 1 $ reverseTranslateToCodons s

--produce all the ways the protein sequence could be coded for
uniqueCodings :: ProteinSeq -> [NucleicSeq]
uniqueCodings s = foldl combine ([[]] :: [NucleicSeq]) $ reverseTranslate s where
                    combine xs ys = [ x ++ y | x <- xs, y <- ys]

constrainedUniqueCodings :: ProteinSeq -> NucleicSeq -> [NucleicSeq]
constrainedUniqueCodings s constraint = filter (isInfixOf constraint) $ uniqueCodings s

----------
-- Misc --
----------

dnaSymbol :: Nucleotide -> Char
dnaSymbol Adenine   = 'A'
dnaSymbol Cytosine  = 'C'
dnaSymbol Guanosine = 'G'
dnaSymbol Thymine   = 'T'

rnaSymbol :: Nucleotide -> Char
rnaSymbol Adenine   = 'A'
rnaSymbol Cytosine  = 'C'
rnaSymbol Guanosine = 'G'
rnaSymbol Thymine   = 'U'

representAsDNA :: NucleicSeq -> String
representAsDNA = map dnaSymbol

representAsRNA :: NucleicSeq -> String
representAsRNA = map rnaSymbol


stringToNucleicSeq :: String -> NucleicSeq
stringToNucleicSeq = map charToNuc

--A very simple, non-general function to get the sequence
simpleSeqGetter :: FilePath -> IO NucleicSeq
simpleSeqGetter fp = do
  unmunged <- readFile fp
  let linedropped = drop 1 $ lines unmunged
  return $ foldr ((++) . stringToNucleicSeq) ([] :: NucleicSeq) linedropped

--Function to drop everything before the first start codon and everything after the first
--stop codon after the start codon
translateCodingRegion :: NucleicSeq -> ProteinSeq
translateCodingRegion s = takeWhile (Stop /=) $ dropWhile (Methionine/=) $ translate s

