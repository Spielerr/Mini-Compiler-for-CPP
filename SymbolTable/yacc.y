%{

    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define SYMBOL_TABLE_SIZE 1000
	#define MAX_IDENTIFIER_SIZE 32

    int yylex();
    void yyerror(char *s);

	typedef struct symbol_table {
		int line_number;
		char name[MAX_IDENTIFIER_SIZE];
		char type[MAX_IDENTIFIER_SIZE];
		char value[MAX_IDENTIFIER_SIZE];
		int size;
		int scope;
	} symbol_table;

	typedef struct node {
		symbol_table *st;
		struct node *next;
	} node_t;

	node_t* complete_symbol_table = ( node_t* )malloc( sizeof(node_t) * SYMBOL_TABLE_SIZE );

    //lookup
	//free
	//allocate
	//insert
	//get_attribute
	//set_attribute

	// handle shift reduce conflicts

%}

%start START

// ---------------- TOKENS ------------------

// Datatypes
%token T_TYPE_INT T_TYPE_FLOAT T_TYPE_DOUBLE T_TYPE_STRING T_TYPE_CHAR T_TYPE_VOID T_TYPE_CLASS T_USER_DEFINED_TYPE T_NUMBER_LITERAL T_STRING_LITERAL T_CHAR_LITERAL T_IDENTIFIER

// Required Construct Tokens
%token T_CONSTRUCT_IF T_CONSTRUCT_ELSE T_CONSTRUCT_FOR

// Block Tokens
%token T_BLOCK_START T_BLOCK_END

// Class Tokens
%token T_ACCESS_PUBLIC T_ACCESS_PRIVATE T_ACCESS_PROTECTED

// Header Tokens
%token T_HEADER_INCLUDE T_HEADER_FILE

// Relational Operator Tokens
%token T_REL_OP_GREATER_THAN T_REL_OP_LESS_THAN T_REL_OP_GREATER_THAN_EQUAL T_REL_OP_LESS_THAN_EQUAL T_REL_OP_EQUAL

// Logical Operators
%token T_LOG_OP_OR T_LOG_OP_AND

// Bitwise Operators
%token T_BIT_OP_AND T_BIT_OP_OR T_BIT_OP_XOR T_BIT_OP_RIGHT_SHIFT T_BIT_OP_LEFT_SHIFT

// Other Operators
%token T_OP_ASSIGNMENT T_OP_ADD T_OP_SUBTRACT T_OP_MULTIPLY T_OP_DIVIDE T_OP_INCREMENT T_OP_DECREMENT

// Input Output Tokens
// Insertion: >> for cin, Extraction: << for cout
%token T_IO_COUT T_IO_CIN T_IO_PRINTF T_IO_SCANF T_IO_GETLINE T_IO_INSERTION T_IO_EXTRACTION

// Other Tokens
%token T_PARAN_OPEN T_PARAN_CLOSE T_SEMI_COLON T_DOUBLE_QUOTES_OPEN T_DOUBLE_QUOTES_CLOSE T_COLON T_SCOPE_RESOLUTION T_SQ_OPEN T_SQ_CLOSE T_COMMA T_RETURN T_DOT

%%

START
    : HEADER BODY {
        printf("Grammar Matched!\n");
    }
    ;

HEADER
    : HEADER INCLUDE
    | INCLUDE
    ;

INCLUDE
    : T_HEADER_INCLUDE T_REL_OP_LESS_THAN T_HEADER_FILE T_REL_OP_GREATER_THAN
    | T_HEADER_INCLUDE T_DOUBLE_QUOTES_OPEN T_HEADER_FILE T_DOUBLE_QUOTES_CLOSE
    ;

BODY
	: BODY FUNCTION_PROTOTYPE
	| BODY FUNCTION_DEFINITION
	| BODY FUNCTION_DECALARATION
	| BODY CLASS
	| BODY CLASS_FUNCTION_DECLARATION
	| BODY BLOCK
	| FUNCTION_PROTOTYPE
	| FUNCTION_DEFINITION
	| FUNCTION_DECALARATION
	| CLASS
	| CLASS_FUNCTION_DECLARATION
	| BLOCK
    ;

CLASS
	: T_TYPE_CLASS T_IDENTIFIER CLASS_BLOCK
	;

CLASS_FUNCTION_DECLARATION
	: TYPE T_USER_DEFINED_TYPE T_SCOPE_RESOLUTION T_IDENTIFIER T_PARAN_OPEN TYPE_LIST FUNCTION_PARAMETER_LIST T_PARAN_CLOSE BLOCK
	| TYPE T_USER_DEFINED_TYPE T_SCOPE_RESOLUTION T_IDENTIFIER T_PARAN_OPEN TYPE_LIST FUNCTION_PARAMETER_LIST T_PARAN_CLOSE STATEMENT
	;

CLASS_BLOCK
	: T_BLOCK_START CLASS_BODY T_BLOCK_END
	;

BLOCK
	: T_BLOCK_START STATEMENTS T_BLOCK_END
	| T_BLOCK_START T_BLOCK_END
	;

