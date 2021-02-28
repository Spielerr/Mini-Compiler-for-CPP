%{

    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define YYSTYPE char *

	#define SYMBOL_TABLE_SIZE 1000
	#define MAX_IDENTIFIER_SIZE 32

    int yylex();

	extern FILE* yyin;

	typedef struct symbol_table_ {
		int line_number;
		char name[MAX_IDENTIFIER_SIZE];
		char type[MAX_IDENTIFIER_SIZE];
		char category[MAX_IDENTIFIER_SIZE];
		char value[MAX_IDENTIFIER_SIZE];
		int size;
		int scope;
	} symbol_table;

	typedef struct node {
		symbol_table *st;
		struct node *next;
	} node_t;

	node_t* complete_symbol_table[SYMBOL_TABLE_SIZE];
	unsigned int hash_function(char *name);
	// node_t *create_node(char *name, char *category, char *type, int line_number);

	symbol_table* insert(char *name, char *category, char *type, int line_number, char *value);
	// symbol_table* lookup_and_insert(char *name, char *category, char *type, int line_number);
	void init_symbol_table();
	symbol_table* lookup(char *name);
	void scope_enter();
	void scope_leave();
	void display_symbol_table();

	void yyerror(char *s);

	int current_scope = 0;
	int scopes[SYMBOL_TABLE_SIZE];
	int scope_counter = 0;

	char variable_declaration_type[20] = "\0";
	int is_declaration_assignment = 0;

	int construct_nesting_level = 0;
	int encountered_construct_nesting_level = 0;

%}

%start START

// ---------------- TOKENS ------------------

// Datatypes
%token T_TYPE_INT T_TYPE_FLOAT T_TYPE_DOUBLE T_TYPE_BOOL T_TYPE_STRING T_TYPE_CHAR T_TYPE_VOID T_TYPE_CLASS T_USER_DEFINED_TYPE T_IDENTIFIER

// Literals
%token  T_CHAR_LITERAL T_STRING_LITERAL T_NUMBER_LITERAL T_BOOL_LITERAL

// Required Construct Tokens
%token T_CONSTRUCT_IF T_CONSTRUCT_ELSE T_CONSTRUCT_FOR

// Block Tokens
%token '{' '}'

// Class Tokens
%token T_ACCESS_PUBLIC T_ACCESS_PRIVATE T_ACCESS_PROTECTED

// Header Tokens
%token T_HEADER_INCLUDE T_HEADER_FILE

// Relational Operator Tokens
%token '>' '<' T_REL_OP_GREATER_THAN_EQUAL T_REL_OP_LESS_THAN_EQUAL T_REL_OP_EQUAL T_REL_OP_NOT_EQUAL

// Logical Operators
%token T_LOG_OP_OR T_LOG_OP_AND

// Bitwise Operators
%token '&' '|' '^' T_BIT_OP_RIGHT_SHIFT T_BIT_OP_LEFT_SHIFT '!'

// Assignment Operators
%token '=' T_OP_ADD_ASSIGNMENT T_OP_SUBTRACT_ASSIGNMENT T_OP_MULTIPLY_ASSIGNMENT T_OP_DIVIDE_ASSIGNMENT T_OP_MOD_ASSIGNMENT

// Other Operators
%token '+' '-' '*' '/' '%' T_OP_INCREMENT T_OP_DECREMENT

// Input Output Tokens
// Insertion: << for cin, Extraction: >> for cout
%token T_IO_COUT T_IO_CIN T_IO_PRINTF T_IO_SCANF T_IO_GETLINE T_IO_INSERTION T_IO_EXTRACTION

// Jump Tokens
%token T_JUMP_BREAK T_JUMP_EXIT T_JUMP_CONTINUE

// Other Tokens
%token '(' ')' ';' T_DOUBLE_QUOTES_OPEN T_DOUBLE_QUOTES_CLOSE T_COLON T_SCOPE_RESOLUTION '[' ']' ',' T_RETURN '.' T_SQ_BRACKET T_COMMENT

%right T_IO_EXTRACTION T_IO_INSERTION

%right '(' ')'

%right '=' T_OP_ADD_ASSIGNMENT T_OP_SUBTRACT_ASSIGNMENT T_OP_MULTIPLY_ASSIGNMENT T_OP_DIVIDE_ASSIGNMENT T_OP_MOD_ASSIGNMENT

