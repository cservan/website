echo "Creating train and test corpus"
for i in *.txt 
do 
	lang=`basename $i .txt`
	head -n 10000 $i > train.$lang
	tail -n 10000 $i > test.$lang
done

echo "creating counts dans vocab"
for lang in bg cs da de el en es et fi fr hu it lt lv nl pl pt ro sk sl sv
do
	echo -n "$lang "
	ngram-count -order 3 -text train.$lang -write ${lang}3g.bo -write-vocab $lang.voc 
done
echo ""

echo "Creating global vocab"
for lang in bg cs da de el en es et fi fr hu it lt lv nl pl pt ro sk sl sv
do
	cat $lang.voc
done > global.voc

echo "traing LM"
for lang in bg cs da de el en es et fi fr hu it lt lv nl pl pt ro sk sl sv
do
	ngram-count -read ${lang}3g.bo -lm ${lang}3g.BO -gt2min 1 -gt3min 2 -vocab global.voc &
done
wait
echo "creating model for fasttext"
rm fasttext_train.txt
rm fasttext_test.txt
for lang in bg cs da de el en es et fi fr hu it lt lv nl pl pt ro sk sl sv
do
	cat train.$lang | perl -pe "s/^/__label__$lang /g" >> fasttext_train.txt
	cat test.$lang | perl -pe "s/^/__label__$lang /g" >> fasttext_test.txt
done 
fasttext supervised -input fasttext_train.txt -output fasttext_train.model -dim 50 
fasttext predict fasttext_train.model.bin fasttext_test.txt > results.EMB.txt
fasttext test fasttext_train.model.bin fasttext_test.txt > results.EMB.scores.txt

echo "create the result file which contains the confusion matrix"

echo -n "	" > results.LM.txt
for header in bg cs da de el en es et fi fr hu it lt lv nl pl pt ro sk sl sv
do
echo -n "$header	" >> results.LM.txt
done
echo "" >> results.LM.txt

echo "fill the result file with the confusion matrix"

for lang1 in bg cs da de el en es et fi fr hu it lt lv nl pl pt ro sk sl sv
do 
	echo -n "$lang1	" >> results.LM.txt
	echo -n "$lang1 "
	for lang2 in bg cs da de el en es et fi fr hu it lt lv nl pl pt ro sk sl sv
	do
		res=`ngram -lm ${lang1}3g.BO -ppl test.$lang2 | perl -pe 's/\s+/\n/g' | grep ppl -A1 | tail -n 1 | perl -pe 's/\s+//g'`
		echo -n "$res " >> results.LM.txt
	done 
	echo "" >> results.LM.txt
	echo ""
done

