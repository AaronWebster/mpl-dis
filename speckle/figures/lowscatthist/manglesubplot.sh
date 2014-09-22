#!/usr/bin/bash
# mangles subplots produced with mat2tikz or whatever
#
# change the dimensions accordingly.

for FILE in *.tex
do
	tac $FILE | sed -e '0,/9cm/s/9cm/5cm/' | tac > ${FILE%%.tex}_mod.tex
done
