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

	symbol_table* insert(char *name, char *category, char *type, int line_number);
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
	: FUNCTION_PREFIX TYPE_LIST ')' ';'
	| FUNCTION_PREFIX ')' ';'
	;

TYPE_LIST
	: TYPE ',' TYPE_LIST 
	| TYPE
	;

FUNCTION_DEFINITION
	: FUNCTION_PREFIX FUNCTION_PARAMETER_LIST ')' ';' {
		scope_leave();
	}
	;

FUNCTION_DECLARATION
	: FUNCTION_PREFIX FUNCTION_PARAMETER_LIST ')' '{' STATEMENTS '}' {
		scope_leave();
	}
	| FUNCTION_PREFIX ')' '{' STATEMENTS '}' {
		scope_leave();
	}
	;

FUNCTION_PARAMETER_LIST
	: TYPE T_IDENTIFIER ',' FUNCTION_PARAMETER_LIST {
		if (insert($2, "Identifier", $1, @2.last_line) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
	}
	| TYPE T_IDENTIFIER '=' EXPRESSION ',' FUNCTION_PARAMETER_LIST {
		if (insert($2, "Identifier", $1, @2.last_line) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
	}
	| TYPE T_IDENTIFIER {
		if (insert($2, "Identifier", $1, @2.last_line) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
	}
	| TYPE T_IDENTIFIER '=' EXPRESSION {
		if (insert($2, "Identifier", $1, @2.last_line) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
	}
	;

FUNCTION_PREFIX
	: TYPE T_IDENTIFIER '(' {
		insert($2, "Function-Identifier", $1, @2.last_line );
		scope_enter();
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

SINGLE_LINE_IF
	: IF_PREFIX LINE_STATEMENT ';' {
		scope_leave();
	}
	| IF_PREFIX ';' {
		scope_leave();
	}
	| IF_PREFIX CONSTRUCT {
		scope_leave();
	}
	;

BLOCK_IF
	: T_CONSTRUCT_IF '(' EXPRESSION ')' BLOCK
	;

IF_PREFIX
	: T_CONSTRUCT_IF '(' EXPRESSION ')' {
		scope_enter();
	}
	;

SINGLE_LINE_ELSE
	: ELSE_PREFIX LINE_STATEMENT ';'{
		scope_leave();
	}
	| ELSE_PREFIX ';'{
		scope_leave();
	}
	| ELSE_PREFIX CONSTRUCT {
		scope_leave();
	}
	;

BLOCK_ELSE
	: T_CONSTRUCT_ELSE BLOCK
	;

ELSE_PREFIX
	: T_CONSTRUCT_ELSE {
		scope_enter();
	}
	;

SINGLE_LINE_FOR
	: FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' LINE_STATEMENT ';'{
		scope_leave();
	}
	| FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' ';'{
		scope_leave();
	}
	| FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' CONSTRUCT{
		scope_leave();
	}
	;

BLOCK_FOR
	: FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' '{' STATEMENTS '}'{
		scope_leave();
	}
	;

FOR_PREFIX
	: T_CONSTRUCT_FOR '(' {
		scope_enter();
	}
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
	: '&'
	| '|'
	| '^'
	;

CONDITIONAL_EXPRESSION
	: EXPRESSION LOGICAL_OPERATOR EXPRESSION_GRAMMAR
	| EXPRESSION RELATIONAL_OPERATOR EXPRESSION_GRAMMAR
	| EXPRESSION BITWISE_OPERATOR EXPRESSION_GRAMMAR
	;

ASSIGNMENT
	: T_IDENTIFIER ASSIGNMENT_OPERATOR EXPRESSION_GRAMMAR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
	}
	| T_IDENTIFIER ASSIGNMENT_OPERATOR ASSIGNMENT {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
	}
	| T_IDENTIFIER '[' EXPRESSION ']' ASSIGNMENT_OPERATOR EXPRESSION_GRAMMAR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
	}
	| T_IDENTIFIER '[' EXPRESSION ']' ASSIGNMENT_OPERATOR ASSIGNMENT {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
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
	| '+' EXPRESSION_F
	| '-' EXPRESSION_F
	;

CONSTRUCT
	: SINGLE_LINE_CONSTRUCT
	| BLOCK_CONSTRUCT
	;

BLOCK_CONSTRUCT
	: BLOCK_FOR
	| BLOCK_IF
	| BLOCK_ELSE
	;

SINGLE_LINE_CONSTRUCT
	: SINGLE_LINE_FOR
	| SINGLE_LINE_IF
	| SINGLE_LINE_ELSE
	;

STATEMENT
	: LINE_STATEMENT ';'
	| CONSTRUCT
	| BLOCK
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
		strcpy(variable_declaration_type, "\0");
	}
	;

VARIABLE_DECLARATION_TYPE
	: TYPE {
		strcpy(variable_declaration_type, $1);
	}
	;

