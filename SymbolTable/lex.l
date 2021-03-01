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
exp_number						{digit}*(\.{digit}+)?([eE][+-]?{digit}+)?

	/* floating point numbers */
float_num						{digit}*(\.{digit}+)?[Ff]


%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define YYSTYPE char *

	#define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line; \
    yylloc.first_column = yylloc.last_column; \
    for(int i = 0; yytext[i] != '\0'; i++) { \
        if(yytext[i] == '\n') { \
            yylloc.last_line++; \
            yylloc.last_column = 0; \
        } \
        else { \
            yylloc.last_column++; \
        } \
    }

	#include "y.tab.h"

	void print_token(char *token);
%}

%option yylineno

%%
^{ws}*"#".*							{ /* not do anything for preprocessor lines */ }

^"using namespace std;"				{ ; }

	/* for all single characters - including operators */
"+"|"-"|"*"|"/"|"%"|"<"|">"|"="|"!"|";"|","|"."|"["|"]"|"{"|"}"|")"|"("|"|"|"&"|"^"	{ print_token("Single Character Token"); yylval = strdup(yytext); return (int)(*yytext); }
{ws}+							{ /* Throw away whitespace */ }

	/* for all multiple characters operators */
"<="							{  print_token("Less than or equal to"); yylval = strdup(yytext); return (T_REL_OP_LESS_THAN_EQUAL);  }
">="							{  print_token("Greater than or equal to"); yylval = strdup(yytext); return (T_REL_OP_GREATER_THAN_EQUAL);  }
"=="							{  print_token("Equal to"); yylval = strdup(yytext); return (T_REL_OP_EQUAL);  }
"!="							{  print_token("Not equal to"); yylval = strdup(yytext); return (T_REL_OP_NOT_EQUAL);  }
"&&"							{  print_token("Logical AND"); yylval = strdup(yytext); return (T_LOG_OP_AND);  }
"||"							{  print_token("Logical OR"); yylval = strdup(yytext); return (T_LOG_OP_OR);  }
"<<"							{  print_token("Insertion operator"); yylval = strdup(yytext); return (T_IO_INSERTION);  }
">>"							{  print_token("Extraction Operator"); yylval = strdup(yytext); return (T_IO_EXTRACTION);  }
"::"							{  print_token("Scope Resolution Operator"); yylval = strdup(yytext); return (T_SCOPE_RESOLUTION); }
"++"							{  print_token("Increment operator"); yylval = strdup(yytext); return (T_OP_INCREMENT); }
"--"							{  print_token("Decrement operator"); yylval = strdup(yytext); return (T_OP_DECREMENT); }
"+="							{  print_token("Additive assignment"); yylval = strdup(yytext); return (T_OP_ADD_ASSIGNMENT); }
"-="							{  print_token("Subtraction Assignment"); yylval = strdup(yytext); return (T_OP_SUBTRACT_ASSIGNMENT); }
"*="							{  print_token("Multiplicative assignment"); yylval = strdup(yytext); return (T_OP_MULTIPLY_ASSIGNMENT); }
"/="							{  print_token("Divisive Assignment"); yylval = strdup(yytext); return (T_OP_DIVIDE_ASSIGNMENT); }
"%="							{  print_token("Mod Assignment"); yylval = strdup(yytext); return (T_OP_MOD_ASSIGNMENT); }

	/* for all keywords */
