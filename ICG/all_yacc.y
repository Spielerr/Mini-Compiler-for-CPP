%{

    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	// #define YYSTYPE char *

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
	void display_quadruples();
	void remove_entry_st(char *name);

	void yyerror(char *s);

	int current_scope = 0;
	int scopes[SYMBOL_TABLE_SIZE];
	int scope_counter = 0;

	char variable_declaration_type[20] = "\0";

	int is_in_construct = 0;

	struct quadruple{
    	char op[10];
    	char arg1[20];
    	char arg2[20];
    	char res[20];
    	struct quadruple *next;
	};
	typedef struct quadruple quadruple;

	quadruple q[100];
	int q_len = 0;

	void push(char *x);
	void expr_code_gen(char *op);
	void code_assign();
	void new_label();
	void for_condition();
	void for_action();
	void for_after();
	void incr_decr(char);
	void unary_code_gen(char);
	void if_cond();
	void after_if();
	void code_reassign(char *);
	void after_control_block();
	void shorthand_op(char);
	void gen_break();

	int nflag = 0;
	int sflag = 0;
	int bflag = 0;
	int cflag = 0;
	int id_used = 0;
	int se = 0;
	char var_name[50];

	#define TAC 1
%}

%union {
	char *str;
	struct s1 {char *type;} type_info;
    // struct temp *o;
	// char *type;
}

%start START

// ---------------- TOKENS ------------------

// Datatypes
%token <str> T_TYPE_INT T_TYPE_FLOAT T_TYPE_DOUBLE T_TYPE_BOOL T_TYPE_STRING T_TYPE_CHAR T_TYPE_VOID T_TYPE_CLASS T_USER_DEFINED_TYPE T_IDENTIFIER

// Literals
%token  <str> T_CHAR_LITERAL T_STRING_LITERAL T_NUMBER_LITERAL T_BOOL_LITERAL

// Required Construct Tokens
%token <str> T_CONSTRUCT_IF T_CONSTRUCT_ELSE T_CONSTRUCT_FOR

// Block Tokens
%token <str> '{' '}'

// Class Tokens
%token <str> T_ACCESS_PUBLIC T_ACCESS_PRIVATE T_ACCESS_PROTECTED

// Header Tokens
%token <str> T_HEADER_INCLUDE T_HEADER_FILE

// Relational Operator Tokens
%token <str> '>' '<' T_REL_OP_GREATER_THAN_EQUAL T_REL_OP_LESS_THAN_EQUAL T_REL_OP_EQUAL T_REL_OP_NOT_EQUAL

// Logical Operators
%token <str> T_LOG_OP_OR T_LOG_OP_AND

// Bitwise Operators
%token <str> '&' '|' '^' T_BIT_OP_RIGHT_SHIFT T_BIT_OP_LEFT_SHIFT '!'

// Assignment Operators
%token <str> '=' T_OP_ADD_ASSIGNMENT T_OP_SUBTRACT_ASSIGNMENT T_OP_MULTIPLY_ASSIGNMENT T_OP_DIVIDE_ASSIGNMENT T_OP_MOD_ASSIGNMENT

// Other Operators
%token <str> '+' '-' '*' '/' '%' T_OP_INCREMENT T_OP_DECREMENT

// Input Output Tokens
// Insertion: << for cin, Extraction: >> for cout
%token <str> T_IO_COUT T_IO_CIN T_IO_PRINTF T_IO_SCANF T_IO_GETLINE T_IO_INSERTION T_IO_EXTRACTION

// Jump Tokens
%token <str> T_JUMP_BREAK T_JUMP_EXIT T_JUMP_CONTINUE

// Other Tokens
%token <str> '(' ')' ';' T_DOUBLE_QUOTES_OPEN T_DOUBLE_QUOTES_CLOSE T_COLON T_SCOPE_RESOLUTION '[' ']' ',' T_RETURN '.' T_SQ_BRACKET T_COMMENT

%type <str> BITWISE_OPERATOR IDENTIFIER_OR_LITERAL UNARY_OPERATOR TYPE CONDITIONAL_EXPRESSION ASSIGNMENT ASSIGNMENT_OPERATOR EXPRESSION EXPRESSION_GRAMMAR EXPRESSION_TERM EXPRESSION_F VARIABLE_DECLARATION VARIABLE_DECLARATION_TYPE VARIABLE_LIST VARIABLE_DECLARATION_IDENTIFIER ARRAY_VARIABLE_DECLARATION_IDENTIFIER ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE ARRAY_LIST LITERAL_LIST COUT INSERTION_LIST CIN EXTRACTION_LIST RETURN LOGICAL_OPERATOR RELATIONAL_OPERATOR


%right T_IO_EXTRACTION T_IO_INSERTION

%right '(' ')'

%right '=' T_OP_ADD_ASSIGNMENT T_OP_SUBTRACT_ASSIGNMENT T_OP_MULTIPLY_ASSIGNMENT T_OP_DIVIDE_ASSIGNMENT T_OP_MOD_ASSIGNMENT

%right '<' '>' T_REL_OP_GREATER_THAN_EQUAL T_REL_OP_LESS_THAN_EQUAL T_REL_OP_EQUAL

%left '+' '-'

%left '*' '/'

%left '&' '|' '^'

%nonassoc IF_PREC

