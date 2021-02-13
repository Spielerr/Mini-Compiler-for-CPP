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
	// #define YYSTYPE char *
	

	int lineno = 1;
	int columnno = 1;
%}

%%

^{ws}*"#".*						{ /* not do anything for preprocessor lines */ printf("hash\n"); }
^"using namespace std;"						{ printf("using token\n"); }
	/* {character_lit}\'				{ LEX_CHARACTER_TOKEN(yytext, yyleng-1); };
	{character_lit}\\				{ ERRMSG("End of line assumed to terminate character with trailing escape.");
									LEX_CHARACTER_TOKEN(yytext, yyleng-1); };
	{character_lit}					{ ERRMSG("End of line assumed to terminate character.");
									LEX_CHARACTER_TOKEN(yytext, yyleng); };

	{string_lit}\"					{ LEX_STRING_TOKEN(yytext, yyleng-1); };
	{string_lit}\\					{ ERRMSG("End of line assumed to terminate string with trailing escape.");
									LEX_STRING_TOKEN(yytext, yyleng-1); };
	{string_lit}					{ ERRMSG("End of line assumed to terminate string.");
									LEX_STRING_TOKEN(yytext, yyleng); }; */
\n 								{ ++lineno; columnno = 0; }

	/* keywords */



	"int"							{ printf("int token\n"); return (T_TYPE_INT); columnno += yyleng; }
	"float"							{ return (T_TYPE_FLOAT); columnno += yyleng; }
	"if"							{ return (T_CONSTRUCT_IF); columnno += yyleng; }
	"+"								{ return (T_OP_ADD); columnno += yyleng; }
	"-"								{ return (T_OP_SUBTRACT); columnno += yyleng; }
	"<<"							{ return (T_IO_COUT); columnno += yyleng; }
	">>"							{ return (T_IO_CIN); columnno += yyleng; }
	"("								{ printf("paren open token\n");return (T_PARAN_OPEN); columnno += yyleng; }
	")"								{ printf("paren close token\n");return (T_PARAN_CLOSE); columnno += yyleng; }
	";"								{ return (T_SEMI_COLON); columnno += yyleng; }
	":"								{ return (T_COLON); columnno += yyleng; }
	"{"								{ return (T_BLOCK_START); columnno += yyleng; }
	"}"								{ return (T_BLOCK_END); columnno += yyleng; }
	","								{ return (T_COMMA); columnno += yyleng; }
	"="								{ printf("equal to \n"); return T_OP_ASSIGNMENT;}
	"return"						{ return (T_RETURN); columnno += yyleng; }
	{digit}+						{ printf("constant\n"); return T_NUMBER_LITERAL;}

	/* multiple character operators */


	/* comments */
"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	{ printf("comment\n"); return T_COMMENT; }	
"/*"([^*]|(\*+[^*/]))*				{printf("ERROR - Non-terminating comment\n");}



{identifier}					{ printf("main token\n"); yylval = strdup(yytext); columnno += yyleng; return T_IDENTIFIER; }

{ws}+							{ /* Throw away whitespace */ }

.								{ yylval = strdup(yytext); }

%%

int yywrap(void)
{
	return 1;
}

/* int main()
{
	yyin = fopen("test_basic.cpp","r");
	yylex();
} */
