#!/bin/bash
rm -f lex.yy.c
rm -f y.output y.tab.h y.tab.c

lex lex.l
yacc -d yacc.y
gcc lex.yy.c y.tab.c

rm -f lex.yy.c
rm -f y.output y.tab.h y.tab.c

./a.out

rm a.out
