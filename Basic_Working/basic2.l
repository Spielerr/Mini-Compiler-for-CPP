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
	#include "y.tab.h"
	extern YYSTYPE yylval;
	#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}

%option yylineno

%%
^{ws}*"#".*							{ /* not do anything for preprocessor lines */ }

^"using namespace std;"				{ ; }

	/* for all single characters - including operators */
"+"|"-"|"*"|"/"|"%"|"<"|">"|"="|"!"|";"|","|"."|"["|"]"|"{"|"}"|")"|"("|"|"|"&"|"^"	{ yylval = yytext[0]; return (int)yytext[0]; }
{ws}+							{ /* Throw away whitespace */ }
.								{ printf("Invalid character\n"); }

	/* for all multiple characters operators */
"<="							{ yylval = strdup(yytext); return (T_REL_OP_LESS_THAN_EQUAL);  }
">="							{ yylval = strdup(yytext); return (T_REL_OP_GREATER_THAN_EQUAL);  }
"=="							{ yylval = strdup(yytext); return (T_REL_OP_EQUAL);  }
"!="							{ yylval = strdup(yytext); return (T_REL_OP_NOT_EQUAL);  }
"&&"							{ yylval = strdup(yytext); return (T_LOG_OP_AND);  }
"||"							{ yylval = strdup(yytext); return (T_LOG_OP_OR);  }
"<<"							{ yylval = strdup(yytext); return (T_IO_INSERTION);  }
">>"							{ yylval = strdup(yytext); return (T_IO_EXTRACTION);  }
"::"							{ yylval = strdup(yytext); return (T_SCOPE_RESOLUTION); }


	/* for all keywords */
"return"						{ yylval = strdup(yytext); return (T_RETURN);  }
"void"							{ yylval = strdup(yytext); return T_TYPE_VOID; }
"class"							{ yylval = strdup(yytext); return T_TYPE_CLASS; }
"public"						{ yylval = strdup(yytext); return T_ACCESS_PUBLIC; }
"private"						{ yylval = strdup(yytext); return T_ACCESS_PRIVATE; }
"protected"						{ yylval = strdup(yytext); return T_ACCESS_PROTECTED; }
"int"							{ yylval = strdup(yytext); return (T_TYPE_INT);  }
"float"							{ yylval = strdup(yytext); return (T_TYPE_FLOAT);  }
"double"						{ yylval = strdup(yytext); return (T_TYPE_DOUBLE);  }
"bool"							{ yylval = strdup(yytext); return (T_TYPE_BOOL);  }
"if"							{ yylval = strdup(yytext); return (T_CONSTRUCT_IF);  }
"else"							{ yylval = strdup(yytext); return (T_CONSTRUCT_ELSE); }
"for"							{ yylval = strdup(yytext); return (T_CONSTRUCT_FOR); }
"cin"							{ yylval = strdup(yytext); return (T_IO_COUT); }
"cout"							{ yylval = strdup(yytext); return (T_IO_CIN); }
"printf"						{ yylval = strdup(yytext); return (T_IO_PRINTF); }
"scanf"							{ yylval = strdup(yytext); return (T_IO_SCANF); }
"break"							{ yylval = strdup(yytext); return (T_JUMP_BREAK); }
"continue"						{ yylval = strdup(yytext); return (T_JUMP_CONTINUE); }
"exit"							{ yylval = strdup(yytext); return (T_JUMP_EXIT); }


	/* for all literals */
{digit}+						{ yylval = (int)(strdup(yytext)); return T_NUMBER_LITERAL;}
"true"|"false"					{ yylval = strdup(yytext); return T_BOOL_LITERAL; }

{character_lit}\'					{ yylval = (char)(yytext[1]); return T_CHAR_LITERAL; }
{character_lit}\'|{character_lit}	{ printf("Incomplete character literal\n"); }

{string_lit}\"						{ yylval = strdup(yytext); return T_STRING_LITERAL; };
{string_lit}\\|{string_lit}			{ printf("Incomplete string literal\n"); }



	/* comments */
"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	{ return T_COMMENT; }	
"/*"([^*]|(\*+[^*/]))*				{ printf("ERROR - Non-terminating comment\n"); }

{identifier}					{ if(yyleng > 31)
								  {
									printf("Length of identifier is greater than 31 characters, truncating it to the first 31 characters only\n"); 
									char *temp = (char*)malloc(sizeof(char) * 32);
									for(int i=0;i<32;i++)
									{
										temp[i] = yytext[i];
									}
									yylval = strdup(temp);
									} 
									else
									{
										yylval = strdup(temp);
									}
									return T_IDENTIFIER; 
								}

{exp_number}					{ yylval = atof(yytext); return T_TYPE_DOUBLE; }

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


	/* 
	check if [] in arrays is being handled properly : treating [, ] as single char operators and whats inside as identifier or literal
	*/