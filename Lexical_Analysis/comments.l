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
"asm"							{ return (T_ASM); columnno += yyleng; }
"auto"							{ return (T_AUTO); columnno += yyleng; }
"bool"							{ return (T_BOOL); columnno += yyleng; }
"break"							{ return (T_BREAK); columnno += yyleng; }
"case"							{ return (T_CASE); columnno += yyleng; }
"catch"							{ return (T_CATCH); columnno += yyleng; }
"char"							{ return (T_CHAR); columnno += yyleng; }
"class"							{ return (T_CLASS); columnno += yyleng; }
"const"							{ return (T_CONST); columnno += yyleng; }
"const_cast"					{ return (T_CONST_CAST); columnno += yyleng; }
"continue"						{ return (T_CONTINUE); columnno += yyleng; }
"default"						{ return (T_DEFAULT); columnno += yyleng; }
"delete"						{ return (T_DELETE); columnno += yyleng; }
"do"							{ return (T_DO); columnno += yyleng; }
"double"						{ return (T_DOUBLE); columnno += yyleng; }
"dynamic_cast"					{ return (T_DYNAMIC_CAST); columnno += yyleng; }
"else"							{ return (T_ELSE); columnno += yyleng; }
"enum"							{ return (T_ENUM); columnno += yyleng; }
"explicit"						{ return (T_EXPLICIT); columnno += yyleng; }
"export"						{ return (T_EXPORT); columnno += yyleng; }
"extern"						{ return (T_EXTERN); columnno += yyleng; }
"false"							{ return (T_FALSE); columnno += yyleng; }
"float"							{ return (T_FLOAT); columnno += yyleng; }
"for"							{ return (T_FOR); columnno += yyleng; }
"friend"						{ return (T_FRIEND); columnno += yyleng; }
"goto"							{ return (T_GOTO); columnno += yyleng; }
"if"							{ return (T_IF); columnno += yyleng; }
"inline"						{ return (T_INLINE); columnno += yyleng; }
"int"							{ return (T_INT); columnno += yyleng; }
"long"							{ return (T_LONG); columnno += yyleng; }
"mutable"						{ return (T_MUTABLE); columnno += yyleng; }
"namespace"						{ return (T_NAMESPACE); columnno += yyleng; }
"new"							{ return (T_NEW); columnno += yyleng; }
"operator"						{ return (T_OPERATOR); columnno += yyleng; }
"private"						{ return (T_PRIVATE); columnno += yyleng; }
"protected"						{ return (T_PROTECTED); columnno += yyleng; }
"public"						{ return (T_PUBLIC); columnno += yyleng; }
"register"						{ return (T_REGISTER); columnno += yyleng; }
"reinterpret_cast"				{ return (T_REINTERPRET_CAST); columnno += yyleng; }
"return"						{ return (T_RETURN); columnno += yyleng; }
"short"							{ return (T_SHORT); columnno += yyleng; }
"signed"						{ return (T_SIGNED); columnno += yyleng; }
"sizeof"						{ return (T_SIZEOF); columnno += yyleng; }
"static"						{ return (T_STATIC); columnno += yyleng; }
"static_cast"					{ return (T_STATIC_CAST); columnno += yyleng; }
"struct"						{ return (T_STRUCT); columnno += yyleng; }
"switch"						{ return (T_SWITCH); columnno += yyleng; }
"template"						{ return (T_TEMPLATE); columnno += yyleng; }
"this"							{ return (T_THIS); columnno += yyleng; }
"throw"							{ return (T_THROW); columnno += yyleng; }
"true"							{ return (T_TRUE); columnno += yyleng; }
"try"							{ return (T_TRY); columnno += yyleng; }
"typedef"						{ return (T_TYPEDEF); columnno += yyleng; }
"typeid"						{ return (T_TYPEID); columnno += yyleng; }
"typename"						{ return (T_TYPENAME); columnno += yyleng; }
"union"							{ return (T_UNION); columnno += yyleng; }
"unsigned"						{ return (T_UNSIGNED); columnno += yyleng; }
"using"							{ return (T_USING); columnno += yyleng; }
"virtual"						{ return (T_VIRTUAL); columnno += yyleng; }
"void"							{ return (T_VOID); columnno += yyleng; }
"volatile"						{ return (T_VOLATILE); columnno += yyleng; }
"wchar_t"						{ return (T_WCHAR_T); columnno += yyleng; }
"while"							{ return (T_WHILE); columnno += yyleng; }

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
"/*"([^*]|(\*+[^*/]))*\*+\/|\/\/.*	{num_comments++; return T_COMMENT;}	
"/*"([^*]|(\*+[^*/]))*				{printf("ERROR - Non-terminating comment\n");}

{exp_number}					{ /*exp_number_fn(yytext, yyleng);*/ return T_DOUBLE;
										// need to handle this function
										 }

{identifier}					{ yylval = strdup(yytext); return T_IDENTIFIER; }

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
