#!/bin/bash
lex basic.l
yacc -d yacc.y
gcc lex.yy.c y.tab.c
./a.out