"return"						{  print_token("Keyword-return"); yylval = strdup(yytext); return (T_RETURN);  }
"void"							{  print_token("Keyword-void"); yylval = strdup(yytext); return T_TYPE_VOID; }
"class"							{  print_token("Keyword-class"); yylval = strdup(yytext); return T_TYPE_CLASS; }
"public"						{  print_token("Keyword-public"); yylval = strdup(yytext); return T_ACCESS_PUBLIC; }
"private"						{  print_token("Keyword-private"); yylval = strdup(yytext); return T_ACCESS_PRIVATE; }
"protected"						{  print_token("Keyword-protected"); yylval = strdup(yytext); return T_ACCESS_PROTECTED; }
"int"							{  print_token("Keyword-int"); yylval = strdup(yytext); return (T_TYPE_INT);  }
"float"							{  print_token("Keyword-float"); yylval = strdup(yytext); return (T_TYPE_FLOAT);  }
"double"						{  print_token("Keyword-double"); yylval = strdup(yytext); return (T_TYPE_DOUBLE);  }
"bool"							{  print_token("Keyword-bool"); yylval = strdup(yytext); return (T_TYPE_BOOL);  }
"if"							{  print_token("Keyword-if"); yylval = strdup(yytext); return (T_CONSTRUCT_IF);  }
"else"							{  print_token("Keyword-else"); yylval = strdup(yytext); return (T_CONSTRUCT_ELSE); }
"for"							{  print_token("Keyword-for"); yylval = strdup(yytext); return (T_CONSTRUCT_FOR); }
"cin"							{  print_token("Keyword-cin"); yylval = strdup(yytext); return (T_IO_CIN); }
"cout"							{  print_token("Keyword-cout"); yylval = strdup(yytext); return (T_IO_COUT); }
"printf"						{  print_token("Keyword-printf"); yylval = strdup(yytext); return (T_IO_PRINTF); }
"scanf"							{  print_token("Keyword-scanf"); yylval = strdup(yytext); return (T_IO_SCANF); }
"break"							{  print_token("Keyword-break"); yylval = strdup(yytext); return (T_JUMP_BREAK); }
"continue"						{  print_token("Keyword-continue"); yylval = strdup(yytext); return (T_JUMP_CONTINUE); }
"exit"							{  print_token("Keyword-exit"); yylval = strdup(yytext); return (T_JUMP_EXIT); }
"string"						{  print_token("Keyword-string"); yylval = strdup(yytext); return (T_TYPE_STRING); }
"char"							{  print_token("Keyword-char"); yylval = strdup(yytext); return (T_TYPE_CHAR); }
"true"							{ print_token("Keyword-true"); yylval = strdup(yytext); return T_BOOL_LITERAL; }
"false"							{ print_token("Keyword-false"); yylval = strdup(yytext); return T_BOOL_LITERAL; }

{identifier}					{ if(yyleng < 32) yylval = strdup(yytext);
								  else {
									  printf("[Error] at line:%d - %s is too long, truncating to first 31 characters\n", yylineno , yytext);
									  char dummy[32];
									  strncpy(dummy, yytext, 31);
									  dummy[31] = '\0';
									  yylval = strdup(dummy);
								  }
								  print_token("Identifier");
								  return T_IDENTIFIER;
								}


	/* for all integer literals */
{digit}+							{ print_token("Literal-Number"); yylval = strdup(yytext); return T_NUMBER_LITERAL;}
	/* "true"|"false"					{ print_token("Literal-Boolean"); yylval = strdup(yytext); return T_BOOL_LITERAL; } */

{character_lit}\'					{ print_token("Literal-Character"); yylval = strdup(yytext); return T_CHAR_LITERAL; }
{character_lit}\'|{character_lit}	{ printf("Incomplete character literal\n"); }

{string_lit}\"						{ print_token("Literal-String"); yylval = strdup(yytext); return T_STRING_LITERAL; };
{string_lit}\\|{string_lit}			{ printf("Incomplete string literal\n"); }




	/* comments */
"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	{ ; }
"/*"([^*]|(\*+[^*/]))*				{ printf("ERROR - Non-terminating comment\n"); }

{exp_number}|{float_num}		{ print_token("Literal-Number"); 
									char id_temp[32];
									gcvt(atof(yytext), 10, id_temp); 
									id_temp[32] = '\0';
									yylval = strdup(id_temp); return T_NUMBER_LITERAL; }
\n								{ ; }

.								{ printf("invalid character --> %s\n", yytext); }
%%

int yywrap(void)
{
	return 1;
}

void print_token(char *token) {
	FILE *fptr = fopen("tokens.txt", "a");
	fprintf(fptr, "%-20s\t\t\t\t\t%-10s\n", token, yytext);
	fclose(fptr);
}