%nonassoc T_CONSTRUCT_ELSE

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
		if (insert($2, "Identifier", $1, @2.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
	}
	| TYPE T_IDENTIFIER '=' EXPRESSION ',' FUNCTION_PARAMETER_LIST {
		if (insert($2, "Identifier", $1, @2.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
        symbol_table* element = lookup($2);
		strcpy(element->value, $4);
	}
	| TYPE T_IDENTIFIER {
		if (insert($2, "Identifier", $1, @2.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
	}
	| TYPE T_IDENTIFIER '=' EXPRESSION {
		if (insert($2, "Identifier", $1, @2.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - Function Parameter \"%s\" has already been declared\n", @2.last_line, $2);
		}
        symbol_table* element = lookup($2);
		strcpy(element->value, $4);
	}
	;

FUNCTION_PREFIX
	: TYPE T_IDENTIFIER '(' {
		insert($2, "Function-Identifier", $1, @2.last_line, NULL);
		scope_enter();
	}
	;

BLOCK
	: BLOCK_START STATEMENTS BLOCK_END
	;

BLOCK_START
	: '{' {
        scope_enter();
    }
	;

BLOCK_END
	: '}' {
        scope_leave();
    }
	;

STATEMENTS
	: STATEMENT STATEMENTS
	| STATEMENT
	;

SINGLE_LINE_IF
	: IF_PREFIX LINE_STATEMENT ';' {
		after_if();
		scope_leave();
	}
	| IF_PREFIX ';' {
		scope_leave();
	}
	| IF_PREFIX CONSTRUCT {
		after_if();
		scope_leave();
	}
	| SINGLE_LINE_IF SINGLE_LINE_ELSE
	| SINGLE_LINE_IF BLOCK_ELSE	
	;

BLOCK_IF
	: T_CONSTRUCT_IF '(' EXPRESSION ')' {if_cond();} BLOCK {after_if();}
	| BLOCK_IF SINGLE_LINE_ELSE
	| BLOCK_IF BLOCK_ELSE
	;

IF_PREFIX
	: T_CONSTRUCT_IF '(' EXPRESSION ')' {
		if_cond();
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
		is_in_construct -= 1;
		for_after();
	}
	| FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' ';' {
		scope_leave();
		is_in_construct -= 1;
		for_after();
	}
	| FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' CONSTRUCT {
		scope_leave();
		is_in_construct -= 1;
		for_after();
	}
	;

BLOCK_FOR
	: FOR_PREFIX FOR_INIT_STATEMENT ';' FOR_CONDITION_STATEMENT ';' FOR_ACTION_STATEMENT ')' '{' STATEMENTS '}'{
		scope_leave();
		is_in_construct -= 1;
		for_after();
	}
	;

FOR_PREFIX
	: T_CONSTRUCT_FOR '(' {
		scope_enter();
		is_in_construct += 1;
	}
	;

FOR_INIT_STATEMENT
	:
	| LINE_STATEMENT {new_label();}
	;

FOR_CONDITION_STATEMENT
	:
	| CONDITIONAL_EXPRESSION { for_condition();}
	;

FOR_ACTION_STATEMENT
	:
	| LINE_STATEMENT {for_action();}
	;

BITWISE_OPERATOR
	: '&' {
        $$ = strdup($1);
    }
	| '|' {
        $$ = strdup($1);
    }
	| '^' {
        $$ = strdup($1);
    }
	;

CONDITIONAL_EXPRESSION
	: EXPRESSION LOGICAL_OPERATOR EXPRESSION_GRAMMAR {
        sprintf($$, "%s %s %s", $1, $2, $3);
        $$ = strdup($$);
		expr_code_gen($2);
    }
	| EXPRESSION RELATIONAL_OPERATOR EXPRESSION_GRAMMAR {
        sprintf($$, "%s %s %s", $1, $2, $3);
        $$ = strdup($$);
		expr_code_gen($2);
    }
	| EXPRESSION BITWISE_OPERATOR EXPRESSION_GRAMMAR {
        sprintf($$, "%s %s %s", $1, $2, $3);
        $$ = strdup($$);
		expr_code_gen($2);
    }
	;

ASSIGNMENT
	: T_IDENTIFIER ASSIGNMENT_OPERATOR EXPRESSION_GRAMMAR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
			sprintf($$, "%s %s %s", $1, $2, $3);
        	$$ = strdup($$);
		}
		else
		{
			push($1);
			sprintf($$, "%s %s %s", $1, $2, $3);
			$$ = strdup($$);
			code_reassign($2);
		}
	}
	| T_IDENTIFIER ASSIGNMENT_OPERATOR ASSIGNMENT {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
			sprintf($$, "%s %s %s", $1, $2, $3);
        	$$ = strdup($$);
		}
		else
		{
			push($1);
			sprintf($$, "%s %s %s", $1, $2, $3);
			$$ = strdup($$);
			code_reassign($2);
		}
	}
	| T_IDENTIFIER '[' EXPRESSION ']' ASSIGNMENT_OPERATOR EXPRESSION_GRAMMAR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
        sprintf($$, "%s [ %s ] %s %s", $1, $3, $5, $6);
        $$ = strdup($$);
	}
	| T_IDENTIFIER '[' EXPRESSION ']' ASSIGNMENT_OPERATOR ASSIGNMENT {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared Variable \"%s\" \n", @1.last_line, $1);
		}
        sprintf($$, "%s [ %s ] %s %s", $1, $3, $5, $6);
        $$ = strdup($$);
	}
	;

ASSIGNMENT_OPERATOR
	: '=' {
        $$ = strdup($1);
    }
	| T_OP_ADD_ASSIGNMENT {
        $$ = strdup($1);
    }
	| T_OP_SUBTRACT_ASSIGNMENT {
        $$ = strdup($1);
    }
	| T_OP_MULTIPLY_ASSIGNMENT {
        $$ = strdup($1);
    }
	| T_OP_DIVIDE_ASSIGNMENT {
        $$ = strdup($1);
    }
	| T_OP_MOD_ASSIGNMENT {
        $$ = strdup($1);
    }
	;