VARIABLE_LIST
	: VARIABLE_DECLARATION_IDENTIFIER ',' VARIABLE_LIST
	| VARIABLE_DECLARATION_IDENTIFIER '=' EXPRESSION ',' VARIABLE_LIST
	| VARIABLE_DECLARATION_IDENTIFIER
	| VARIABLE_DECLARATION_IDENTIFIER '=' EXPRESSION

	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE ',' VARIABLE_LIST
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER '=' ARRAY_LIST ',' VARIABLE_LIST
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER '=' ARRAY_LIST
	;

VARIABLE_DECLARATION_IDENTIFIER
	: T_IDENTIFIER {
		if (insert($1, "Identifier", variable_declaration_type, @1.last_line) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
	}
	;

ARRAY_VARIABLE_DECLARATION_IDENTIFIER
	: T_IDENTIFIER '[' ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
	}
	| T_IDENTIFIER '[' EXPRESSION ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
	}
	;

ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE
	: T_IDENTIFIER '[' EXPRESSION ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
	}
	;
 
ARRAY_LIST
	: '{' LITERAL_LIST '}'
	;

LITERAL_LIST
	: IDENTIFIER_OR_LITERAL ',' LITERAL_LIST
	| IDENTIFIER_OR_LITERAL
	;

COUT
	: T_IO_COUT T_IO_INSERTION INSERTION_LIST
	;

INSERTION_LIST
	: EXPRESSION T_IO_INSERTION INSERTION_LIST
	| EXPRESSION
	;

CIN
	: T_IO_CIN T_IO_EXTRACTION EXTRACTION_LIST
	;

EXTRACTION_LIST
	: T_IDENTIFIER T_IO_EXTRACTION EXTRACTION_LIST {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
	}
	| T_IDENTIFIER {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		$$ = $1;
	}
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
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		$$ = $1;
	}
	| T_IDENTIFIER '(' ')' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		$$ = $1;
	}
	| T_IDENTIFIER '(' LITERAL_LIST ')' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		$$ = $1;
	}
	| T_IDENTIFIER UNARY_OPERATOR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		$$ = $1;
	}
	| UNARY_OPERATOR T_IDENTIFIER {
		if (lookup($2) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @2.last_line, $2);
		}
		$$ = $2;
	}
	| T_IDENTIFIER '[' EXPRESSION ']' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		$$ = $1;
	}
	| UNARY_OPERATOR T_IDENTIFIER '[' EXPRESSION ']' {
		if (lookup($2) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @2.last_line, $2);
		}
		$$ = $2;
	}
	| T_IDENTIFIER '[' EXPRESSION  ']' UNARY_OPERATOR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		$$ = $1;
	}
	| T_CHAR_LITERAL
	| T_NUMBER_LITERAL
	| T_STRING_LITERAL
	| T_BOOL_LITERAL
	;

UNARY_OPERATOR
	: T_OP_INCREMENT
	| T_OP_DECREMENT
	;

TYPE
	: T_TYPE_INT {  
		$$ = $1;
	}
	| T_TYPE_DOUBLE {
		$$ = $1;
	}
	| T_TYPE_FLOAT {
		$$ = $1;
	}
	| T_TYPE_CHAR {
		$$ = $1;
	}
	| T_TYPE_STRING {
		$$ = $1;
	}
	| T_TYPE_VOID {
		$$ = $1;
	}
	| T_TYPE_BOOL {
		$$ = $1;
	}
	;

%%

void yyerror(char *s){
	printf("\n[Error] at line:%d, column:%d\n", yylloc.last_line, yylloc.last_column);
}

int main(int argc, char *argv[]) {

	yyin = fopen("test2.cpp","r");
	
	init_symbol_table();

    int isError = yyparse();

    if (isError) {
        printf("\n\nParsing is unsuccessful\n\n");
    }
    else {
        printf("\n\nParsing is successful!\n\n");
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
			if(temp->st->scope==scopes[current_scope])
				looked_up = temp->st;
		}
		temp = temp->next;
	}
	return looked_up;
}
node_t *create_node(char *name, char *category, char *type, int line_number)
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
	new_node->st->line_number = line_number;
	new_node->st->scope = current_scope;
	new_node->next = NULL;
	return new_node;
}
symbol_table* insert(char *name, char *category, char *type, int line_number)
{
	// only in current scope
	unsigned int hash_value = hash_function(name);
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

		prev->next = create_node(name,category,type,line_number);
		temp = prev->next;
	}
	else
	{
		complete_symbol_table[hash_value] = create_node(name,category,type,line_number);
		temp = 	complete_symbol_table[hash_value];
	}
	return temp->st;
}
void display_symbol_table()
{
	printf("SYMBOL TABLE\n");
	printf("--------------------------------------------------------------------------------------------------------------------------\n");
	printf("Token\t\t\tCategory\t\t\tType\t\t\tLine Number\t\t\tScope\n");
	printf("--------------------------------------------------------------------------------------------------------------------------\n");
	for(int i=0;i<SYMBOL_TABLE_SIZE;++i)
	{
		node_t* temp = complete_symbol_table[i];
		while(temp!=NULL)
		{
			printf("%-10s\t\t%-20s\t\t%-10s\t\t%10d\t\t%10d\n",temp->st->name,temp->st->category,temp->st->type,temp->st->line_number,temp->st->scope);
			temp = temp->next;
		}
	}
	printf("\n\n");
}