%right '<' '>' T_REL_OP_GREATER_THAN_EQUAL T_REL_OP_LESS_THAN_EQUAL T_REL_OP_EQUAL

%left '+' '-'

%left '*' '/'

%left '&' '|' '^'

%%


START
	: INCLUDE BODY {
        sprintf($$, "%s", $2);
    }
	| BODY {
        sprintf($$, "%s", $1);
    }
	| INCLUDE
	;

INCLUDE
	: INCLUDE T_HEADER_INCLUDE '<' T_HEADER_FILE '>'
	| INCLUDE T_HEADER_INCLUDE T_STRING_LITERAL
	| T_HEADER_INCLUDE '<' T_HEADER_FILE '>'
	| T_HEADER_INCLUDE T_STRING_LITERAL
	;

BODY
	: BODY_BLOCK BODY {
        sprintf($$, "%s %s", $1, $2);
    }
	| BODY_BLOCK {
        sprintf($$, "%s", $1);
    }
	;

BODY_BLOCK
	: FUNCTION {
        sprintf($$, "%s", $1);
    }
	| BLOCK {
        sprintf($$, "%s", $1);
    }
	;

FUNCTION
	: FUNCTION_PROTOTYPE {
        sprintf($$, "%s", $1);
    }
	| FUNCTION_DEFINITION {
        sprintf($$, "%s", $1);
    }
	| FUNCTION_DECLARATION {
        sprintf($$, "%s", $1);
    }
	;

FUNCTION_PROTOTYPE
	: FUNCTION_PREFIX TYPE_LIST ')' ';' {
        sprintf($$, "%s %s ) ;", $1, $2);
    }
	| FUNCTION_PREFIX ')' ';' {
        sprintf($$, "%s ) ;", $1);
    }
	;

TYPE_LIST
	: TYPE ',' TYPE_LIST {
        sprintf($$, "%s , %s", $1, $3);
    }
	| TYPE {
        sprintf($$, "%s", $1);
    }
	;

FUNCTION_DEFINITION
	: FUNCTION_PREFIX FUNCTION_PARAMETER_LIST ')' ';' {
		scope_leave();
        sprintf($$, "%s %s ) ;", $1, $2);
	}
	;

FUNCTION_DECLARATION
	: FUNCTION_PREFIX FUNCTION_PARAMETER_LIST ')' '{' STATEMENTS '}' {
		scope_leave();
        sprintf($$, "%s %s ) { %s }", $1, $2, $5);
	}
	| FUNCTION_PREFIX ')' '{' STATEMENTS '}' {
		scope_leave();
        sprintf($$, "%s ) { %s }", $1, $4);
	}
	;