EXPRESSION
	: ASSIGNMENT {
        $$ = strdup($1);
    }
	| CONDITIONAL_EXPRESSION {
        $$ = strdup($1);
    }
	| EXPRESSION_GRAMMAR {
        $$ = strdup($1);
    }
	;

EXPRESSION_GRAMMAR
	: EXPRESSION_GRAMMAR '+' EXPRESSION_TERM {
		// if(sflag)
		// {
		// 	sprintf($$, "%s + %s", $1, $3);
        // 	$$ = strdup($$);
		// 	printf("[Semantic Error] at line:%d - invalid operation on operator +\n", @1.last_line);
		// 	sflag = 0;
		// 	se = 1;
		// }
		// else
		// {
		// 	expr_code_gen($2);
		// 	sprintf($$, "%s + %s", $1, $3);
		// 	$$ = strdup($$);
		// }
		sprintf($$, "%s + %s", $1, $3);
        $$ = strdup($$);
		expr_code_gen($2);
		if(sflag)
		{
			printf("[Semantic Error] at line:%d - invalid operation on operator +\n", @1.last_line);
			sflag = 0;
			se = 1;
		}
    }
	| EXPRESSION_GRAMMAR '-' EXPRESSION_TERM {
		// if(sflag)
		// {
		// 	sprintf($$, "%s - %s", $1, $3);
        // 	$$ = strdup($$);
		// 	printf("[Semantic Error] at line:%d - invalid operation on operator -\n", @1.last_line);
		// 	sflag = 0;
		// 	se = 1;
		// }
		// else
		// {
		// 	expr_code_gen($2);
		// 	sprintf($$, "%s - %s", $1, $3);
		// 	$$ = strdup($$);
		// }
		sprintf($$, "%s - %s", $1, $3);
        $$ = strdup($$);
		expr_code_gen($2);
		if(sflag)
		{
			printf("[Semantic Error] at line:%d - invalid operation on operator -\n", @1.last_line);
			sflag = 0;
			se = 1;
		}
    }
	| EXPRESSION_TERM {
        $$ = strdup($1);
    }
	;

EXPRESSION_TERM
	: EXPRESSION_TERM '*' EXPRESSION_F {
		// if(sflag)
		// {
		// 	sprintf($$, "%s * %s", $1, $3);
        // 	$$ = strdup($$);
		// 	printf("[Semantic Error] at line:%d - invalid operation on operator *\n", @1.last_line);
		// 	sflag = 0;
		// 	se = 1;
		// }
		// else
		// {
		// 	// expr_code_gen($2);
		// 	sprintf($$, "%s * %s", $1, $3);
		// 	$$ = strdup($$);
		// }
		expr_code_gen($2);
        sprintf($$, "%s * %s", $1, $3);
        $$ = strdup($$);
		if(sflag)
		{
			printf("[Semantic Error] at line:%d - invalid operation on operator *\n", @1.last_line);
			sflag = 0;
			se = 1;
		}
    }
	| EXPRESSION_TERM '/' EXPRESSION_F {
		// if(sflag)
		// {
		// 	sprintf($$, "%s / %s", $1, $3);
        // 	$$ = strdup($$);
		// 	printf("[Semantic Error] at line:%d - invalid operation on operator /\n", @1.last_line);
		// 	sflag = 0;
		// 	se = 1;
		// }
		// else
		// {
		// 	expr_code_gen($2);
		// 	sprintf($$, "%s / %s", $1, $3);
		// 	$$ = strdup($$);
		// }
		expr_code_gen($2);
        sprintf($$, "%s / %s", $1, $3);
        $$ = strdup($$);
		if(sflag)
		{
			printf("[Semantic Error] at line:%d - invalid operation on operator /\n", @1.last_line);
			sflag = 0;
			se = 1;
		}
    }
	| EXPRESSION_TERM '%' EXPRESSION_F {
		// if(sflag)
		// {
		// 	sprintf($$, "%s %% %s", $1, $3);
        // 	$$ = strdup($$);
		// 	printf("[Semantic Error] at line:%d - invalid operation on operator %%\n", @1.last_line);
		// 	sflag = 0;
		// 	se = 1;
		// }
		// else
		// {
		// 	expr_code_gen($2);
		// 	sprintf($$, "%s %% %s", $1, $3);
		// 	$$ = strdup($$);
		// }
		expr_code_gen($2);
        sprintf($$, "%s %% %s", $1, $3);
        $$ = strdup($$);
		if(sflag)
		{
			printf("[Semantic Error] at line:%d - invalid operation on operator %%\n", @1.last_line);
			sflag = 0;
			se = 1;
		}
    }
	| EXPRESSION_F {
        $$ = strdup($1);
    }
	| '!' EXPRESSION_F {
        sprintf($$, "! %s", $2);
        $$ = strdup($$);
		if(sflag)
		{
			printf("[Semantic Error] at line:%d - invalid operation on operator !\n", @1.last_line);
			sflag = 0;
			se = 1;
		}
    }
	;

EXPRESSION_F
	: IDENTIFIER_OR_LITERAL {
        $$ = strdup($1);
    }
	| '(' EXPRESSION ')' {
        sprintf($$, "( %s )", $2);
        $$ = strdup($$);
    }
	| '+' EXPRESSION_F {
        sprintf($$, "+ %s", $2);
        $$ = strdup($$);
		unary_code_gen('+');
    }
	| '-' EXPRESSION_F {
        sprintf($$, "- %s", $2);
        $$ = strdup($$);
		unary_code_gen('-');

    }
	;

