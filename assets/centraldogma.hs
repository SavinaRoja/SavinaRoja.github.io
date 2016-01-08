--A collection of the code presented in "Haskell Meets the Central Dogma"
--By Paul Barton

type Element = Char            -- A unitary object
type Seq     = [Element]       -- An ordered collection of Elements

type DNABase = Char            -- DNA variant of Element
type DNASeq  = [DNABase]       -- DNA variant of Sequence

type RNABase = Char            -- RNA variant of Element
type RNASeq  = [RNABase]       -- RNA variant of Sequence

type AminoAcid  = Char         -- Protein variant of Element
type ProteinSeq = [AminoAcid]  -- Protein variant of Sequence

--Replication

--function that gives whatever sequence element it receives
replicateBase :: Element -> Element
replicateBase x = x

--function that maps the replicateBase function over its input
replication :: Seq -> Seq
replication s = map replicateBase s

--a function to tell us if the replication was faithful (True) or not (False)
validReplication :: Seq -> Bool
validReplication s = s == replication s

--Complementation

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

--Reverse Complementation
--function composition quickly gets us the reverse complement functions
reverseComplementDNA :: DNASeq -> DNASeq
reverseComplementDNA = reverse . complementDNA

reverseComplementRNA :: RNASeq -> RNASeq
reverseComplementRNA = reverse . complementRNA

--Transcription and Reverse Transcription
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
