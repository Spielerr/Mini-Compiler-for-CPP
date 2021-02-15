#!/bin/bash
rm -f lex.yy.c
lex basic.l
yacc -d -v yacc.y
gcc -g lex.yy.c y.tab.c
./a.out