CONSTRUCT
	: SINGLE_LINE_CONSTRUCT
	| BLOCK_CONSTRUCT
	;

BLOCK_CONSTRUCT
	: BLOCK_FOR
	| BLOCK_IF %prec IF_PREC { after_control_block();}
	;

SINGLE_LINE_CONSTRUCT
	: SINGLE_LINE_FOR
	| SINGLE_LINE_IF %prec IF_PREC {after_control_block();}
	;

STATEMENT
	: LINE_STATEMENT ';'
	| CONSTRUCT
	| BLOCK
	| ';'
	;

JUMP_STATEMENT
	: T_JUMP_BREAK {
		if (is_in_construct == 0)
			printf("[Error] at line:%d - \"break\" statement not within loop or switch\n", @1.last_line);
		else
		{
			gen_break();
		}
	}
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
        sprintf($$, "%s %s", $1, $2);
        $$ = strdup($$);
	}
	;

VARIABLE_DECLARATION_TYPE
	: TYPE {
		strcpy(variable_declaration_type, $1);
        $$ = strdup($1);
	}
	;

VARIABLE_LIST
	: VARIABLE_DECLARATION_IDENTIFIER ',' VARIABLE_LIST {
        sprintf($$, "%s , %s", $1, $3);
        $$ = strdup($$);
    }
	| VARIABLE_DECLARATION_IDENTIFIER '=' EXPRESSION ',' VARIABLE_LIST {
		symbol_table* element = lookup($1);
		strcpy(var_name, element -> name);
		sprintf(element->value, "%s", $3);
        sprintf($$, "%s = %s , %s", $1, $3, $5);
        $$ = strdup($$);
		if(se)
		{
			remove_entry_st(element -> name);
			se = 0;
		}
		if(sflag)
		{
			if(strcmp(element->type, "string"))
			{
				printf("[Semantic Error] at line:%d - Assigning string to %s \n", @1.last_line, element->type);
				// remove entry from symbol table
				remove_entry_st(element -> name);
			}
			sflag = 0;
		}
		if(nflag)
		{
			if(!strcmp(element->type, "bool"))
			{
				// element->value = (bool)(atof())
				if(atof(element -> value))
				{
					sprintf(element->value, "%s", "true");
				}
				else
				{
					sprintf(element->value, "%s", "false");
				}
			}
			if(!strcmp(element->type, "int"))
			{
				// printf("***********prob\n");
				// printf("%s\n", element->value);
				if(!((element->value)[0] == 't'))
				{
					// printf("voila************\n");
					int temp = (int)(atof(element->value));
					sprintf(element->value, "%d", temp);
				}
				// element->value = (bool)(atof())
				// sprintf(element->value, "%s", (int)(atof($3)));
				// int temp = (int)(atof(element->value));
				// sprintf(element->value, "%d", temp);
			}
			nflag = 0;
		}
		if(cflag)
		{
			if(!strcmp(element->type, "bool"))
			{
				sprintf(element->value, "%s", "true");
			}
			if(!strcmp(element->type, "int"))
			{
				// element->value = (bool)(atof())
				// sprintf(element->value, "%s", (int)(atof($3)));
				int temp = (int)(element->value[1]);
				sprintf(element->value, "%d", temp);
			}
			cflag = 0;
		}
		if(bflag)
		{
			if(!strcmp(element->type, "int") || !strcmp(element->type, "float") || !strcmp(element->type, "double"))
			{
				if(!strcmp(element -> value, "true"))
					sprintf(element->value, "%d", 1);
				else
					sprintf(element->value, "%d", 0);
			}
			if(!strcmp(element->type, "char"))
			{
				if(!strcmp(element -> value, "true"))
					sprintf(element->value, "%s", "\'1\'");
				else
					sprintf(element->value, "%s", "\'0\'");
			}
			bflag = 0;
		}
	}
	| VARIABLE_DECLARATION_IDENTIFIER {
        $$ = strdup($1);
    }
	| VARIABLE_DECLARATION_IDENTIFIER '=' EXPRESSION {
		symbol_table* element = lookup($1);
		strcpy(var_name, element -> name);
		strcpy(element->value, $3);
        sprintf($$, "%s = %s", $1, $3);
        $$ = strdup($$);
		code_assign();
		if(se)
		{
			remove_entry_st(element -> name);
			se = 0;
		}
		if(sflag)
		{
			if(strcmp(element->type, "string"))
			{
				printf("[Semantic Error] at line:%d - Assigning string to %s \n", @1.last_line, element->type);
				// remove entry from symbol 
				remove_entry_st(element -> name);
			}
			sflag = 0;
		}
		if(nflag)
		{
			// printf("***************\n");
			if(!strcmp(element->type, "bool"))
			{
				// element->value = (bool)(atof())
				if(atof(element -> value))
				{
					sprintf(element->value, "%s", "true");
				}
				else
				{
					sprintf(element->value, "%s", "false");
				}
			}
			if(!strcmp(element->type, "int"))
			{
				// printf("*************prob\n");
				// printf("%s\n", element->value);
				if(!((element->value)[0] == 't'))
				{
					// printf("voila************\n");
					int temp = (int)(atof(element->value));
					sprintf(element->value, "%d", temp);
				}
				// element->value = (bool)(atof())
				// sprintf(element->value, "%s", (int)(atof($3)));
				// int temp = (int)(atof(element->value));
				// sprintf(element->value, "%d", temp);
			}
			nflag = 0;
		}
		if(cflag)
		{
			if(!strcmp(element->type, "bool"))
			{
				sprintf(element->value, "%s", "true");
			}
			if(!strcmp(element->type, "int"))
			{
				// element->value = (bool)(atof())
				// sprintf(element->value, "%s", (int)(atof($3)));
				int temp = (int)(element->value[1]);
				sprintf(element->value, "%d", temp);
			}
			cflag = 0;
		}
		if(bflag)
		{
			if(!strcmp(element->type, "int") || !strcmp(element->type, "float") || !strcmp(element->type, "double"))
			{
				if(!strcmp(element -> value, "true"))
					sprintf(element->value, "%d", 1);
				else
					sprintf(element->value, "%d", 0);
			}
			if(!strcmp(element->type, "char"))
			{
				if(!strcmp(element -> value, "true"))
					sprintf(element->value, "%s", "\'1\'");
				else
					sprintf(element->value, "%s", "\'0\'");
			}
			bflag = 0;
		}
	}

	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE ',' VARIABLE_LIST {
        sprintf($$, "%s , %s", $1, $3);
        $$ = strdup($$);
    }
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER '=' ARRAY_LIST ',' VARIABLE_LIST {
        sprintf($$, "%s = %s , %s", $1, $3, $5);
        $$ = strdup($$);
    }
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE {
        $$ = strdup($1);
    }
	| ARRAY_VARIABLE_DECLARATION_IDENTIFIER '=' ARRAY_LIST {
        sprintf($$, "%s = %s", $1, $3);
        $$ = strdup($$);
    }
	;

