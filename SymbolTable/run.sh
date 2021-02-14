#!/bin/bash
lex lex.l
yacc -d -v yacc.y
gcc lex.yy.c y.tab.c
./a.out
