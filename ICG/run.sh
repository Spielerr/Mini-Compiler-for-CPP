#!/bin/bash
# Usage: ./run.sh <FILENAME>
rm -f lex.yy.c
rm -f y.output y.tab.h y.tab.c

lex lex.l
yacc -d all_yacc.y
gcc lex.yy.c y.tab.c

rm -f *.o
rm -f lex.yy.c
rm -f y.output y.tab.h y.tab.c

./a.out $1

# rm a.out