VARIABLE_DECLARATION_IDENTIFIER
	: T_IDENTIFIER {
		if (insert($1, "Identifier", variable_declaration_type, @1.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
        $$ = strdup($1);
		push($1);
	}
	;

ARRAY_VARIABLE_DECLARATION_IDENTIFIER
	: T_IDENTIFIER '[' ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
        sprintf($$, "%s []", $1);
        $$ = strdup($$);
	}
	| T_IDENTIFIER '[' EXPRESSION ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
        sprintf($$, "%s [ %s ]", $1, $3);
        $$ = strdup($$);
	}
	;

ARRAY_VARIABLE_DECLARATION_IDENTIFIER_WITH_SIZE
	: T_IDENTIFIER '[' EXPRESSION ']' {
		if (insert($1, "Identifier-Array", variable_declaration_type, @1.last_line, NULL) == NULL) {
			printf("[Error] at line:%d - \"%s\" has already been declared\n", @1.last_line, $1);
		}
        sprintf($$, "%s [ %s ]", $1, $3);
        $$ = strdup($$);
	}
	;

ARRAY_LIST
	: '{' LITERAL_LIST '}' {
        sprintf($$, "{ %s }", $2);
        $$ = strdup($$);
    }
	| T_STRING_LITERAL {
        $$ = strdup($1);
    }
	;

LITERAL_LIST
	: IDENTIFIER_OR_LITERAL ',' LITERAL_LIST {
        sprintf($$, "%s , %s", $1, $3);
        $$ = strdup($$);
    }
	| IDENTIFIER_OR_LITERAL {
        $$ = strdup($1);
    }
	;

COUT
	: T_IO_COUT T_IO_INSERTION INSERTION_LIST {
        sprintf($$, "%s %s %s", $1, $2, $3);
        $$ = strdup($$);
    }
	;

INSERTION_LIST
	: EXPRESSION T_IO_INSERTION INSERTION_LIST {
        sprintf($$, "%s %s %s", $1, $2, $3);
        $$ = strdup($$);
    }
	| EXPRESSION {
        $$ = strdup($1);
    }
	;

CIN
	: T_IO_CIN T_IO_EXTRACTION EXTRACTION_LIST {
        sprintf($$, "%s %s %s", $1, $2, $3);
        $$ = strdup($$);
    }
	;

EXTRACTION_LIST
	: T_IDENTIFIER T_IO_EXTRACTION EXTRACTION_LIST {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
        sprintf($$, "%s %s %s", $1, $2, $3);
        $$ = strdup($$);
	}
	| T_IDENTIFIER {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		$$ = strdup($1);
	}
	;

RETURN
	: T_RETURN EXPRESSION {
        sprintf($$, "%s %s", $1, $2);
        $$ = strdup($$);
    }
	;

LOGICAL_OPERATOR
	: T_LOG_OP_AND {
        $$ = strdup($1);
    }
	| T_LOG_OP_OR {
        $$ = strdup($1);
    }
	;

RELATIONAL_OPERATOR
	: T_REL_OP_EQUAL {
        $$ = strdup($1);
    }
	| '>' {
        $$ = strdup($1);
    }
	| T_REL_OP_GREATER_THAN_EQUAL {
        $$ = strdup($1);
    }
	| '<' {
        $$ = strdup($1);
    }
	| T_REL_OP_LESS_THAN_EQUAL {
        $$ = strdup($1);
    }
	| T_REL_OP_NOT_EQUAL {
        $$ = strdup($1);
    }
	;