FUNCTION_PROTOTYPE
	: TYPE T_IDENTIFIER T_PARAN_OPEN TYPE_LIST T_PARAN_CLOSE T_SEMI_COLON
	;

TYPE_LIST
	: TYPE_LIST T_COMMA TYPE
	| TYPE
	| TYPE_LIST T_COMMA TYPE T_SQ_OPEN T_SQ_CLOSE
	| TYPE T_SQ_OPEN T_SQ_CLOSE
	;

FUNCTION_DEFINITION
	: TYPE T_IDENTIFIER T_PARAN_OPEN TYPE_LIST FUNCTION_PARAMETER_LIST T_PARAN_CLOSE T_SEMI_COLON
	;

FUNCTION_DECALARATION
	: TYPE T_IDENTIFIER T_PARAN_OPEN TYPE_LIST FUNCTION_PARAMETER_LIST T_PARAN_CLOSE BLOCK
	| TYPE T_IDENTIFIER T_PARAN_OPEN TYPE_LIST FUNCTION_PARAMETER_LIST T_PARAN_CLOSE T_SEMI_COLON STATEMENT
	;

FUNCTION_PARAMETER_LIST
	: FUNCTION_PARAMETER_LIST TYPE T_IDENTIFIER
	| FUNCTION_PARAMETER_LIST TYPE T_IDENTIFIER T_OP_ASSIGNMENT EXPRESSION
	| TYPE T_IDENTIFIER
	| TYPE T_IDENTIFIER T_OP_ASSIGNMENT EXPRESSION
	;

STATEMENTS
	: STATEMENTS STATEMENT T_SEMI_COLON
	| STATEMENT T_SEMI_COLON

STATEMENT
	: VARIABLE_INTIALIZATION
	| VARIABLE_ASSIGNMENT
	| IF_ELSE_BLOCK
	| FOR_LOOP
	| RETURN_STATEMENT
	| FUNCTION_CALL
	;

EXPRESSION

CONDITION

CLASS_BODY

VARIABLE_INTIALIZATION

VARIABLE_ASSIGNMENT

IF_ELSE_BLOCK

FOR_LOOP

RETURN_STATEMENT

FUNCTION_CALL
	: T_IDENTIFIER T_PARAN_OPEN PARAMETER_LIST T_PARAN_CLOSE
	| TODO: CHAINING OF FUNCTION CALLS
	;

PARAMETER_LIST
	:

LITERAL
	: T_NUMBER_LITERAL
	| T_STRING_LITERAL
	| T_CHAR_LITERAL
	;

RELATIONAL_OPERATOR
	: T_REL_OP_LESS_THAN
	| T_REL_OP_LESS_THAN_EQUAL
	| T_REL_OP_GREATER_THAN_EQUAL
	| T_REL_OP_GREATER_THAN
	| T_REL_OP_EQUAL
	;

TYPE
	: T_TYPE_INT,
	| T_TYPE_CHAR,
	| T_TYPE_STRING,
	| T_TYPE_FLOAT,
	| T_TYPE_DOUBLE,
	| T_USER_DEFINED_TYPE
	| T_TYPE_VOID
	;

%%

int main(int argc, char *argv[]) {

    int isError = yyparse();
    if (isError) {
        printf("Error has Occured while parsing\n");
    }
    else {
        printf("Parsing successful!!!\n");
    }
    return 0;

}

unsigned int hash_function(char *name)
{
	unsigned int hash_value = 0;
	for(;name!='\0';++name)
	{
		hash_value = hash_value +(int)(*name);
	}
	hash_value = hash_value % SYMBOL_TABLE_SIZE;
	return hash_value;
}
symbol_table* lookup()
{
	unsigned int hash_value = hash_function(name);
	node_t *temp = complete_symbol_table[hash_value];

	while(temp!=NULL)
	{
		if(strcmp(temp->st->name,name)==0)
		{
			return temp->st;
		}
		temp = temp->next;
	}
	return NULL;
}
node_t *create_node()
{
	node_t *new_node = (node_t*)malloc(sizeof(node_t));
	new_node->st = (symbol_table*)malloc(sizeof(symbol_table));
	strcpy(new_node->st->name,name);
	new_node->st->next = NULL;
	return new_node;
}
symbol_table* insert()
{
	unsigned int hash_value = hash_function(name);
	node_t *temp = complete_symbol_table[hash_value];
	if(temp!=NULL)
	{
		while(temp->next!=NULL)
		{
			temp = temp->next;
		}
		temp->next = create_node();
		temp = temp->next;
	}
	else
	{
		complete_symbol_table[hash_value] = create_node();
		temp = 	complete_symbol_table[hash_value];
	}
	return temp->st;
}
void display_symbol_table()
{
	printf("---------SYMBOL TABLE---------\n");
	printf("Token\tType\tScope\tLine Number\n")
	for(int i=0;i<SYMBOL_TABLE_SIZE;++i)
	{
		node_t *temp = complete_symbol_table[i];
		while(temp!=NULL)
		{
			printf("%s\t%s\t%s\t")
		}
	}
}