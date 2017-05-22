%{
#include <stdio.h>
int yylex();
void yyerror(const char* msg);
%}

%token TYPE_INT TYPE_DOUBLE TYPE_BOOL TYPE_CHAR
%token OP_PLUS OP_MINUS OP_MULTIPLE OP_DIVIDE OP_PERCENT OP_2PLUS OP_2MINUS OP_LESS OP_LE OP_GREATER OP_GE OP_2EQUAL OP_NE OP_EQUAL OP_AND OP_OR OP_NOT OP_POINTER OP_ADDR
%token PUNC_COLON PUNC_SEMICOLON PUNC_COMMA PUNC_DOT PUNC_LBRACKET PUNC_RBRACKET PUNC_LPERAN PUNC_RPERAN PUNC_LBRACE PUNC_RBRACE
%token KEY_VOID KEY_NULL KEY_FOR KEY_WHILE KEY_DO KEY_IF KEY_ELSE KEY_SWITCH KEY_RETURN KEY_BREAK KEY_CONTINUE KEY_CONST KEY_TRUE KEY_FALSE KEY_STRUCT KEY_CASE KEY_DEFAULT
/*%token STDIO_PRINTF STDIO_SCANF STDIO_GETC STDIO_GETS STDIO_GETCHAR STDIO_PUTS STDIO_PUTCHAR STDIO_CLEARERR STDIO_FOPEN STDIO_FCLOSE STDIO_GETW STDIO_PUTW STDIO_PUTC STDIO_FPUTC STDIO_FGETS STDIO_FPUTS STDIO_FEOF STDIO_FGETC STDIO_FPRINTF STDIO_FSCANF STDIO_FSEEK STDIO_FTELL STDIO_REWIND STDIO_SPRINTF STDIO_SSCANF STDIO_REMOVE STDIO_FFLUSH */
%token TOKEN_ID TOKEN_STRING TOKEN_CHAR TOKEN_INTEGER TOKEN_DOUBLE TOKEN_SCI
/*%token OTHER_SPACE OTHER_COMMENT OTHER_MULTICOMMENT OTHRE_SOURCEON OTHER_SOURCEOFF OTHER_TOKENON OTHER_TOKENOFF*/

%nonassoc LOWER_THAN_ELSE
%nonassoc KEY_ELSE

%start starting_unit
%%

starting_unit
		: zero_or_more_declaration function_definition
		;

zero_or_more_declaration
		: /* empty */
		| zero_or_more_declaration external_declaration	
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
		: declaration_const /* only variables */
		| declaration_no_const /* variables and array */
		;

declaration_const
		: declaration_specifiers_const PUNC_SEMICOLON
		| declaration_specifiers_const init_declarator_list_const PUNC_SEMICOLON
		;

declaration_specifiers_const
		: type_qualifier type_specifier
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

init_declarator_list_const
		: init_declarator_const
		| init_declarator_list_const PUNC_COMMA init_declarator_const
		;

init_declarator_const
		: declarator_const OP_EQUAL initializer
		| declarator_const
		;

declarator_const
		: direct_declarator_const
		; /* not support pointer */

direct_declarator_const
		: TOKEN_ID
		| PUNC_LPERAN declarator_const PUNC_RPERAN
		| direct_declarator_const PUNC_LPERAN PUNC_RPERAN
		| direct_declarator_const PUNC_LPERAN parameter_list PUNC_RPERAN
		| direct_declarator_const PUNC_LPERAN identifier_list PUNC_RPERAN
		;

declaration_no_const
		: declaration_specifiers_no_const PUNC_SEMICOLON
		| declaration_specifiers_no_const init_declarator_list_no_const PUNC_SEMICOLON
		;

declaration_specifiers_no_const
		: type_specifier
		| type_specifier declaration_specifiers_no_const
		;


init_declarator_list_no_const
		: init_declarator_no_const
		| init_declarator_list_no_const PUNC_COMMA init_declarator_no_const
		;

init_declarator_no_const
		: declarator_no_const OP_EQUAL initializer
		| declarator_no_const
		;

declarator_no_const
		: direct_declarator_no_const
		; /* not support pointer */

