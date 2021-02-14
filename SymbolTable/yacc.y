%{

    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

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
	symbol_table* insert();
	node_t *create_node(char *name);

	symbol_table* insert(char *name, char *category, char *type, int line_number);
	symbol_table* lookup_and_insert(char *name, char *category, char *type, int line_number);
	symbol_table* lookup(char *name);
	void scope_enter();
	void scope_leave();

	char *variable_declaration_type = (char *)malloc(20 * sizeof(char));
	strcpy(variable_declaration_type, "\0");

%}

%start START

// ---------------- TOKENS ------------------

// Datatypes
%token T_TYPE_INT T_TYPE_FLOAT T_TYPE_DOUBLE T_TYPE_STRING T_TYPE_CHAR T_TYPE_VOID T_TYPE_CLASS T_USER_DEFINED_TYPE T_NUMBER_LITERAL T_STRING_LITERAL T_CHAR_LITERAL T_IDENTIFIER

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
%token T_BIT_OP_AND T_BIT_OP_OR T_BIT_OP_XOR T_BIT_OP_RIGHT_SHIFT T_BIT_OP_LEFT_SHIFT '!'

// Assignment Operators
%token '=' T_OP_ADD_ASSIGNMENT T_OP_SUBTRACT_ASSIGNMENT T_OP_MULTIPLY_ASSIGNMENT T_OP_DIVIDE_ASSIGNMENT T_OP_MOD_ASSIGNMENT

// Other Operators
%token '+' '-' '*' '/' '%' T_OP_INCREMENT T_OP_DECREMENT

// Input Output Tokens
// Insertion: >> for cin, Extraction: << for cout
%token T_IO_COUT T_IO_CIN T_IO_PRINTF T_IO_SCANF T_IO_GETLINE T_IO_INSERTION T_IO_EXTRACTION

// Jump Tokens
%token T_JUMP_BREAK T_JUMP_EXIT T_JUMP_CONTINUE

// Other Tokens
%token '(' ')' ';' T_DOUBLE_QUOTES_OPEN T_DOUBLE_QUOTES_CLOSE T_COLON T_SCOPE_RESOLUTION '[' ']' ',' T_RETURN '.'

%right T_IO_EXTRACTION T_IO_INSERTION

%right '(' ')'

%right '=' T_OP_ADD_ASSIGNMENT T_OP_SUBTRACT_ASSIGNMENT T_OP_MULTIPLY_ASSIGNMENT T_OP_DIVIDE_ASSIGNMENT T_OP_MOD_ASSIGNMENT

%right '<' '>' T_REL_OP_GREATER_THAN_EQUAL T_REL_OP_LESS_THAN_EQUAL T_REL_OP_EQUAL

%left '+' '-'

%left '*' '/'

%left T_BIT_OP_AND T_BIT_OP_OR T_BIT_OP_XOR

%%

START
	: INCLUDE BODY
	| BODY
	| INCLUDE
	;

INCLUDE
	: INCLUDE T_HEADER_INCLUDE '<' T_HEADER_FILE '>'
	| INCLUDE T_HEADER_INCLUDE T_STRING_LITERAL
	| T_HEADER_INCLUDE '<' T_HEADER_FILE '>'
	| T_HEADER_INCLUDE T_STRING_LITERAL
	;

BODY
	: BODY_BLOCK BODY
	| BODY_BLOCK
	;

BODY_BLOCK
	: FUNCTION
	| BLOCK
	;

FUNCTION
	: FUNCTION_PROTOTYPE
	| FUNCTION_DEFINITION
	| FUNCTION_DECLARATION
	;

FUNCTION_PROTOTYPE
	: TYPE T_IDENTIFIER '(' TYPE_LIST ')' ';' {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Identifier', $1, @1.last_line );
	}
	| TYPE T_IDENTIFIER '(' ')' ';' {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Identifier', $1, @1.last_line );
	}
	;

TYPE_LIST
	: TYPE ',' TYPE_LIST {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
	}
	| TYPE {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
	}
	;

FUNCTION_DEFINITION
	: TYPE T_IDENTIFIER '(' FUNCTION_PARAMETER_LIST ')' ';' {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Function', $1, @1.last_line);
	}
	;

FUNCTION_DECLARATION
	: TYPE T_IDENTIFIER '(' FUNCTION_PARAMETER_LIST ')' BLOCK {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Function', $1, @1.last_line);
	}
	| TYPE T_IDENTIFIER '(' ')' BLOCK {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Function', $1, @1.last_line);
	}
	;