FUNCTION_PARAMETER_LIST
	: TYPE T_IDENTIFIER ',' FUNCTION_PARAMETER_LIST {
		if (insert($2, "Identifier", $1, @2.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
        sprintf($$, "%s %s , %s", $1, $2, $4);
	}
	| TYPE T_IDENTIFIER '=' EXPRESSION ',' FUNCTION_PARAMETER_LIST {
		if (insert($2, "Identifier", $1, @2.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
        sprintf($$, "%s %s = %s , %s", $1, $2, $4, $6);
	}
	| TYPE T_IDENTIFIER {
		if (insert($2, "Identifier", $1, @2.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
        sprintf($$, "%s %s", $1, $2);
	}
	| TYPE T_IDENTIFIER '=' EXPRESSION {
		if (insert($2, "Identifier", $1, @2.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
        sprintf($$, "%s %s = %s", $1, $2, $4);
	}
	;

FUNCTION_PREFIX
	: TYPE T_IDENTIFIER '(' {
		insert($2, "Function-Identifier", $1, @2.last_line, NULL);
		scope_enter();
        sprintf($$, "%s %s (", $1, $2);
	}
	;

BLOCK
	: BLOCK_START STATEMENTS BLOCK_END {
        sprintf($$, "%s %s %s", $1, $2, $3);
    }
	;

BLOCK_START
	: '{' {
        scope_enter();
        sprintf($$, "{");
    }
	;

BLOCK_END
	: '}' {
        scope_leave();
        sprintf($$, "}");
    }
	;

STATEMENTS
	: STATEMENT STATEMENTS {
        sprintf($$, "%s %s", $1, $2);
    }
	| STATEMENT {
        sprintf($$, "%s", $1);
    }
	;

SINGLE_LINE_IF
	: IF_PREFIX LINE_STATEMENT ';' {
		scope_leave();
        sprintf($$, "%s %s ;", $1, $2);
	}
	| IF_PREFIX ';' {
		scope_leave();
        sprintf($$, "%s ;", $1);
	}
	| IF_PREFIX CONSTRUCT {
		scope_leave();
        sprintf($$, "%s", $1);
	}
	;

BLOCK_IF
	: T_CONSTRUCT_IF '(' EXPRESSION ')' BLOCK {
        sprintf($$, "%s ( %s ) %s", $1, $3, $5);
    }
	;

IF_PREFIX
	: T_CONSTRUCT_IF '(' EXPRESSION ')' {
		scope_enter();
        sprintf($$, "%s ( %s )", $1, $3);
	}
	;

SINGLE_LINE_ELSE
	: ELSE_PREFIX LINE_STATEMENT ';'{
		scope_leave();
        sprintf($$, "%s %s ;", $1, $2);
	}
	| ELSE_PREFIX ';'{
		scope_leave();
        sprintf($$, "%s ;", $1);
	}
	| ELSE_PREFIX CONSTRUCT {
		scope_leave();
        sprintf($$, "%s %s", $1, $2);
	}
	;

BLOCK_ELSE
	: T_CONSTRUCT_ELSE BLOCK {
        sprintf($$, "%s %s", $1, $2);
    }
	;

ELSE_PREFIX
	: T_CONSTRUCT_ELSE {
		scope_enter();
        sprintf($$, "%s", $1);
	}
	;

SINGLE_LINE_FOR
	: FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' LINE_STATEMENT ';'{
		scope_leave();
        sprintf($$, "%s %s ; %s ; %s ) %s ;", $1, $2, $4, $6, $8);
	}
	| FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' ';'{
		scope_leave();
        sprintf($$, "%s %s ; %s ; %s ) ;", $1, $2, $4, $6);
	}
	| FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' CONSTRUCT{
		scope_leave();
        sprintf($$, "%s %s ; %s ; %s ) %s", $1, $2, $4, $6, $8);
	}
	;

BLOCK_FOR
	: FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' '{' STATEMENTS '}'{
		scope_leave();
        sprintf($$, "%s %s ; %s ; %s ) { %s }", $1, $2, $4, $6, $9);
	}
	;

FOR_PREFIX
	: T_CONSTRUCT_FOR '(' {
		scope_enter();
        sprintf($$, "%s (", $1);
	}
	;

FOR_INIT_STATEMENT
	:
	| LINE_STATEMENT {
        sprintf($$, "%s", $1);
    }
	;

FOR_CONDITION_STATEMENT
	:
	| CONDITIONAL_EXPRESSION {
        sprintf($$, "%s", $1);
    }
	;

FOR_ACTION_STATEMENT
	:
	| LINE_STATEMENT {
        sprintf($$, "%s", $1);
    }
	;

BITWISE_OPERATOR
	: '&' {
        sprintf($$, "&");
    }
	| '|' {
        sprintf($$, "|");
    }
	| '^' {
        sprintf($$, "^");
    }
	;

CONDITIONAL_EXPRESSION
	: EXPRESSION LOGICAL_OPERATOR EXPRESSION_GRAMMAR {
        sprintf($$, "%s %s %s", $1, $2, $3);
    }
	| EXPRESSION RELATIONAL_OPERATOR EXPRESSION_GRAMMAR {
        sprintf($$, "%s %s %s", $1, $2, $3);
    }
	| EXPRESSION BITWISE_OPERATOR EXPRESSION_GRAMMAR {
        sprintf($$, "%s %s %s", $1, $2, $3);
    }
	;

ASSIGNMENT
	: T_IDENTIFIER ASSIGNMENT_OPERATOR EXPRESSION_GRAMMAR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
        sprintf($$, "%s %s %s", $1, $2, $3);
	}
	| T_IDENTIFIER ASSIGNMENT_OPERATOR ASSIGNMENT {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
        sprintf($$, "%s %s %s", $1, $2, $3);
	}
	| T_IDENTIFIER '[' EXPRESSION ']' ASSIGNMENT_OPERATOR EXPRESSION_GRAMMAR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
        sprintf($$, "%s [ %s ] %s %s", $1, $3, $5, $6);
	}
	| T_IDENTIFIER '[' EXPRESSION ']' ASSIGNMENT_OPERATOR ASSIGNMENT {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
        sprintf($$, "%s [ %s ] %s %s", $1, $3, $5, $6);
	}
	;

ASSIGNMENT_OPERATOR
	: '=' {
        sprintf($$, "=");
    }
	| T_OP_ADD_ASSIGNMENT {
        sprintf($$, "+=");
    }
	| T_OP_SUBTRACT_ASSIGNMENT {
        sprintf($$, "-=");
    }
	| T_OP_MULTIPLY_ASSIGNMENT {
        sprintf($$, "*=");
    }
	| T_OP_DIVIDE_ASSIGNMENT {
        sprintf($$, "/=");
    }
	| T_OP_MOD_ASSIGNMENT {
        sprintf($$, "%%=");
    }
	;

EXPRESSION
	: ASSIGNMENT {
        sprintf($$, "%s", $1);
    }
	| CONDITIONAL_EXPRESSION {
        sprintf($$, "%s", $1);
    }
	| EXPRESSION_GRAMMAR {
        sprintf($$, "%s", $1);
    }
	;

EXPRESSION_GRAMMAR
	: EXPRESSION_GRAMMAR '+' EXPRESSION_TERM {
        sprintf($$, "%s + %s", $1, $3);
    }
	| EXPRESSION_GRAMMAR '-' EXPRESSION_TERM {
        sprintf($$, "%s - %s", $1, $3);
    }
	| EXPRESSION_TERM {
        sprintf($$, "%s", $1);
    }
	;

EXPRESSION_TERM
	: EXPRESSION_TERM '*' EXPRESSION_F {
        sprintf($$, "%s * %s", $1, $3);
    }
	| EXPRESSION_TERM '/' EXPRESSION_F {
        sprintf($$, "%s / %s", $1, $3);
    }
	| EXPRESSION_TERM '%' EXPRESSION_F {
        sprintf($$, "%s %% %s", $1, $3);
    }
	| EXPRESSION_F {
        sprintf($$, "%s", $1);
    }
	| '!' EXPRESSION_F {
        sprintf($$, "! %s", $2);
    }
	;

EXPRESSION_F
	: IDENTIFIER_OR_LITERAL {
        sprintf($$, "%s", $1);
    }
	| '(' EXPRESSION ')' {
        sprintf($$, "( %s )", $2);
    }
	| '+' EXPRESSION_F {
        sprintf($$, "+ %s", $2);
    }
	| '-' EXPRESSION_F {
        sprintf($$, "- %s", $2);
    }
	;

CONSTRUCT
	: SINGLE_LINE_CONSTRUCT {
        sprintf($$, "%s", $1);
    }
	| BLOCK_CONSTRUCT {
        sprintf($$, "%s", $1);
    }
	;

BLOCK_CONSTRUCT
	: BLOCK_FOR {
        sprintf($$, "%s", $1);
    }
	| BLOCK_IF {
        sprintf($$, "%s", $1);
    }
	| BLOCK_ELSE {
        sprintf($$, "%s", $1);
    }
	;

SINGLE_LINE_CONSTRUCT
	: SINGLE_LINE_FOR {
        sprintf($$, "%s", $1);
    }
	| SINGLE_LINE_IF {
        sprintf($$, "%s", $1);
    }
	| SINGLE_LINE_ELSE {
        sprintf($$, "%s", $1);
    }
	;

STATEMENT
	: LINE_STATEMENT ';' {
        sprintf($$, "%s ;", $1);
    }
	| CONSTRUCT {
        sprintf($$, "%s", $1);
    }
	| BLOCK {
        sprintf($$, "%s", $1);
    }
	| ';' {
        sprintf($$, ";");
    }
	;

JUMP_STATEMENT
	: T_JUMP_BREAK {
        sprintf($$, "%s", $1);
    }
	| T_JUMP_EXIT {
        sprintf($$, "%s", $1);
    }
	| T_JUMP_CONTINUE {
        sprintf($$, "%s", $1);
    }
	;

LINE_STATEMENT
	: VARIABLE_DECLARATION {
        sprintf($$, "%s", $1);
    }
	| EXPRESSION {
        sprintf($$, "%s", $1);
    }
	| COUT {
        sprintf($$, "%s", $1);
    }
	| CIN {
        sprintf($$, "%s", $1);
    }
	| RETURN {
        sprintf($$, "%s", $1);
    }
	| JUMP_STATEMENT {
        sprintf($$, "%s", $1);
    }
	;

VARIABLE_DECLARATION
	: VARIABLE_DECLARATION_TYPE VARIABLE_LIST {
		strcpy(variable_declaration_type, "\0");
        sprintf($$, "%s %s", $1, $2);
	}
	;

VARIABLE_DECLARATION_TYPE
	: TYPE {
		strcpy(variable_declaration_type, $1);
        sprintf($$, "%s", $1);
	}
	;

VARIABLE_LIST
	: VARIABLE_DECLARATION_IDENTIFIER ',' VARIABLE_LIST {
        sprintf($$, "%s , %s", $1, $3);
    }
	| VARIABLE_DECLARATION_IDENTIFIER '=' EXPRESSION ',' VARIABLE_LIST {
		symbol_table* element = lookup($1);
		strcpy(element->value, $3);
        sprintf($$, "%s = %s , %s", $1, $3, $5);
	}
	| VARIABLE_DECLARATION_IDENTIFIER {
        sprintf($$, "%s", $1);
    }
	| VARIABLE_DECLARATION_IDENTIFIER '=' EXPRESSION {
		symbol_table* element = lookup($1);
		strcpy(element->value, $3);
        sprintf($$, "%s = %s", $1, $3);
	}

	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE ',' VARIABLE_LIST {
        sprintf($$, "%s , %s", $1, $3);
    }
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER '=' ARRAY_LIST ',' VARIABLE_LIST {
        sprintf($$, "%s = %s , %s", $1, $3, $5);
    }
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE {
        sprintf($$, "%s", $1);
    }
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER '=' ARRAY_LIST {
        sprintf($$, "%s = %s", $1, $3);
    }
	;

VARIABLE_DECLARATION_IDENTIFIER
	: T_IDENTIFIER {
		if (insert($1, "Identifier", variable_declaration_type, @1.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
        sprintf($$, "%s", $1);
	}
	;

ARRAY_VARIABLE_DECLARATION_IDENTIFIER
	: T_IDENTIFIER '[' ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
        sprintf($$, "%s []", $1);
	}
	| T_IDENTIFIER '[' EXPRESSION ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
        sprintf($$, "%s [ %s ]", $1, $3);
	}
	;

ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE
	: T_IDENTIFIER '[' EXPRESSION ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
        sprintf($$, "%s [ %s ]", $1, $3);
	}
	;

ARRAY_LIST
	: '{' LITERAL_LIST '}' {
        sprintf($$, "{ %s }", $2);
    }
	| T_STRING_LITERAL {
        sprintf($$, "%s", $1);
    }
	;

LITERAL_LIST
	: IDENTIFIER_OR_LITERAL ',' LITERAL_LIST {
        sprintf($$, "%s , %s", $1, $3);
    }
	| IDENTIFIER_OR_LITERAL {
        sprintf($$, "%s", $1);
    }
	;

COUT
	: T_IO_COUT T_IO_INSERTION INSERTION_LIST {
        sprintf($$, "%s %s %s", $1, $2, $3);
    }
	;

INSERTION_LIST
	: EXPRESSION T_IO_INSERTION INSERTION_LIST {
        sprintf($$, "%s %s %s", $1, $2, $3);
    }
	| EXPRESSION {
        sprintf($$, "%s", $1);
    }
	;

CIN
	: T_IO_CIN T_IO_EXTRACTION EXTRACTION_LIST {
        sprintf($$, "%s %s %s", $1, $2, $3);
    }
	;

EXTRACTION_LIST
	: T_IDENTIFIER T_IO_EXTRACTION EXTRACTION_LIST {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
        sprintf($$, "%s %s %s", $1, $2, $3);
	}
	| T_IDENTIFIER {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		sprintf($$, "%s", $1);
	}
	;

RETURN
	: T_RETURN EXPRESSION {
        sprintf($$, "%s %s", $1, $2);
    }
	;

LOGICAL_OPERATOR
	: T_LOG_OP_AND {
        sprintf($$, "%s", $1);
    }
	| T_LOG_OP_OR {
        sprintf($$, "%s", $1);
    }
	;

RELATIONAL_OPERATOR
	: T_REL_OP_EQUAL {
        sprintf($$, "%s", $1);
    }
	| '>' {
        sprintf($$, ">");
    }
	| T_REL_OP_GREATER_THAN_EQUAL {
        sprintf($$, "%s", $1);
    }
	| '<' {
        sprintf($$, "<");
    }
	| T_REL_OP_LESS_THAN_EQUAL {
        sprintf($$, "%s", $1);
    }
	| T_REL_OP_NOT_EQUAL {
        sprintf($$, "%s", $1);
    }
	;

IDENTIFIER_OR_LITERAL
	: T_IDENTIFIER {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		sprintf($$, "%s", $1);
	}
	| T_IDENTIFIER '(' ')' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Function \"%s\" not defined \n", @1.last_line, $1);
		}
		sprintf($$, "%s ()", $1);
	}
	| T_IDENTIFIER '(' LITERAL_LIST ')' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Function \"%s\" not defined \n", @1.last_line, $1);
		}
		sprintf($$, "%s ( %s )", $1, $3);
	}
	| T_IDENTIFIER UNARY_OPERATOR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		sprintf($$, "%s %s", $1, $2);
	}
	| UNARY_OPERATOR T_IDENTIFIER {
		if (lookup($2) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @2.last_line, $2);
		}
		sprintf($$, "%s %s", $1, $2);
	}
	| T_IDENTIFIER '[' EXPRESSION ']' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		sprintf($$, "%s [ %s ]", $1, $3);
	}
	| UNARY_OPERATOR T_IDENTIFIER '[' EXPRESSION ']' {
		if (lookup($2) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @2.last_line, $2);
		}
		sprintf($$, "%s %s [ %s ]", $1, $2, $4);
	}
	| T_IDENTIFIER '[' EXPRESSION  ']' UNARY_OPERATOR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		sprintf($$, "%s [ %s ] %s", $1, $3, $5);
	}
	| T_CHAR_LITERAL {
        sprintf($$, "%s", $1);
    }
	| T_NUMBER_LITERAL {
        sprintf($$, "%s", $1);
    }
	| T_STRING_LITERAL {
        sprintf($$, "%s", $1);
    }
	| T_BOOL_LITERAL {
        sprintf($$, "%s", $1);
    }
	;

