%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    int yylex();
    int yyerror(char *s);
%}

%start START

// ---------------- TOKENS ------------------

// Datatypes
%token TYPE_INT TYPE_FLOAT TYPE_STRING TYPE_CHAR TYPE_VOID USER_DEFINED_TYPE TYPE_ARRAY NUMBER_LITERAL STRING_LITERAL CHAR_LITERAL IDENTIFIER

// Required Construct Tokens
%token CONSTRUCT_IF CONSTRUCT_ELSE CONSTRUCT_FOR

// Block Tokens
%token BLOCK_CLASS BLOCK_FUNCTION BLOCK_START BLOCK_END

// Class Tokens
%token ACCESS_PUBLIC ACCESS_PRIVATE ACCESS_PROTECTED

// Header Tokens
%token HEADER_INCLUDE HEADER_FILE

// Relational Operator Tokens
%token REL_OP_GREATER_THAN REL_OP_LESS_THAN REL_OP_ADD REL_OP_GREATER_THAN_EQUAL REL_OP_LESS_THAN_EQUAL REL_OP_EQUAL

// Logical Operators
%token LOG_OP_OR LOG_OP_AND

// Bitwise Operators
%token BIT_OP_AND BIT_OP_OR BIT_OP_XOR BIT_OP_RIGHT_SHIFT BIT_OP_LEFT_SHIFT

// Other Operators
%token OP_ASSIGNMENT OP_ADD OP_SUBTRACT OP_MULTIPLY OP_DIVIDE OP_INCREMENT OP_DECREMENT

// Input Output Tokens
// Insertion: >> for cin, Extraction: << for cout
%token IO_COUT IO_CIN IO_PRINTF IO_SCANF IO_GETLINE IO_INSERTION IO_EXTRACTION

// Other Tokens
%token PARAN_OPEN PARAN_CLOSE SEMI_COLON DOUBLE_QUOTES_OPEN DOUBLE_QUOTES_CLOSE

%%

START
    : HEADER MAIN {
        printf("Grammar Matched!\n");
    }
    ;

HEADER
    : HEADER INCLUDE
    | INCLUDE
    ;

INCLUDE
    : HEADER_INCLUDE REL_OP_LESS_THAN HEADER_FILE REL_OP_GREATER_THAN
    | HEADER_INCLUDE DOUBLE_QUOTES_OPEN HEADER_FILE DOUBLE_QUOTES_CLOSE
    ;

MAIN:
    ;

%%

int main(int argc, char *argv[]) {

    const isError = yyparse();
    if (isError) {
        printf("Error has Occured while parsing\n");
    }
    else {
        printf("Parsing successful!!!\n");
    }
    return 0;
}