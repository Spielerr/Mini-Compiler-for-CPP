%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define SYMBOL_TABLE_SIZE 1000
	#define MAX_IDENTIFIER_SIZE 32
	typedef struct symbol_table
	{
		int line_number;
		char name[MAX_IDENTIFIER_SIZE];
		char type[MAX_IDENTIFIER_SIZE];
		char value[MAX_IDENTIFIER_SIZE];
		int size;
		int scope;
	}symbol_table;

	typedef struct node
	{
		symbol_table *st;
		struct node *next;
	}node_t;

	node_t* complete_symbol_table = (node_t*)malloc(sizeof(node_t)*SYMBOL_TABLE_SIZE);

	//lookup
	//free
	//allocate
	//insert
	//get_attribute
	//set_attribute

	// handle shift reduce conflicts
%}
%%

%%

int main()
{
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
	new_node->st->next = NULL:
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