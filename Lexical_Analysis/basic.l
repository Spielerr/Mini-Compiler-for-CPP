	/* whitespace */
ws								[ \f\v\t]
	/* digits */
digit							[0-9]
	/* hexadecimal characters */
hex								[0-9A-Fa-f]
	/* alphabets and underscore */
letter							[A-Z_a-z]

	/* for identifiers */
non_digit						{letter}
identifier						({non_digit}({non_digit}|{digit})*)

	/* character literals */
character_lit					(L?\'([^\'\\\n]|\\.)*)
character_literal				({character_lit}\')

	/* string literals */
string_lit						(L?\"([^\"\\\n]|\\.)*)
string_literal					({string_lit}\")

	/* handling special cases of floating point numbers */
exp_number						(\.?{digit}({digit}|{non_digit}|[eE][-+]|\.)*)


%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include "y.tab.h"

	int lineno = 1;
	int columnno = 1;

	void yyerror(char*);
%}

%%

^{ws}*"#".*						{ /* not do anything for preprocessor lines */ }

\n 								{ ++lineno; columnno = 0; }

	/* keywords */


"while"							{ return (T_WHILE); columnno += yyleng; }
"int"							{ return (T_TYPE_INT); columnno += yyleng; }
"float"							{ return (T_TYPE_FLOAT); columnno += yyleng; }
"if"							{ return (T_CONSTRUCT_IF); columnno += yyleng; }
"+"								{ return (T_OP_ADD); columnno += yyleng; }
"-"								{ return (T_OP_SUBTRACT); columnno += yyleng; }
"<<"							{ return (T_IO_COUT); columnno += yyleng; }
">>"							{ return (T_IO_CIN); columnno += yyleng; }
"("								{ return (T_PARAN_OPEN); columnno += yyleng; }
")"								{ return (T_PARAN_CLOSE); columnno += yyleng; }
";"								{ return (T_SEMI_COLON); columnno += yyleng; }
":"								{ return (T_COLON); columnno += yyleng; }
"{"								{ return (T_SQ_OPEN); columnno += yyleng; }
"}"								{ return (T_SQ_CLOSE); columnno += yyleng; }
","								{ return (T_COMMA); columnno += yyleng; }
"return"						{ return (T_RETURN); columnno += yyleng; }


	/* multiple character operators */
"::"							{ return (T_SCOPE); columnno += yyleng; }
"<<"							{ return (T_SHL); columnno += yyleng; }
">>"							{ return (T_SHR); columnno += yyleng; }
"=="							{ return (T_EQ); columnno += yyleng; }
"!="							{ return (T_NE); columnno += yyleng; }
"<="							{ return (T_LE); columnno += yyleng; }
">="							{ return (T_GE); columnno += yyleng; }
"&&"							{ return (T_LOG_AND); columnno += yyleng; }
"||"							{ return (T_LOG_OR); columnno += yyleng; }
"++"							{ return (T_INC); columnno += yyleng; }
"--"							{ return (T_DEC); columnno += yyleng; }
"->*"							{ return (T_ARROW_STAR); columnno += yyleng; }
"->"							{ return (T_ARROW); columnno += yyleng; }
".*"							{ return (T_DOT_STAR); columnno += yyleng; }
"+="							{ return (T_ASS_ADD); columnno += yyleng; }
"-="							{ return (T_ASS_SUB); columnno += yyleng; }
"*="							{ return (T_ASS_MUL); columnno += yyleng; }
"/="							{ return (T_ASS_DIV); columnno += yyleng; }
"%="							{ return (T_ASS_MOD); columnno += yyleng; }
"^="							{ return (T_ASS_XOR); columnno += yyleng; }
"&="							{ return (T_ASS_AND); columnno += yyleng; }
"|="							{ return (T_ASS_OR); columnno += yyleng; }
">>="							{ return (T_ASS_SHR); columnno += yyleng; }
"<<="							{ return (T_ASS_SHL); columnno += yyleng; }

	/* comments */
"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	{num_comments++; return COMMENT;}	
"/*"([^*]|(\*+[^*/]))*				{printf("ERROR - Non-terminating comment\n");}

{exp_number}					{ /*exp_number_fn(yytext, yyleng);*/ return T_DOUBLE;
										// need to handle this function
										 }

{identifier} | "main"					{ yylval = strdup(yytext); return T_IDENTIFIER; columnno += yyleng;}

{ws}+							{ /* Throw away whitespace */ }

.								{ yylval = strdup(yytext); return T_INVALID; }

%%

int yywrap(void)
{
	return 1;
}

int main()
{
	extern FILE *yyin;
	yyin = fopen("test.c", "r");
	yylex();
	/* printf("Number of one line comments:%d\n", num_comments); */
	return 0;
}