direct_declarator_no_const
		: TOKEN_ID
		| PUNC_LPERAN declarator_no_const PUNC_RPERAN
		| direct_declarator_no_const PUNC_LBRACKET TOKEN_INTEGER PUNC_RBRACKET /* todo may need to let int > 0*/
		| direct_declarator_no_const PUNC_LPERAN PUNC_RPERAN
		| direct_declarator_no_const PUNC_LPERAN parameter_list PUNC_RPERAN
		| direct_declarator_no_const PUNC_LPERAN identifier_list PUNC_RPERAN
		;


function_definition
		: declaration_specifiers_no_const declarator_no_const declaration_list compound_statement
		| declaration_specifiers_no_const declarator_no_const compound_statement
		| KEY_VOID declarator_no_const declaration_list compound_statement
		| KEY_VOID declarator_no_const compound_statement
		;



initializer
		: PUNC_LBRACE PUNC_RBRACE
		| PUNC_LBRACE initializer_list PUNC_RBRACE
		| PUNC_LBRACE initializer_list PUNC_COMMA PUNC_RBRACE
		| assignment_expression_without_func
		;

initializer_list
		: designation initializer
		| initializer
		| initializer_list PUNC_COMMA designation initializer
		| initializer_list PUNC_COMMA initializer
		;

designation
		: designator_list OP_EQUAL
		;

designator_list
		: designator
		| designator_list designator
		;

designator
		: PUNC_DOT TOKEN_ID
		;


identifier_list
		: TOKEN_ID
		| identifier_list PUNC_COMMA TOKEN_ID
		;


parameter_list
		: parameter_declaration
		| parameter_list PUNC_COMMA parameter_declaration
		;

parameter_declaration
		: declaration_specifiers_no_const declarator_no_const
		| declaration_specifiers_no_const
		; /* ignore abstract delaration here */

compound_statement
		: PUNC_LBRACE block_item_list PUNC_RBRACE
		;

block_item_list
		: zero_or_more_declaration zero_or_more_statement
		;


zero_or_more_statement
		: /* empty */
		| zero_or_more_statement statement
		;

statement
		: compound_statement
		| expression_statement
		| selection_statement
		| iteration_statement
		| jump_statement
		; /* not support labeled statement */

expression_statement
		: PUNC_SEMICOLON
		| expression PUNC_SEMICOLON
		;

expression
		: assignment_expression
		| expression PUNC_COMMA assignment_expression
		;

assignment_expression
		: logical_or_expression
		| unary_expression OP_EQUAL assignment_expression
		;

assignment_expression_without_func
		: logical_or_expression_without_func
		| unary_expression_without_func OP_EQUAL assignment_expression_without_func
		;

logical_or_expression
		: logical_and_expression
		| logical_or_expression OP_OR logical_and_expression
		;

logical_and_expression
		: and_expression
		| logical_and_expression OP_AND and_expression
		;

and_expression
		: equality_expression
		| and_expression OP_ADDR equality_expression
		;

equality_expression
		: relational_expression
		| equality_expression OP_2EQUAL relational_expression
		| equality_expression OP_NE relational_expression
		;

relational_expression
		: additive_expression
		| relational_expression OP_GREATER additive_expression
		| relational_expression OP_GE additive_expression
		| relational_expression OP_LESS additive_expression
		| relational_expression OP_LE additive_expression
		;

additive_expression
		: multiplicative_expression
		| additive_expression OP_PLUS multiplicative_expression
		| additive_expression OP_MINUS multiplicative_expression
		;

multiplicative_expression
		: unary_expression
		| multiplicative_expression OP_MULTIPLE unary_expression
		| multiplicative_expression OP_DIVIDE unary_expression
		| multiplicative_expression OP_PERCENT unary_expression
		;

unary_expression
		: postfix_expression
		| OP_2PLUS unary_expression
		| OP_2MINUS unary_expression
		| unary_operator unary_expression
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
		| postfix_expression PUNC_LBRACKET expression PUNC_RBRACKET
		| postfix_expression PUNC_LPERAN PUNC_RPERAN
		| postfix_expression PUNC_LPERAN argument_expression_list PUNC_RPERAN
		| postfix_expression PUNC_DOT TOKEN_ID
		| postfix_expression OP_2PLUS
		| postfix_expression OP_2MINUS
		; /* may need to support initializer list */

primary_expression
		: TOKEN_ID
		| constant
		| TOKEN_STRING
		| PUNC_LPERAN expression PUNC_RPERAN
		;

constant
		: TOKEN_INTEGER
		| TOKEN_DOUBLE
		| TOKEN_SCI
		;

