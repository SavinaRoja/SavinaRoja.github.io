--A collection of the code presented in "Haskell Meets the Central Dogma"
--By Paul Barton

import Data.List
import Data.List.Split

type Element = Char            -- A unitary object
type Seq     = [Element]       -- An ordered collection of Elements

type DNABase = Char            -- DNA variant of Element
type DNASeq  = [DNABase]       -- DNA variant of Sequence

type RNABase = Char            -- RNA variant of Element
type RNASeq  = [RNABase]       -- RNA variant of Sequence

type AminoAcid  = Char         -- Protein variant of Element
type ProteinSeq = [AminoAcid]  -- Protein variant of Sequence

-----------------
-- Replication --
-----------------

--function that gives whatever sequence element it receives
replicateBase :: Element -> Element
replicateBase x = x

--function that maps the replicateBase function over its input
replication :: Seq -> Seq
replication s = map replicateBase s

--a function to tell us if the replication was faithful (True) or not (False)
validReplication :: Seq -> Bool
validReplication s = s == replication s

---------------------
-- Complementation --
---------------------

--complementarity for DNA, by nucleotide
complementDNABase :: DNABase -> DNABase
complementDNABase 'A' = 'T'
complementDNABase 'C' = 'G'
complementDNABase 'G' = 'C'
complementDNABase 'T' = 'A'
complementDNABase x = x     -- do not change unexpected characters

--and by sequence
complementDNA :: DNASeq -> DNASeq
complementDNA s = map complementDNABase s

--complementarity for RNA, by nucleotide
complementRNABase :: RNABase -> RNABase
complementRNABase 'A' = 'U'
complementRNABase 'C' = 'G'
complementRNABase 'G' = 'C'
complementRNABase 'U' = 'A'
complementRNABase x = x     -- do not change unexpected characters

--and by sequence
complementRNA :: RNASeq -> RNASeq
complementRNA s = map complementRNABase s

--Same as the function above, but written with guards. I think simple pattern
--matching is cleaner as is, without guards, but it's here as example
--complementDNABase :: DNABase -> DNABase
--complementDNABase x
--  | x == 'A'  = 'T'
--  | x == 'C'  = 'G'
--  | x == 'G'  = 'C'
--  | x == 'T'  = 'A'
--  | otherwise = x

--Testing functions, to make sure double execution produces the input
testComplementDNA :: DNASeq -> Bool
testComplementDNA s = s == (complementDNA $ complementDNA s)

testComplementRNA :: RNASeq -> Bool
testComplementRNA s = s == (complementRNA $ complementRNA s)

--Reverse Complementation
--function composition quickly gets us the reverse complement functions
reverseComplementDNA :: DNASeq -> DNASeq
reverseComplementDNA = reverse . complementDNA

reverseComplementRNA :: RNASeq -> RNASeq
reverseComplementRNA = reverse . complementRNA

--------------------------------------------
--Transcription and Reverse Transcription --
--------------------------------------------

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

--functions to test that transcription and reverse transcription functions are
--properly symmetrical; keep in mind that it's only meant to work on valid input
pingPong :: DNASeq -> Bool
pingPong s = s == (reverseTranscribe $ transcribe s)

thereAndBackAgain :: RNASeq -> Bool
thereAndBackAgain s = s == (transcribe $ reverseTranscribe s)

-----------------
-- Translation --
-----------------

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

--translation is done by mapping the geneticCode over the codons
translate :: RNASeq -> ProteinSeq
translate s = map geneticCode $ chunksOf 3 s

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