IDENTIFIER_OR_LITERAL
	: T_IDENTIFIER {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		else
		{
			symbol_table* element = lookup($1);
			if(!strcmp(element->type, "string"))
				sflag += 1;
			else if((!strcmp(element->type, "int")) || (!strcmp(element->type, "string")))
				nflag += 1;
			else if(!strcmp(element->type, "char"))
				cflag += 1;
			else if(!strcmp(element->type, "bool"))
				bflag += 1;
		}
		push($1);
		$$ = strdup($1);
	}
	| T_IDENTIFIER '(' ')' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Function \"%s\" not defined \n", @1.last_line, $1);
		}
		else
		{
			symbol_table* element = lookup($1);
			if(!strcmp(element->type, "string"))
				sflag += 1;
			else if((!strcmp(element->type, "int")) || (!strcmp(element->type, "string")))
				nflag += 1;
			else if(!strcmp(element->type, "char"))
				cflag += 1;
			else if(!strcmp(element->type, "bool"))
				bflag += 1;
		}
		sprintf($$, "%s ()", $1);
        $$ = strdup($$);
	}
	| T_IDENTIFIER '(' LITERAL_LIST ')' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Function \"%s\" not defined \n", @1.last_line, $1);
		}
		else
		{
			symbol_table* element = lookup($1);
			if(!strcmp(element->type, "string"))
				sflag += 1;
			else if((!strcmp(element->type, "int")) || (!strcmp(element->type, "string")))
				nflag += 1;
			else if(!strcmp(element->type, "char"))
				cflag += 1;
			else if(!strcmp(element->type, "bool"))
				bflag += 1;
		}
		sprintf($$, "%s ( %s )", $1, $3);
        $$ = strdup($$);
	}
	| T_IDENTIFIER UNARY_OPERATOR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		else
		{
			symbol_table* element = lookup($1);
			if(!strcmp(element->type, "string"))
				sflag += 1;
			else if((!strcmp(element->type, "int")) || (!strcmp(element->type, "string")))
				nflag += 1;
			else if(!strcmp(element->type, "char"))
				cflag += 1;
			else if(!strcmp(element->type, "bool"))
				bflag += 1;
		}
		sprintf($$, "%s %s", $1, $2);
        $$ = strdup($$);
	}
	| UNARY_OPERATOR T_IDENTIFIER {
		if (lookup($2) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @2.last_line, $2);
		}
		else
		{
			symbol_table* element = lookup($2);
			if(!strcmp(element->type, "string"))
				sflag += 1;
			else if((!strcmp(element->type, "int")) || (!strcmp(element->type, "string")))
				nflag += 1;
			else if(!strcmp(element->type, "char"))
				cflag += 1;
			else if(!strcmp(element->type, "bool"))
				bflag += 1;
		}
		sprintf($$, "%s %s", $1, $2);
        $$ = strdup($$);
	}
	| T_IDENTIFIER '[' EXPRESSION ']' {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		else
		{
			symbol_table* element = lookup($1);
			if(!strcmp(element->type, "string"))
				sflag += 1;
			else if((!strcmp(element->type, "int")) || (!strcmp(element->type, "string")))
				nflag += 1;
			else if(!strcmp(element->type, "char"))
				cflag += 1;
			else if(!strcmp(element->type, "bool"))
				bflag += 1;
		}
		sprintf($$, "%s [ %s ]", $1, $3);
        $$ = strdup($$);
	}
	| UNARY_OPERATOR T_IDENTIFIER '[' EXPRESSION ']' {
		if (lookup($2) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @2.last_line, $2);
		}
		else
		{
			symbol_table* element = lookup($2);
			if(!strcmp(element->type, "string"))
				sflag += 1;
			else if((!strcmp(element->type, "int")) || (!strcmp(element->type, "string")))
				nflag += 1;
			else if(!strcmp(element->type, "char"))
				cflag += 1;
			else if(!strcmp(element->type, "bool"))
				bflag += 1;
		}
		sprintf($$, "%s %s [ %s ]", $1, $2, $4);
        $$ = strdup($$);
	}
	| T_IDENTIFIER '[' EXPRESSION  ']' UNARY_OPERATOR {
		if (lookup($1) == NULL) {
			printf("[Error] at line:%d - Undeclared variable \"%s\" \n", @1.last_line, $1);
		}
		else
		{
			symbol_table* element = lookup($1);
			if(!strcmp(element->type, "string"))
				sflag += 1;
			else if((!strcmp(element->type, "int")) || (!strcmp(element->type, "string")))
				nflag += 1;
			else if(!strcmp(element->type, "char"))
				cflag += 1;
			else if(!strcmp(element->type, "bool"))
				bflag += 1;
		}
		sprintf($$, "%s [ %s ] %s", $1, $3, $5);
        $$ = strdup($$);
	}
	| T_CHAR_LITERAL {
		push($1);
        $$ = strdup($1);
		cflag += 1;
    }
	| T_NUMBER_LITERAL {
		push($1);
        $$ = strdup($1);
		nflag += 1;
    }
	| T_STRING_LITERAL {
		push($1);
        $$ = strdup($1);
		sflag += 1;
    }
	| T_BOOL_LITERAL {
		push($1);
        $$ = strdup($1);
		bflag += 1;
    }
	;

UNARY_OPERATOR
	: T_OP_INCREMENT {
        $$ = strdup($1);
		incr_decr('+');
    }
	| T_OP_DECREMENT {
        $$ = strdup($1);
		incr_decr('-');

    }
	;

TYPE
	: T_TYPE_INT {
		$$ = strdup($1);
	}
	| T_TYPE_DOUBLE {
		$$ = strdup($1);
	}
	| T_TYPE_FLOAT {
		$$ = strdup($1);
	}
	| T_TYPE_CHAR {
		$$ = strdup($1);
	}
	| T_TYPE_STRING {
		$$ = strdup($1);
	}
	| T_TYPE_VOID {
		$$ = strdup($1);
	}
	| T_TYPE_BOOL {
		$$ = strdup($1);
	}
	;

