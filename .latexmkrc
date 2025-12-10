# Latexmk configuration for mpl-dis

# Use pdflatex with shell escape for TikZ externalization
# Increase main memory to 8MB (8000000 words) to handle large inline data tables
$pdflatex = 'pdflatex -interaction=nonstopmode -shell-escape --main-memory=8000000 %O %S';

# Enable bibtex for bibliography processing
$bibtex_use = 2;

# Ensure proper cleanup
@generated_exts = (@generated_exts, 'auxlock', 'figlist', 'makefile', 'bbl', 'tdo', 'pyg');