FUNCTION_PARAMETER_LIST
	: TYPE T_IDENTIFIER ',' FUNCTION_PARAMETER_LIST {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Identifier', $1, @1.last_line);
	}
	| TYPE T_IDENTIFIER '=' EXPRESSION ',' FUNCTION_PARAMETER_LIST {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Identifier', $1, @1.last_line);
	}
	| TYPE T_IDENTIFIER {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Identifier', $1, @1.last_line);
	}
	| TYPE T_IDENTIFIER '=' EXPRESSION {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		insert($2, 'Identifier', $1, @1.last_line);
	}
	;


BLOCK
	: BLOCK_START STATEMENTS BLOCK_END
	;

BLOCK_START
	: '{' { scope_enter(); }
	;

BLOCK_END
	: '}' { scope_leave(); }
	;

STATEMENTS
	: STATEMENT STATEMENTS
	| STATEMENT
	;

IF_BLOCK
	: T_CONSTRUCT_IF '(' EXPRESSION ')' STATEMENT
	;

ELSE_BLOCK
	: T_CONSTRUCT_ELSE STATEMENT
	;

FOR_BLOCK
	: T_CONSTRUCT_FOR '(' FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' STATEMENT
	;

FOR_INIT_STATEMENT
	:
	| LINE_STATEMENT
	;

FOR_CONDITION_STATEMENT
	: 
	| CONDITIONAL_EXPRESSION
	;

FOR_ACTION_STATEMENT
	: 
	| LINE_STATEMENT
	;

BITWISE_OPERATOR
	: T_BIT_OP_AND
	| T_BIT_OP_OR
	| T_BIT_OP_XOR
	;

CONDITIONAL_EXPRESSION
	: EXPRESSION LOGICAL_OPERATOR EXPRESSION_GRAMMAR
	| EXPRESSION RELATIONAL_OPERATOR EXPRESSION_GRAMMAR
	| EXPRESSION BITWISE_OPERATOR EXPRESSION_GRAMMAR
	;

