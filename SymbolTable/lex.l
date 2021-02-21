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
exp_number						[+-]?{digit}+(\.{digit}+)?([eE][+-]?{digit}+)?


%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define YYSTYPE char *
	#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
	#include "y.tab.h"	
%}

%option yylineno

%%
^{ws}*"#".*							{ /* not do anything for preprocessor lines */ }

^"using namespace std;"				{ ; }

	/* for all single characters - including operators */
"+"|"-"|"*"|"/"|"%"|"<"|">"|"="|"!"|";"|","|"."|"["|"]"|"{"|"}"|")"|"("|"|"|"&"|"^"	{ return (int)(*yytext); }
{ws}+							{ /* Throw away whitespace */ }

	/* for all multiple characters operators */
"<="							{  return (T_REL_OP_LESS_THAN_EQUAL);  }
">="							{  return (T_REL_OP_GREATER_THAN_EQUAL);  }
"=="							{  return (T_REL_OP_EQUAL);  }
"!="							{  return (T_REL_OP_NOT_EQUAL);  }
"&&"							{  return (T_LOG_OP_AND);  }
"||"							{  return (T_LOG_OP_OR);  }
"<<"							{  return (T_IO_INSERTION);  }
">>"							{  return (T_IO_EXTRACTION);  }
"::"							{  return (T_SCOPE_RESOLUTION); }
"++"							{  return (T_OP_INCREMENT); }
"--"							{  return (T_OP_DECREMENT); }

	/* for all keywords */
"return"						{  return (T_RETURN);  }
"void"							{  return T_TYPE_VOID; }
"class"							{  return T_TYPE_CLASS; }
"public"						{  return T_ACCESS_PUBLIC; }
"private"						{  return T_ACCESS_PRIVATE; }
"protected"						{  return T_ACCESS_PROTECTED; }
"int"							{  return (T_TYPE_INT);  }
"float"							{  return (T_TYPE_FLOAT);  }
"double"						{  return (T_TYPE_DOUBLE);  }
"bool"							{  return (T_TYPE_BOOL);  }
"if"							{  return (T_CONSTRUCT_IF);  }
"else"							{  return (T_CONSTRUCT_ELSE); }
"for"							{  return (T_CONSTRUCT_FOR); }
"cin"							{  return (T_IO_CIN); }
"cout"							{  return (T_IO_COUT); }
"printf"						{  return (T_IO_PRINTF); }
"scanf"							{  return (T_IO_SCANF); }
"break"							{  return (T_JUMP_BREAK); }
"continue"						{  return (T_JUMP_CONTINUE); }
"exit"							{  return (T_JUMP_EXIT); }
"string"						{  return (T_TYPE_STRING); }
"char"							{  return (T_TYPE_CHAR); }
"true"						{ yylval = strdup(yytext); return T_BOOL_LITERAL; }
"false"						{ yylval = strdup(yytext); return T_BOOL_LITERAL; }

{identifier}					{ if(yyleng < 32) yylval = strdup(yytext); 
								  else {
									  printf("Error : Identifier is too long, cutting it down to first 31 characters\n");
									  char dummy[32];
									  strncpy(dummy, yytext, 31);
									  dummy[31] = '\0';
									  yylval = strdup(dummy);
								  }
								  return T_IDENTIFIER; 
								}


	/* for all integer literals */
{digit}+							{ yylval = strdup(yytext); return T_NUMBER_LITERAL;}
	/* "true"|"false"					{ yylval = strdup(yytext); return T_BOOL_LITERAL; } */

{character_lit}\'					{ yylval = strdup(yytext); return T_CHAR_LITERAL; }
{character_lit}\'|{character_lit}	{ printf("Incomplete character literal\n"); }

{string_lit}\"						{ yylval = strdup(yytext); return T_STRING_LITERAL; };
{string_lit}\\|{string_lit}			{ printf("Incomplete string literal\n"); }




	/* comments */
"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	{ ; }	
"/*"([^*]|(\*+[^*/]))*				{ printf("ERROR - Non-terminating comment\n"); }

{exp_number}					{ snprintf(yylval, 50, "%f", atof(yytext)); return T_NUMBER_LITERAL; }
\n								{ ; }

.								{ printf("invalid character --> %s\n", yytext); }
%%

int yywrap(void)
{
	return 1;
}