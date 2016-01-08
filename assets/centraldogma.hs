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
complementDNABase _ = _     -- do not change unexpected characters

--and by sequence
complementDNA :: DNASeq -> DNASeq
complementDNA s = map complementDNABase s

--complementarity for RNA, by nucleotide
complementRNABase :: RNABase -> RNABase
complementRNABase 'A' = 'U'
complementRNABase 'C' = 'G'
complementRNABase 'G' = 'C'
complementRNABase 'U' = 'A'
complementRNABase _ = _     -- do not change unexpected characters

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