logical_or_expression_without_func
		: logical_and_expression_without_func
		| logical_or_expression_without_func OP_OR logical_and_expression_without_func
		;

logical_and_expression_without_func
		: and_expression_without_func
		| logical_and_expression_without_func OP_AND and_expression_without_func
		;

and_expression_without_func
		: equality_expression_without_func
		| and_expression_without_func OP_ADDR equality_expression_without_func
		;

equality_expression_without_func
		: relational_expression_without_func
		| equality_expression_without_func OP_2EQUAL relational_expression_without_func
		| equality_expression_without_func OP_NE relational_expression_without_func
		;

relational_expression_without_func
		: additive_expression_without_func
		| relational_expression_without_func OP_GREATER additive_expression_without_func
		| relational_expression_without_func OP_GE additive_expression_without_func
		| relational_expression_without_func OP_LESS additive_expression_without_func
		| relational_expression_without_func OP_LE additive_expression_without_func
		;

additive_expression_without_func
		: multiplicative_expression_without_func
		| additive_expression_without_func OP_PLUS multiplicative_expression_without_func
		| additive_expression_without_func OP_MINUS multiplicative_expression_without_func
		;

multiplicative_expression_without_func
		: unary_expression_without_func
		| multiplicative_expression_without_func OP_MULTIPLE unary_expression_without_func
		| multiplicative_expression_without_func OP_DIVIDE unary_expression_without_func
		| multiplicative_expression_without_func OP_PERCENT unary_expression_without_func
		;

unary_expression_without_func
		: postfix_expression_without_func
		| OP_2PLUS unary_expression_without_func
		| OP_2MINUS unary_expression_without_func
		| unary_operator unary_expression_without_func
		; /* not support sizeof alignof */

postfix_expression_without_func
		: primary_expression_without_func
		| postfix_expression_without_func PUNC_LBRACKET TOKEN_INTEGER PUNC_RBRACKET
		| postfix_expression_without_func PUNC_DOT TOKEN_ID
		| postfix_expression_without_func OP_2PLUS
		| postfix_expression_without_func OP_2MINUS
		; /* may need to support initializer list */

primary_expression_without_func
		: TOKEN_ID
		| constant
		| TOKEN_STRING
		| PUNC_LPERAN expression PUNC_RPERAN
		;


argument_expression_list
		: assignment_expression
		| argument_expression_list PUNC_COMMA assignment_expression
		;

selection_statement
		: KEY_IF PUNC_LPERAN expression PUNC_RPERAN statement KEY_ELSE statement
		| KEY_IF PUNC_LPERAN expression PUNC_RPERAN statement %prec LOWER_THAN_ELSE
		| KEY_SWITCH PUNC_LPERAN identifier_list PUNC_RPERAN PUNC_LBRACE switch_content PUNC_RBRACE
		;

switch_content
		: one_or_more_case
		| one_or_more_case default_statement
		;

one_or_more_case
		: case_statement
		| one_or_more_case case_statement
		;

case_statement
		: KEY_CASE int_or_char_const PUNC_COLON zero_or_more_statement
		;

default_statement
		: KEY_DEFAULT PUNC_COLON zero_or_more_statement
		;

int_or_char_const
		: TOKEN_INTEGER
		| TOKEN_CHAR
		;

iteration_statement
		: KEY_WHILE PUNC_LPERAN expression PUNC_RPERAN statement
		| KEY_DO statement KEY_WHILE PUNC_LPERAN expression PUNC_RPERAN PUNC_SEMICOLON
		| KEY_FOR PUNC_LPERAN expression_statement expression_statement PUNC_RPERAN statement
		| KEY_FOR PUNC_LPERAN expression_statement expression_statement expression PUNC_RPERAN statement
		| KEY_FOR PUNC_LPERAN declaration expression_statement PUNC_RPERAN statement
		| KEY_FOR PUNC_LPERAN declaration expression_statement expression PUNC_RPERAN statement
		;

jump_statement
		: KEY_CONTINUE PUNC_SEMICOLON
		| KEY_BREAK PUNC_SEMICOLON
		| KEY_RETURN PUNC_SEMICOLON
		| KEY_RETURN expression PUNC_SEMICOLON
		;
%%
int main(){
	yyparse();
	printf("No syntax error!\n");
	return 0;
}

