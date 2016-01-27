--A collection of the code presented in "Haskell Meets the Central Dogma"
--This time making use of algebraic data types
--By Paul Barton

import Data.List
import Data.List.Split
import Data.Maybe

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

type DNA = [Nucleotide]
type Protein = [AminoAcid]

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

complement :: DNA -> DNA
complement s = map complementNucleotide s

reverseComplementDNA = reverse . complement

-----------------
-- Translation --
-----------------

data Codon = Codon Nucleotide Nucleotide Nucleotide

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
geneticCode (Codon Guanosine Thymine   Cytosine )  = Valine
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
--geneticCode x = x

codonify :: DNA -> [Codon]
codonify s = catMaybes $ map toCodons $ chunksOf 3 s

toCodons :: DNA -> Maybe Codon
toCodons (f:s:t:[]) = Just (Codon f s t)
toCodons _ = Nothing

translate :: DNA -> Protein
translate s = map geneticCode $ codonify s

{-|
--composing a function to translate DNA by first transcribing it, then translating
translateDNA :: DNASeq -> ProteinSeq
translateDNA = translate . transcribe

--A very simple, non-general function to get the sequence
simpleSeqGetter :: FilePath -> IO Seq
simpleSeqGetter fp = do
  unmunged <- readFile fp
  let linedropped = drop 1 $ lines unmunged
  return $ foldr (++) "" linedropped

--Function to drop everything before the first start codon and everything after the first
--stop codon after the start codon
translateCodingRegion :: RNASeq -> ProteinSeq
translateCodingRegion s = takeWhile ('*'/=) $ dropWhile ('M'/=) $ translateDNA s

-------------------------
-- Reverse Translation --
-------------------------

--20 standard amino acids, Stop codons, and catch-all line
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

--mapping codonsFor over a protein sequence
reverseTranslate :: ProteinSeq -> [[DNACodon]]
reverseTranslate s  = map codonsFor s

--count up all the ways the protein sequence could be coded for in DNA or RNA
uniqueCodingsCount :: ProteinSeq -> Integer
uniqueCodingsCount s = foldr (\x ->  (*) $ genericLength x) 1 $ reverseTranslate s

--produce all the ways the protein sequence could be coded for
uniqueCodings s = foldl combine [""] $ reverseTranslate s where
                     combine xs ys = [ x ++ y | x <- xs, y <- ys]

--produce only the possible coding DNA sequences that contain the constraint
constrainedUniqueCodings :: ProteinSeq -> DNASeq -> [DNASeq]
constrainedUniqueCodings s constraint = filter (isInfixOf constraint) $ uniqueCodings s

-}
