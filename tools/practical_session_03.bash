# Part 1

## Exercice 1
### Q1:
paste train.words.txt train.tags.txt -d"_"  | perl -pe 's/^_//g' > train.decoder.col.txt

## Exercice 2
### Q1: 
cat train.tags.txt | perl -pe 's/^$/<s>/g' | perl -pe 's/\s+/ /g' | perl -pe 's/<s>/\n/g' > train.tags-lm.txt
### Q2: 
cat train.decoder.col.txt | perl -pe 's/^$/<s>/g' | perl -pe 's/\s+/ /g' | perl -pe 's/<s>/\n/g' > train.decoder.txt
### Q3: 
cat test.tags.txt | perl -pe 's/^$/<s>/g' | perl -pe 's/\s+/ /g' | perl -pe 's/<s>/\n/g' > test.tags.ref.txt
### Q4: 
cat test.words.txt | perl -pe 's/^$/<s>/g' | perl -pe 's/\s+/ /g' | perl -pe 's/<s>/\n/g' > test.words.src.txt

## Exercice 3
### Q1: 
cat train.decoder.txt | perl -pe 's/\s+/\n/g' | sort -u | python3 create_dictionary.py > train.decoder.dic
cat train.words.txt test.words.txt | perl -pe 's/\s+/\n/g' | sort -u | python3 create_dictionary.py > words.dic
cat train.tags.txt test.tags.txt | perl -pe 's/\s+/\n/g' | sort -u | python3 create_dictionary.py > tags.dic

### Q2: One token per line associated with one unique ID. An "<epsilon>" token is added.

# Part 2
## Exercice 1
### Q1:
farcompilestrings -symbols=train.decoder.dic --keep_symbols=1 train.decoder.txt > train.decoder.far 
### Q2: farcompilestrings enables to compile a plain text into an automata

## Exercice 2
### Q1:
ngramcount --order=2 train.decoder.far > train.decoder.counts 
### Q2: ngramcount like ngram-count from SRILM extract counts from a compiled automata

## Exercice 3
### Q1:
ngrammake --method="kneser_ney" train.decoder.counts | fstclosure > train.decoder.lm 
### Q2: ngrammake train LM from counts ; fstclosure enable the closure of a finite state automata => rolling back from the beginning.
### Q3: kneser_ney is a function to enable the Kneser-Ney smoothing approach described in "Reinhard Kneser and Hermann Ney. 1995. Improved backing-off for M-gram language modeling. In Proc. of ICASSP, pages 181–184"

## Exercice 4
### Q1:
fstprint --isymbols=train.decoder.dic --osymbols=train.decoder.dic train.decoder.lm > train.decoder.lm.fst 
### Q2: fstprint enable to print in text the LM trained 
### Q3: col1 1 : from state ; col1 2 : to state ; col1 3 : input symbol ; col1 4 : output symbol ; col1 5 : transition score (-log prob) ; 
### Q4: 
cat train.decoder.lm.fst | perl -pe 's/_/\t/g' | cut -f 1,2,3,4,7 >  train.decoder.prob.fst
cat train.decoder.lm.fst | perl -pe 's/_/\t/g' | cut -f 1,2,3,4 >  train.decoder.noprob.fst

# Part 3
## Exercice 1
### Q1:
farcompilestrings -symbols=tags.dic --keep_symbols=1 train.tags-lm.txt > train.tags-lm.far 
## Exercice 1
### Q2:
ngramcount --order=5 train.tags-lm.far > train.tags-lm.counts 
## Exercice 1
### Q3:
ngrammake --method="kneser_ney" train.tags-lm.counts | fstclosure > train.tags-lm.fsa 
## Exercice 1
### Q4:
fstprint --isymbols=tags.dic --osymbols=tags.dic train.tags-lm.fsa > train.tags-lm.fst 

