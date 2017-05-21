%{
#include <stdio.h>
int yylex();
void yyerror(const char* msg);
%}

%token TYPE_INT TYPE_DOUBLE TYPE_BOOL TYPE_CHAR
%token OP_PLUS OP_MINUS OP_MULTIPLE OP_DIVIDE OP_PERCENT OP_2PLUS OP_2MINUS OP_LESS OP_LE OP_GREATER OP_GE OP_2EQUAL OP_NE OP_EQUAL OP_AND OP_OR OP_NOT OP_POINTER OP_ADDR
%token PUNC_COLON PUNC_SEMICOLON PUNC_COMMA PUNC_DOT PUNC_LBRACKET PUNC_RBRACKET PUNC_LPERAN PUNC_RPERAN PUNC_LBRACE PUNC_RBRACE
%token KEY_VOID KEY_NULL KEY_FOR KEY_WHILE KEY_DO KEY_IF KEY_ELSE KEY_SWITCH KEY_RETURN KEY_BREAK KEY_CONTINUE KEY_CONST KEY_TRUE KEY_FALSE KEY_STRUCT KEY_CASE KEY_DEFAULT
%token STDIO_PRINTF STDIO_SCANF STDIO_GETC STDIO_GETS STDIO_GETCHAR STDIO_PUTS STDIO_PUTCHAR STDIO_CLEARERR STDIO_FOPEN STDIO_FCLOSE STDIO_GETW STDIO_PUTW STDIO_PUTC STDIO_FPUTC STDIO_FGETS STDIO_FPUTS STDIO_FEOF STDIO_FGETC STDIO_FPRINTF STDIO_FSCANF STDIO_FSEEK STDIO_FTELL STDIO_REWIND STDIO_SPRINTF STDIO_SSCANF STDIO_REMOVE STDIO_FFLUSH
%token TOKEN_ID TOKEN_STRING TOKEN_CHAR TOKEN_INTEGER TOKEN_DOUBLE TOKEN_SCI
%token OTHER_SPACE OTHER_COMMENT OTHER_MULTICOMMENT OTHRE_SOURCEON OTHER_SOURCEOFF OTHER_TOKENON OTHER_TOKENOFF

%start starting_unit
%%

starting_unit
		: external_declaration
		| starting_unit external_declaration
		;

external_declaration
		: function_definition
		| declaration
		;

declaration_list
		: declaration
		| declaration_list declaration
		;

declaration
		: declaration_specifiers ';'
		| declaration_specifiers init_declarator_list ';'
		;

declaration_specifiers
		: type_specifier
		| type_specifier declaration_specifiers
		| type_qualifier
		| type_qualifier declaration_specifiers
		;

type_specifier
		: TYPE_CHAR
		| TYPE_BOOL
		| TYPE_INT
		| TYPE_DOUBLE
		; /* not support struct or union except array */

type_qualifier
		: KEY_CONST
		; /* not support restrict atomic volatile */

init_declarator_list
		: init_declarator
		| init_declarator_list ',' init_declarator
		;

init_declarator
		: declarator '=' initializer
		| declarator
		;

function_definition
		: declaration_specifiers declarator declaration_list compound_statement
		| declaration_specifiers declarator compound_statement
		;

initializer
		: '{' initializer_list '}'
		| '{' initializer_list ',' '}'
		| assignment_expression
		;

initializer_list
		: designation initializer
		| initializer
		| initializer_list ',' designation initializer
		| initializer_list ',' initializer
		;

designation
		: designator_list '='
		;

designator_list
		: designator
		| designator_list designator
		;

designator
		: '.' TOKEN_ID
		;

declarator
		: direct_declarator
		; /* not support pointer */

direct_declarator
		: TOKEN_ID
		| '(' declarator ')'
		| direct_declarator '[' TOKEN_INTEGER ']' /* todo may need to let int > 0*/
		| direct_declarator '(' ')'
		| direct_declarator '(' parameter_list ')'
		| direct_declarator '(' identifier_list ')'
		;

identifier_list
		: TOKEN_ID
		| identifier_list ',' TOKEN_ID
		;


parameter_list
		: parameter_declaration
		| parameter_list ',' parameter_declaration
		;

