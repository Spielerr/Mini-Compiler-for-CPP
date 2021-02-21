#!/bin/bash
rm -f lex.yy.c
rm -f y.output yy.tab.h yy.tab.c
lex lex.l
yacc -d -v yacc.y
gcc -g lex.yy.c y.tab.c
./a.out