%%
int temp_id = 0;
int label_id = 0;
int DEBUG = 0;
char stack[1000][1000];
int top = 0;
int label_top = -1;
int label_match[100];
int if_label_top = -1;
int if_label_stack[100];
int if_label = -1;
void create_quad(char *arg1,char *arg2, char* res,char *op)
{
	strcpy(q[q_len].op,op);
	strcpy(q[q_len].arg1,arg1);
	strcpy(q[q_len].arg2,arg2);
	strcpy(q[q_len].res,res);
	q_len+=1;
}
void expr_code_gen(char *op)
{
	// create temp
	if(TAC)
	{
		if(DEBUG)
			printf("top :%d\n",top);
		char temp_var[20];
		sprintf(temp_var,"t%d",temp_id);
		temp_id+=1;
		printf("%s = %s %s %s\n",temp_var,stack[top-1],op,stack[top]);
		char value_temp[40000];
		sprintf(value_temp,"%s %s %s",stack[top-1],op,stack[top]);
		insert(temp_var,"temporary","", 0, value_temp);
		//quadruple add
		create_quad(stack[top-1],stack[top],temp_var,op);

		top-=1;
		strcpy(stack[top],temp_var);
	}

}
void code_reassign(char *op)
{
	if(TAC)
	{
		if(strlen(op)==2)
		{
			// printf("shorthand op\n");
			char temp_var[10];
			sprintf(temp_var,"t%d",temp_id);
			temp_id+=1;

			printf("%s = %s %c %s\n",temp_var,stack[top],op[0],stack[top-1]);
			//quadruple add
			op[1]='\0';
			create_quad(stack[top],stack[top-1],temp_var,op);

			char value_temp[20000];
			sprintf(value_temp,"%s %c %s",stack[top],op[0],stack[top-1]);
			insert(temp_var,"temporary","", 0, value_temp);

			printf("%s = %s\n",stack[top],temp_var);
			create_quad(stack[top],"",temp_var,"=");
			symbol_table* temp_variable_st = lookup(stack[top]);
			strcpy(temp_variable_st->value,temp_var);
			
			top-=1;
			return;
		}
		if(DEBUG)
			printf("topa :%d\n",top);
		printf("%s = %s\n",stack[top],stack[top-1]);
		
		create_quad(stack[top-1],"",stack[top],"=");
		top-=1;
	}
}
void code_assign()
{
	if(TAC)
	{
		if(DEBUG)
			printf("topa :%d\n",top);
		printf("%s = %s\n",stack[top-1],stack[top]);

		create_quad(stack[top],"",stack[top-1],"=");

		symbol_table* temp_variable_st = lookup(stack[top-1]);
		strcpy(temp_variable_st->value,stack[top]);

		top-=1;
	}
}
void push(char *x)
{
	if(TAC)
	{
		strcpy(stack[++top], x);
		if(DEBUG)
			printf("Pushed %s\n",x);
	}
}
void new_label()
{
	if(TAC)
	{
		printf("L%d:\n",label_id);
		
		char label_temp[10];
		sprintf(label_temp,"L%d",label_id);
		create_quad("","","label",label_temp);

		label_match[++label_top] = label_id;
		label_id+=1;
	}
}
void for_condition()
{
	if(TAC)
	{
		char label_temp[10];
		sprintf(label_temp,"L%d",label_id);

		printf("if t%d goto L%d\n",temp_id-1,label_id);
		
		char temp_var[10];
		sprintf(temp_var,"t%d",temp_id-1);

		create_quad(temp_var,"",label_temp,"if");
		
		top-=1;
		if(DEBUG)
		{
			printf("topx: %d\n",top);
		}
		label_match[++label_top] = label_id;
		label_id+=1;
		label_match[++label_top] = label_id;
		printf("goto L%d\n",label_id);

		sprintf(label_temp,"L%d",label_id);
		create_quad("","",label_temp,"goto");

		label_match[++label_top] = ++label_id;
		printf("L%d:\n",label_id);
		sprintf(label_temp,"L%d",label_id);
		create_quad("","","label",label_temp);
		label_id+=1;
	}
}
void for_action()
{
	if(TAC)
	{
		char label_temp[10];
		sprintf(label_temp,"L%d",label_match[label_top-3]);

		printf("goto L%d\n",label_match[label_top-3]);
		create_quad("","",label_temp,"goto");
		printf("L%d:\n",label_match[label_top-2]);
		sprintf(label_temp,"L%d",label_match[label_top-3]);
		create_quad("","","label",label_temp);
		top-=1;
	}
}
void for_after()
{
	if(TAC)
	{
		/* printf("for after\n"); */
		char label_temp[10];
		sprintf(label_temp,"L%d",label_match[label_top]);
		if(DEBUG)
		{
			int x = label_top;
			printf("label stack contents: \n");
			while(x!=-1)
			{
				printf("top: %d val: %d ",x,label_match[x]);
				x-=1;
			}
			printf("\n");
		}
		printf("goto L%d\n",label_match[label_top]);
		create_quad("","",label_temp,"goto");
		label_top-=1;
		
		printf("L%d:\n",label_match[label_top]);
		sprintf(label_temp,"L%d",label_match[label_top]);
		create_quad("","","label",label_temp);

		label_top-=3;
	}
}
void unary_code_gen(char op)
{
	if(TAC)
	{
		char temp_var[10];
		sprintf(temp_var,"t%d",temp_id);
		temp_id+=1;
		char temp_op[5];
		temp_op[0] = op;
		temp_op[1] = '\0';
		printf("%s = %c %s\n",temp_var,op,stack[top]);
		create_quad(stack[top],"",temp_op,temp_var);
		
		char value_temp[20000];
		sprintf(value_temp,"%c %s",op,stack[top]);
		insert(temp_var,"temporary","", 0, value_temp);
		
		top-=1;
		strcpy(stack[top],temp_var);
	}
}
void incr_decr(char op)
{
	if(TAC)
	{
		char temp_var[10];
		sprintf(temp_var,"t%d",temp_id);
		temp_id+=1;

		char temp_op[5];
		temp_op[0] = op;
		temp_op[1] = '\0';
		
		printf("%s = %s %c %d\n",temp_var,stack[top],op,1);
		create_quad(stack[top],"1",temp_var,temp_op);
		
		printf("%s = %s\n",stack[top],temp_var);
		create_quad(temp_var,"",stack[top],"=");
		top-=1;
	}
	// strcpy(stack[top],temp_var);
}
void if_cond()
{
	if(TAC)
	{
		char temp_var[10];
		sprintf(temp_var,"t%d",temp_id-1);

		char label_temp[10];
		sprintf(label_temp,"L%d",label_id);

		/* printf("if t%d goto L%d\n",temp_id-1,label_id);  */
		printf("if %s goto L%d\n",stack[top],label_id); 
		create_quad(stack[top],"","if",label_temp);

		label_id+=1;
		label_match[++label_top] = label_id;
		
		sprintf(label_temp,"L%d",label_id);
		
		printf("goto L%d\n",label_id);
		if_label_stack[++if_label_top] = label_id;

		create_quad("","",label_temp,"goto");
		
		printf("L%d:\n",label_id-1);

		sprintf(label_temp,"L%d",label_id-1);	
		create_quad("","","label",label_temp);
		
		label_id+=1;
	}
}
void after_if()
{
	if(TAC)
	{
		char label_temp[10];
		sprintf(label_temp,"L%d",label_id);

		printf("goto L%d\n",label_id);
		create_quad("","",label_temp,"goto");

		label_id+=1;
		printf("L%d:\n",if_label_stack[if_label_top]);

		sprintf(label_temp,"L%d",if_label_stack[if_label_top]);	
		create_quad("","","label",label_temp);

		if_label_top--;	
		label_top--;
		if_label_stack[++if_label_top] = label_id-1;
	}
}
void after_control_block()
{
	if(TAC)
	{
		printf("L%d:\n",if_label_stack[if_label_top]);

		char label_temp[10];
		sprintf(label_temp,"L%d",if_label_stack[if_label_top]);
		
		create_quad("","","label",label_temp);
		
		if_label_top--;
		/* label_top-=1; */

	}
}
void gen_break()
{
	if(TAC)
	{
		;
		/* printf("break\n");  */
		/* printf("goto L%d\n",label_match[label_top]); */
		/* label_top-=1; */
		/* printf("goto L%d\n",label_match[label_top]); */
		/* label_top-=1; */
		/* printf("goto L%d\n",label_match[label_top]); */

	}
}
void yyerror(char *s){
	printf("\n[Error] at line:%d, column:%d\n", yylloc.last_line, yylloc.last_column);
}
int main(int argc, char *argv[]) {

	yyin = fopen(argv[1],"r");

	init_symbol_table();

    FILE *fptr = fopen("tokens.txt", "w");
    fprintf(fptr, "TOKENS STREAMED\n");
    fprintf(fptr, "----------------------------------------------------------------------------------------------------------------------------------------------------------\n");
    fprintf(fptr, "Token Type\t\t\t\t\tToken Value\n");
    fprintf(fptr, "----------------------------------------------------------------------------------------------------------------------------------------------------------\n");
    fclose(fptr);

    int isError = yyparse();

    if (isError) {
        printf("\nPARSING IS UNSUCCESSFUL\n\n");
    }
    else {
        printf("\nPARSING IS SUCCESSFUL\n\n");
		display_symbol_table();
		display_quadruples();
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
    name = strdup(name);
	// printf("Lookup for %s with scope %d\n",name,current_scope);

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
			int x_scope = current_scope;
			if(x_scope==0)
			{
				return temp->st;
			}
			while(x_scope!=0)
			{
				int par_scope = scopes[x_scope];
				if(temp->st->scope==par_scope)
				{
					looked_up = temp->st;
					break;
				}
				x_scope = par_scope;
			}
		}
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
    name = strdup(name);
    category = strdup(category);
    type = strdup(type);

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
        int counter = 0;
		while(temp!=NULL)
		{
            counter++;
			printf("%-10s\t\t%-20s\t\t%-10s\t\t%10d\t\t%10d\t\t\t%s\n",temp->st->name,temp->st->category,temp->st->type,temp->st->line_number,temp->st->scope, temp->st->value);
			temp = temp->next;
		}
	}
    printf("--------------------------------------------------------------------------------------------------------------------------------------------------------\n");
	printf("\n\n");

}
void display_quadruples()
{
	FILE *fptr = fopen("quad.txt","w");
	printf("--------------------------------------------------------------------------------------------------------------------------------------------------------\n");
	printf("QUADRUPLES\n");
	printf("Op\targ1\targ2\tres\n");
	for(int i=0;i<q_len;++i)
	{
		fprintf(fptr,"%s\t%s\t%s\t%s\n",q[i].op,q[i].arg1,q[i].arg2,q[i].res);
		printf("%s\t%s\t%s\t%s\n",q[i].op,q[i].arg1,q[i].arg2,q[i].res);

	}
	printf("--------------------------------------------------------------------------------------------------------------------------------------------------------\n");
}

void remove_entry_st(char *name)
{
	int hash_value = hash_function(name);
	node_t *temp = complete_symbol_table[hash_value];
	node_t *temp_prev = NULL;
	while(temp != NULL)
	{
		if((strcmp(temp->st->name, name) == 0) && (temp->st->scope == current_scope))
		{
			if(temp_prev == NULL)
			{
				complete_symbol_table[hash_value] = NULL;
				return;
			}
			temp_prev -> next = temp -> next;
		}
		else
		{
			temp_prev = temp;
			temp = temp -> next;
		}
	}
}