UNARY_OPERATOR
	: T_OP_INCREMENT {
        sprintf($$, "%s", $1);
    }
	| T_OP_DECREMENT {
        sprintf($$, "%s", $1);
    }
	;

TYPE
	: T_TYPE_INT {
		sprintf($$, "%s", $1);
	}
	| T_TYPE_DOUBLE {
		sprintf($$, "%s", $1);
	}
	| T_TYPE_FLOAT {
		sprintf($$, "%s", $1);
	}
	| T_TYPE_CHAR {
		sprintf($$, "%s", $1);
	}
	| T_TYPE_STRING {
		sprintf($$, "%s", $1);
	}
	| T_TYPE_VOID {
		sprintf($$, "%s", $1);
	}
	| T_TYPE_BOOL {
		sprintf($$, "%s", $1);
	}
	;

%%

void yyerror(char *s){
	printf("\n[Error] at line:%d, column:%d\n", yylloc.last_line, yylloc.last_column);
}

int main(int argc, char *argv[]) {

	yyin = fopen("test_new_1.cpp","r");

	init_symbol_table();

    printf("TOKENS STREAMED\n");
    printf("----------------------------------------------------------------------------------------------------------------------------------------------------------\n");
    printf("Token Type\t\t\t\t\tToken Value\n");
    printf("----------------------------------------------------------------------------------------------------------------------------------------------------------\n");

    int isError = yyparse();
    printf("----------------------------------------------------------------------------------------------------------------------------------------------------------\n");

    if (isError) {
        printf("\nPARSING IS UNSUCCESSFUL\n\n");
    }
    else {
        printf("\nPARSING IS SUCCESSFUL\n\n");
		display_symbol_table();
    }
    return 0;

}
void scope_enter()
{
	scope_counter+=1;
	scopes[scope_counter] = current_scope;
	current_scope = scope_counter;
}
void scope_leave()
{
	current_scope = scopes[current_scope];
}
void init_symbol_table()
{
	for(int i=0;i<SYMBOL_TABLE_SIZE;++i)
	{
		complete_symbol_table[i] = NULL;
	}
}
unsigned int hash_function(char *name)
{
	unsigned int hash_value = 0;
	for(;*name!='\0';++name)
	{
		hash_value = hash_value +(int)(*name);
	}
	hash_value = hash_value % SYMBOL_TABLE_SIZE;
	return hash_value;
}
symbol_table* lookup(char *name)
{
	unsigned int hash_value = hash_function(name);
	node_t *temp = complete_symbol_table[hash_value];
	// check in parent scope
	symbol_table* looked_up = NULL;
	while(temp!=NULL)
	{
		if((strcmp(temp->st->name,name)==0))
		{
			if(temp->st->scope==current_scope)
				return temp->st;
			int x_scope = temp->st->scope;
			while(x_scope!=0)
			{
				int par_scope = scopes[x_scope];
				if(x_scope==scopes[par_scope])
				{
					looked_up = temp->st;
					break;
				}
				x_scope = par_scope;
			}
			if(x_scope==0)
				looked_up=temp->st;
		}
		if(looked_up!=NULL)
			break;
		temp = temp->next;
	}
	return looked_up;
}
node_t *create_node(char *name, char *category, char *type, int line_number, char *value)
{
	node_t *new_node = (node_t*)malloc(sizeof(node_t));
	new_node->st = (symbol_table*)malloc(sizeof(symbol_table));
	strcpy(new_node->st->name,name);
	strcpy(new_node->st->category,category);
	if(type != NULL)
	{
		strcpy(new_node->st->type,type);
	}
	else
	{
		char dummy[] = "NA";
		strcpy(new_node->st->type, dummy);
	}
	if (value != NULL) {
		strcpy(new_node->st->value, value);
	}
	else {
		char dummy[] = "NA";
		strcpy(new_node->st->value, dummy);
	}
 	new_node->st->line_number = line_number;
	new_node->st->scope = current_scope;
	new_node->next = NULL;
	return new_node;
}
symbol_table* insert(char *name, char *category, char *type, int line_number, char *value)
{
	// only in current scope
	unsigned int hash_value = hash_function(name);
    printf("HASH: %s %d\n", name, hash_value);
	node_t *temp = complete_symbol_table[hash_value];
	if(temp!=NULL)
	{
		node_t *prev = NULL;
		while(temp!=NULL) {
			if((temp->st->scope==current_scope)&&(strcmp(temp->st->name,name)==0))
			{
				return NULL;
			}
			prev = temp;
			temp = temp->next;
		}

		prev->next = create_node(name,category,type,line_number, value);
		temp = prev->next;
	}
	else
	{
		complete_symbol_table[hash_value] = create_node(name,category,type,line_number, value);
		temp = complete_symbol_table[hash_value];
	}
	return temp->st;
}
void display_symbol_table()
{
	printf("SYMBOL TABLE\n");
	printf("--------------------------------------------------------------------------------------------------------------------------------------------------------\n");
	printf("Token\t\t\tCategory\t\t\tType\t\t\tLine Number\t\t\tScope\t\t\tValue String\n");
	printf("--------------------------------------------------------------------------------------------------------------------------------------------------------\n");
	for(int i=0;i<SYMBOL_TABLE_SIZE;++i)
	{
		node_t* temp = complete_symbol_table[i];
		while(temp!=NULL)
		{
			printf("%-10s\t\t%-20s\t\t%-10s\t\t%10d\t\t%10d\t\t\t%s\n",temp->st->name,temp->st->category,temp->st->type,temp->st->line_number,temp->st->scope, temp->st->value);
			temp = temp->next;
		}
	}
    printf("--------------------------------------------------------------------------------------------------------------------------------------------------------\n");
	printf("\n\n");
}
