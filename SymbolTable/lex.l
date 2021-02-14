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

^{ws}*"#".*						{ /* not do anything for preprocessor lines */}
^"using namespace std;"						{ printf("using token\n"); }

\n 								{ ++lineno; columnno = 0; }



	"int"							{ return (T_TYPE_INT); columnno += yyleng; }
	"float"							{ return (T_TYPE_FLOAT); columnno += yyleng; }
	"if"							{ return (T_CONSTRUCT_IF); columnno += yyleng; }
	"else"							{ return (T_CONSTRUCT_ELSE); columnno += yyleng; }
	"for"							{ return (T_CONSTRUCT_FOR); columnno += yyleng; }
	"cout"							{ return (T_IO_COUT); columnno += yyleng; }
	"+"								{ return (T_OP_ADD); columnno += yyleng; }
	"-"								{ return (T_OP_SUBTRACT); columnno += yyleng; }
	"<<"							{ return (T_IO_EXTRACTION); columnno += yyleng; }
	">>"							{ return (T_IO_INSERTION); columnno += yyleng; }
	"("								{ return (T_PARAN_OPEN); columnno += yyleng; }
	")"								{ return (T_PARAN_CLOSE); columnno += yyleng; }
	";"								{ return (T_SEMI_COLON); columnno += yyleng; }
	":"								{ return (T_COLON); columnno += yyleng; }
	"{"								{ return (T_BLOCK_START); columnno += yyleng; }
	"}"								{ return (T_BLOCK_END); columnno += yyleng; }
	","								{ return (T_COMMA); columnno += yyleng; }
	"="								{ return T_OP_ASSIGNMENT;}
	"=="							{ return T_REL_OP_EQUAL;}
	"return"						{ return (T_RETURN); columnno += yyleng; }
	{digit}+						{ return T_NUMBER_LITERAL;}

"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	{ printf("comment\n"); }	
"/*"([^*]|(\*+[^*/]))*				{printf("ERROR - Non-terminating comment\n");}



{identifier}					{yylval = strdup(yytext); columnno += yyleng; return T_IDENTIFIER; }

{ws}+							{ /* Throw away whitespace */ }

.								{ yylval = strdup(yytext); }

%%

int yywrap(void)
{
	return 1;
}
