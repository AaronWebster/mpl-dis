TARGET=writeup
all:
	latex $(TARGET).tex
	dvips -o $(TARGET).ps $(TARGET).dvi
clean:
	find . -name "*.aux" -exec rm '{}' \;
	find . -name "*.toc" -exec rm '{}' \;
	find . -name "*.lof" -exec rm '{}' \;
	find . -name "*.lot" -exec rm '{}' \;
	find . -name "*.log" -exec rm '{}' \;
pdf:
	dvipdf $(TARGET).dvi