# Part 4
## Exercice 1
### Q1:
cut -f1 -d' ' words.dic | python3 txt2fst.py | awk '{if (NF>1) print $1"\t"$2"\t"$3"\t<eps>\t10000"; else print $0}' > filler.words-tags.fst
fstcompile --isymbols=words.dic --osymbols=tags.dic filler.words-tags.fst | fstclosure > filler.words-tags.fsa
cut -f1 -d' ' tags.dic | python3 txt2fst.py | awk '{if (NF>1) print $1"\t"$2"\t"$3"\t<eps>\t10000"; else print $0}' > filler.tags.fst
fstcompile --isymbols=tags.dic --osymbols=tags.dic filler.tags.fst | fstclosure > filler.tags.fsa
### Q2: fstcompile for compiling automata, fstclosure, to "close" the automata.

## Exercice 2
### Q1:
fstcompile --isymbols=words.dic --osymbols=tags.dic filler.words-tags.fst | fstrmepsilon | fstclosure > filler.words-tags.fsa
fstcompile --isymbols=tags.dic --osymbols=tags.dic filler.tags.fst | fstrmepsilon | fstclosure > filler.tags.fsa
fstcompile --isymbols=words.dic --osymbols=tags.dic train.decoder.prob.fst | fstclosure > train.decoder.prob.fsa
fstunion train.decoder.prob.fsa filler.words-tags.fsa | fstclosure > train.decoder.filler.prob.fsa
fstunion train.tags-lm.fsa filler.tags.fsa | fstclosure > train.tags-lm.filler.prob.fsa 
### Q2: fstunion to "concatenate" two automata
### Q3:
fstcompile --isymbols=words.dic --osymbols=tags.dic train.decoder.noprob.fst | fstclosure > train.decoder.noprob.fsa
fstunion train.decoder.noprob.fsa filler.words-tags.fsa | fstclosure > train.decoder.filler.noprob.fsa
fstunion train.tags-lm.fsa filler.tags.fsa | fstclosure > train.tags-lm.filler.noprob.fsa 


## Exercice 3
### Q1:
echo "In January , he accepted the position of vice chairman of Carlyle Group , a merchant banking concern . " | python3 txt2fst.py | fstcompile --isymbols=words.dic --acceptor=true - first_test.fsa
fstcompose first_test.fsa train.decoder.filler.prob.fsa | fstshortestpath | fstrmepsilon > lineoutput.fsa
fstprint -isymbols=words.dic --osymbols=tags.dic lineoutput.fsa | python3 ordertxtfst.py > lineoutput.txt
fstdraw -isymbols=words.dic --osymbols=tags.dic lineoutput.fsa | dot -Tps > lineoutput.ps
### Q2: fstdraw enable to draw the automata into the postdscript format
### Q3: lineoutput.txt contains hypothesis 1 word with 1 tag with the score
### Q4:
fstcompose first_test.fsa train.decoder.filler.prob.fsa | fstarcsort | fstcompose - train.tags-lm.filler.prob.fsa | fstshortestpath | fstrmepsilon | tee lineoutput_full_decoding.fsa | fstprint --isymbols=words.dic --osymbols=tags.dic - | python3 ordertxtfst.py > lineoutput_full_decoding.txt
fstdraw -isymbols=words.dic --osymbols=tags.dic lineoutput_full_decoding.fsa | dot -Tps > lineoutput_full_decoding.ps
### Q5: yes a bit better
fstcompile --isymbols=words.dic --osymbols=tags.dic filler.words-tags.fst | fstrmepsilon | fstclosure > filler.words-tags.fsa
fstcompile --isymbols=tags.dic --osymbols=tags.dic filler.tags.fst | fstrmepsilon | fstclosure > filler.tags.fsa
fstcompile --isymbols=words.dic --osymbols=tags.dic train.decoder.noprob.fst | fstclosure > train.decoder.noprob.fsa
fstunion train.decoder.noprob.fsa filler.words-tags.fsa | fstclosure > train.decoder.filler.noprob.fsa
fstunion train.tags-lm.fsa filler.tags.fsa | fstclosure > train.tags-lm.filler.noprob.fsa 
fstcompile --isymbols=words.dic --osymbols=tags.dic train.decoder.noprob.fst | fstclosure > train.decoder.noprob.fsa
fstunion train.decoder.noprob.fsa filler.words-tags.fsa | fstclosure > train.decoder.filler.noprob.fsa
fstunion train.tags-lm.fsa filler.tags.fsa | fstclosure > train.tags-lm.filler.noprob.fsa 




