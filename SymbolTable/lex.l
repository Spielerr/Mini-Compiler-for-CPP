ws								[ \f\v\t]
digit							[0-9]
hex								[0-9A-Fa-f]
letter							[A-Z_a-z]

non_digit						{letter}
identifier						({non_digit}({non_digit}|{digit})*)

character_lit					(L?\'([^\'\\\n]|\\.)*)
character_literal				({character_lit}\')

string_lit						(L?\"([^\"\\\n]|\\.)*)
string_literal					({string_lit}\")

exp_number						(\.?{digit}({digit}|{non_digit}|[eE][-+]|\.)*)


%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include "y.tab.h"
	

	int lineno = 1;
	int columnno = 1;
%}

%%

^{ws}*"#".*						{ /* not do anything for preprocessor lines */ printf("%s\n", yytext); }
^"using namespace std;"						{ printf("using token\n"); }

\n 								{ ++lineno; columnno = 0; }



	"int"							{  printf("%s\n", yytext); return (T_TYPE_INT); columnno += yyleng; }
	"float"							{  printf("%s\n", yytext); return (T_TYPE_FLOAT); columnno += yyleng; }
	"if"							{  printf("%s\n", yytext); return (T_CONSTRUCT_IF); columnno += yyleng; }
	"else"							{  printf("%s\n", yytext); return (T_CONSTRUCT_ELSE); columnno += yyleng; }
	"for"							{  printf("%s\n", yytext); return (T_CONSTRUCT_FOR); columnno += yyleng; }
	"cout"							{  printf("%s\n", yytext); return (T_IO_COUT); columnno += yyleng; }
	"+"								{  printf("%s\n", yytext); return (T_OP_ADD); columnno += yyleng; }
	"-"								{  printf("%s\n", yytext); return (T_OP_SUBTRACT); columnno += yyleng; }
	"<<"							{  printf("%s\n", yytext); return (T_IO_EXTRACTION); columnno += yyleng; }
	">>"							{  printf("%s\n", yytext); return (T_IO_INSERTION); columnno += yyleng; }
	"("								{  printf("%s\n", yytext); return (T_PARAN_OPEN); columnno += yyleng; }
	")"								{  printf("%s\n", yytext); return (T_PARAN_CLOSE); columnno += yyleng; }
	";"								{  printf("%s\n", yytext); return (T_SEMI_COLON); columnno += yyleng; }
	":"								{  printf("%s\n", yytext); return (T_COLON); columnno += yyleng; }
	"{"								{  printf("%s\n", yytext); return (T_BLOCK_START); columnno += yyleng; }
	"}"								{  printf("%s\n", yytext); return (T_BLOCK_END); columnno += yyleng; }
	","								{  printf("%s\n", yytext); return (T_COMMA); columnno += yyleng; }
	"="								{  printf("%s\n", yytext); return T_OP_ASSIGNMENT;}
	"=="							{  printf("%s\n", yytext); return T_REL_OP_EQUAL;}
	"return"						{  printf("%s\n", yytext); return (T_RETURN); columnno += yyleng; }
	{digit}+						{  printf("%s\n", yytext); return T_NUMBER_LITERAL;}

"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	{ printf("comment\n"); }	
"/*"([^*]|(\*+[^*/]))*				{printf("ERROR - Non-terminating comment\n");}



{identifier}					{ printf("%s\n", yytext); yylval = strdup(yytext); columnno += yyleng; return T_IDENTIFIER; }

{ws}+							{ /* Throw away whitespace */ }

.								{ yylval = strdup(yytext); }

%%

int yywrap(void)
{
	return 1;
}
