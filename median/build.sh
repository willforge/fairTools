# 

perl tree.pl --dbug --cnt=30 --zm 36 --seed=54321 | tee tree.log;
dot -Tpng tree.dot -o tree.png; 
pandoc -t html -f markdown -o README.html README.md
