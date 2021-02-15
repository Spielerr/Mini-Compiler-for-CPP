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
	// #define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}

%option yylineno

%%
^{ws}*"#".*							{ /* not do anything for preprocessor lines */ }

^"using namespace std;"				{ ; }

	/* for all single characters - including operators */
"+"|"-"|"*"|"/"|"%"|"<"|">"|"="|"!"|";"|","|"."|"["|"]"|"{"|"}"|")"|"("		{ printf("%s\n", yytext); return (int)yytext[0]; }
	/*  .							{ printf("Invalid character\n"); } */

	/* for all multiple characters operators */
"<="							{ printf("%s\n", yytext); return (T_REL_OP_LESS_THAN_EQUAL);  }
">="							{ printf("%s\n", yytext); return (T_REL_OP_GREATER_THAN_EQUAL);  }
"=="							{ printf("%s\n", yytext); return (T_REL_OP_EQUAL);  }
"!="							{ printf("%s\n", yytext); return (T_REL_OP_NOT_EQUAL);  }
"&&"							{ printf("%s\n", yytext); return (T_LOG_OP_AND);  }
"||"							{ printf("%s\n", yytext); return (T_LOG_OP_OR);  }
"<<"							{ printf("%s\n", yytext); return (T_IO_EXTRACTION);  }
">>"							{ printf("%s\n", yytext); return (T_IO_INSERTION);  }
"::"							{ printf("%s\n", yytext); return (T_SCOPE_RESOLUTION); }


	/* for all keywords */
"printf("%s\n", yytext); return"						{ printf("%s\n", yytext); return (T_RETURN);  }
"void"							{ printf("%s\n", yytext); return T_TYPE_VOID; }
"class"							{ printf("%s\n", yytext); return T_TYPE_CLASS; }
"public"						{ printf("%s\n", yytext); return T_ACCESS_PUBLIC; }
"private"						{ printf("%s\n", yytext); return T_ACCESS_PRIVATE; }
"protected"						{ printf("%s\n", yytext); return T_ACCESS_PROTECTED; }
"int"							{ printf("%s\n", yytext); return (T_TYPE_INT);  }
"float"							{ printf("%s\n", yytext); return (T_TYPE_FLOAT);  }
"double"						{ printf("%s\n", yytext); return (T_TYPE_DOUBLE);  }
	/* "bool"							{ printf("%s\n", yytext); return (T_TYPE_BOOL);  } */
"if"							{ printf("%s\n", yytext); return (T_CONSTRUCT_IF);  }
"else"							{ printf("%s\n", yytext); return (T_CONSTRUCT_ELSE); }
"for"							{ printf("%s\n", yytext); return (T_CONSTRUCT_FOR); }
"cin"							{ printf("%s\n", yytext); return (T_IO_CIN); }
"cout"							{ printf("%s\n", yytext); return (T_IO_COUT); }
"return"						{ printf("%s\n", yytext); return (T_RETURN); }
"printf"						{ printf("%s\n", yytext); return (T_IO_PRINTF); }
"scanf"							{ printf("%s\n", yytext); return (T_IO_SCANF); }
	/* for all literals */
{digit}+						{ printf("%s digit\n", yytext); return T_NUMBER_LITERAL;}
	/* "true"|"false"					{ printf("%s\n", yytext); return T_BOOL_LITERAL; } */

{character_lit}\'					{ printf("%s\n", yytext); return T_CHAR_LITERAL; }
{character_lit}\'|{character_lit}	{ printf("Incomplete character literal\n"); }

{string_lit}\"						{ printf("%s\n", yytext); return T_STRING_LITERAL; };
{string_lit}\\|{string_lit}			{ printf("Incomplete string literal\n"); }



	/* comments */
"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	
"/*"([^*]|(\*+[^*/]))*				{ printf("ERROR - Non-terminating comment\n"); }

{identifier}					{ if(yyleng > 31)
								  {
									printf("Length of identifier is greater than 31 characters, truncating it to the first 31 characters only\n"); 
									char *temp = (char*)malloc(sizeof(char) * 32);
									for(int i=0;i<32;i++)
									{
										temp[i] = yytext[i];
									}
									} 
									else
									{
									}
									printf("%s\n", yytext); return T_IDENTIFIER; 
								}

{ws}+							{ /* Throw away whitespace */ }

{exp_number}					{ printf("%s\n", yytext); return T_TYPE_DOUBLE; }

%%

	int yywrap(void)
	{
		return 1;
	}