parameter_declaration
		: declaration_specifiers declarator
		| declaration_specifiers
		; /* ignore abstract delaration here */

compound_statement
		: '{' '}'
		| '{' block_item_list '}'
		;

block_item_list
		: block_item
		| block_item_list block_item
		;

block_item
		: declaration
		| statement
		;

statement
		: compound_statement
		| expression_statement
		| selection_statement
		| iteration_statement
		| jump_statement
		; /* not support labeled statement */

expression_statement
		: ';'
		| expression ';'
		;

expression
		: assignment_expression
		| expression ',' assignment_expression
		;

assignment_expression
		: conditional_expression
		| unary_expression assignment_expression assignment_expression
		;

conditional_expression
		: logical_or_expression
		| logical_or_expression '?' expression ':' conditional_expression /* may not need to support */
		;

logical_or_expression
		: logical_and_expression
		| logical_or_expression OP_OR logical_and_expression
		;

logical_and_expression
		: inclusive_or_expression
		| logical_and_expression OP_AND inclusive_or_expression
		;

inclusive_or_expression
		: exclusive_or_expression
		| inclusive_or_expression '|' exclusive_or_expression
		;

exclusive_or_expression
		: and_expression 
		| exclusive_or_expression '^' and_expression
		; /* may need to eliminate */

and_expression
		: equality_expression
		| and_expression '&' equality_expression
		;

equality_expression
		: relational_expression
		| equality_expression OP_2EQUAL relational_expression
		| equality_expression OP_NE relational_expression
		;

relational_expression
		: shift_expression
		| relational_expression OP_GREATER shift_expression
		| relational_expression OP_GE shift_expression
		| relational_expression OP_LESS shift_expression
		| relational_expression OP_LE shift_expression
		;

shift_expression
		: additive_expression
		; /* not support << >> punc */

additive_expression
		: multiplicative_expression
		| additive_expression OP_PLUS multiplicative_expression
		| additive_expression OP_MINUS multiplicative_expression
		;

multiplicative_expression
		: cast_expression
		| multiplicative_expression OP_MULTIPLE cast_expression
		| multiplicative_expression OP_DIVIDE cast_expression
		| multiplicative_expression OP_PERCENT cast_expression
		;

cast_expression
		: unary_expression
		; /* not support type cast */

unary_expression
		: postfix_expression
		| OP_2PLUS unary_expression
		| OP_2MINUS unary_expression
		| unary_operator cast_expression
		; /* not support sizeof alignof */

unary_operator
		: OP_ADDR
		| OP_POINTER
		| OP_PLUS
		| OP_MINUS
		| OP_NOT
		;

postfix_expression
		: primary_expression
		| postfix_expression '[' TOKEN_INTEGER ']'
		| postfix_expression '(' ')'
		| postfix_expression '(' argument_expression_list ')'
		| postfix_expression '.' TOKEN_ID
		| postfix_expression OP_2PLUS
		| postfix_expression OP_2MINUS
		; /* may need to support initializer list */

primary_expression
		: TOKEN_ID
		| constant
		| TOKEN_STRING
		| '(' expression ')'
		;

constant
		: TOKEN_INTEGER
		| TOKEN_DOUBLE
		| TOKEN_SCI
		;

argument_expression_list
		: assignment_expression
		| argument_expression_list ',' assignment_expression
		;

selection_statement
		: KEY_IF '(' expression ')' statement KEY_ELSE statement
		| KEY_IF '(' expression ')' statement
		| KEY_SWITCH '(' expression ')' statement
		;

iteration_statement
		: KEY_WHILE '(' expression ')' statement
		| KEY_DO statement KEY_WHILE '(' expression ')' ';'
		| KEY_FOR '(' expression_statement expression_statement ')' statement
		| KEY_FOR '(' expression_statement expression_statement expression ')' statement
		| KEY_FOR '(' declaration expression_statement ')' statement
		| KEY_FOR '(' declaration expression_statement expression ')' statement
		;

jump_statement
		: KEY_CONTINUE ';'
		| KEY_BREAK ';'
		| KEY_RETURN ';'
		| KEY_RETURN expression ';'
		;
%%
int main(){
	return yyparse();
}