ASSIGNMENT
	: T_IDENTIFIER ASSIGNMENT_OPERATOR EXPRESSION_GRAMMAR {
		if (variable_declaration_type[0] != '\0)
			insert($1, 'Identifier', variable_declaration_type, @1.last_line);
		lookup($1);
	}
	| T_IDENTIFIER ASSIGNMENT_OPERATOR ASSIGNMENT {
		if (variable_declaration_type[0] != '\0)
			insert($1, 'Identifier', variable_declaration_type, @1.last_line);
		lookup($1);
	}
	;

ASSIGNMENT_OPERATOR
	: '='
	| T_OP_ADD_ASSIGNMENT
	| T_OP_SUBTRACT_ASSIGNMENT
	| T_OP_MULTIPLY_ASSIGNMENT
	| T_OP_DIVIDE_ASSIGNMENT
	| T_OP_MOD_ASSIGNMENT
	;

EXPRESSION
	: ASSIGNMENT
	| CONDITIONAL_EXPRESSION
	| EXPRESSION_GRAMMAR
	;

EXPRESSION_GRAMMAR
	: EXPRESSION_GRAMMAR '+' EXPRESSION_TERM
	| EXPRESSION_GRAMMAR '-' EXPRESSION_TERM
	| EXPRESSION_TERM
	;

EXPRESSION_TERM
	: EXPRESSION_TERM '*' EXPRESSION_F
	| EXPRESSION_TERM '/' EXPRESSION_F
	| EXPRESSION_TERM '%' EXPRESSION_F
	| EXPRESSION_F
	| '!' EXPRESSION_F
	;

EXPRESSION_F
	: IDENTIFIER_OR_LITERAL
	| '(' EXPRESSION ')'
	;

BLOCK_STATEMENT
	: IF_BLOCK
	| ELSE_BLOCK
	| FOR_BLOCK
	| BLOCK
	;

STATEMENT
	: LINE_STATEMENT ';'
	| BLOCK_STATEMENT
	| ';'
	;

JUMP_STATEMENT
	: T_JUMP_BREAK
	| T_JUMP_EXIT
	| T_JUMP_CONTINUE
	;

LINE_STATEMENT
	: VARIABLE_DECLARATION
	| EXPRESSION
	| COUT
	| CIN
	| RETURN
	| JUMP_STATEMENT
	;

VARIABLE_DECLARATION
	: VARIABLE_DECLARATION_TYPE VARIABLE_LIST {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
		strcpy(variable_declaration_type, $1);
	}
	;

VARIABLE_DECLARATION_TYPE
	: TYPE
	;

VARIABLE_LIST
	: T_IDENTIFIER ',' VARIABLE_LIST {
		insert($1, 'Identifier', variable_declaration_type, @1.last_line);
	}
	| ASSIGNMENT ',' VARIABLE_LIST
	| T_IDENTIFIER {
		insert($1, 'Identifier', variable_declaration_type, @1.last_line);
		strcpy(variable_declaration_type, "\0");
	}
	| ASSIGNMENT {
		insert($1, 'Identifier', variable_declaration_type, @1.last_line);
		strcpy(variable_declaration_type, "\0");
	}
	;

COUT
	: T_IO_COUT T_IO_EXTRACTION EXTRACTION_LIST
	;

EXTRACTION_LIST
	: EXPRESSION T_IO_EXTRACTION EXTRACTION_LIST
	| EXPRESSION
	;

CIN
	: T_IO_CIN T_IO_INSERTION INSERTION_LIST
	;

INSERTION_LIST
	: T_IDENTIFIER T_IO_EXTRACTION INSERTION_LIST
	| T_IDENTIFIER
	;

RETURN
	: T_RETURN EXPRESSION
	;

LOGICAL_OPERATOR
	: T_LOG_OP_AND
	| T_LOG_OP_OR
	;

RELATIONAL_OPERATOR
	: T_REL_OP_EQUAL
	| '>'
	| T_REL_OP_GREATER_THAN_EQUAL
	| '<'
	| T_REL_OP_LESS_THAN_EQUAL
	| T_REL_OP_NOT_EQUAL
	;

IDENTIFIER_OR_LITERAL
	: T_IDENTIFIER {
		lookup($1);
	}
	| T_IDENTIFIER T_OP_INCREMENT {
		lookup($1);
	}
	| T_OP_DECREMENT T_IDENTIFIER {
		lookup($2);
	}
	| T_CHAR_LITERAL {
		lookup_and_insert($1, 'Constant', NULL, @1.last_line);
	}
	| T_NUMBER_LITERAL {
		lookup_and_insert($1, 'Constant', NULL, @1.last_line);
	}
	| T_STRING_LITERAL {
		lookup_and_insert($1, 'Constant', NULL, @1.last_line);
	}
	;

TYPE
	: T_TYPE_INT {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
	}
	| T_TYPE_DOUBLE {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
	}
	| T_TYPE_FLOAT {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
	}
	| T_TYPE_CHAR {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
	}
	| T_TYPE_STRING {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
	}
	| T_TYPE_VOID {
		lookup_and_insert($1, 'Datatype', NULL, @1.last_line);
	}
	;

%%

int yyerror(){
  printf("ERROR\n");
}

int main(int argc, char *argv[]) {

	yyin = fopen("test1.cpp","r");

    int isError = yyparse();

    if (isError) {
        printf("Error has Occured while parsing\n");
    }
    else {
        printf("Parsing successful!!!\n");
    }
    return 0;

}
// void init_symbol_table()
// {
// 	for(int i=0;i<SYMBOL_TABLE_SIZE;++i)
// 	{
// 		complete_symbol_table[i]->st = NULL;
// 	}
// }
// unsigned int hash_function(char *name)
// {
// 	unsigned int hash_value = 0;
// 	for(;*name!='\0';++name)
// 	{
// 		hash_value = hash_value +(int)(*name);
// 	}
// 	hash_value = hash_value % SYMBOL_TABLE_SIZE;
// 	return hash_value;
// }
// symbol_table* lookup(char *name)
// {
// 	unsigned int hash_value = hash_function(name);
// 	node_t *temp = complete_symbol_table[hash_value];

// 	while(temp!=NULL)
// 	{
// 		if(strcmp(temp->st->name,name)==0)
// 		{
// 			return temp->st;
// 		}
// 		temp = temp->next;
// 	}
// 	return NULL;
// }
// node_t *create_node(char *name)
// {
// 	node_t *new_node = (node_t*)malloc(sizeof(node_t));
// 	new_node->st = (symbol_table*)malloc(sizeof(symbol_table));
// 	strcpy(new_node->st->name,name);
// 	new_node->next = NULL;
// 	return new_node;
// }
// symbol_table* insert(char *name)
// {
// 	unsigned int hash_value = hash_function(name);
// 	node_t *temp = complete_symbol_table[hash_value];
// 	if(temp!=NULL)
// 	{
// 		while(temp->next!=NULL)
// 		{
// 			temp = temp->next;
// 		}
// 		// temp->next = create_node();
// 		temp = temp->next;
// 	}
// 	else
// 	{
// 		// complete_symbol_table[hash_value] = create_node();
// 		temp = 	complete_symbol_table[hash_value];
// 	}
// 	return temp->st;
// }
// void display_symbol_table()
// {
// 	printf("---------SYMBOL TABLE---------\n");
// 	printf("Token\tType\tScope\tLine Number\n");
// 	for(int i=0;i<SYMBOL_TABLE_SIZE;++i)
// 	{
// 		node_t* temp = complete_symbol_table[i];
// 		while(temp!=NULL)
// 		{
// 			printf("%s\t%s\t%s\t");
// 		}
// 	}
// }
