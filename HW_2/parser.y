%{
#include <stdio.h>
void yyerror(const char* msg) {}
%}

%token TYPE_INT TYPE_DOUBLE TYPE_BOOL TYPE_CHAR
%token OP_PLUS OP_MINUS OP_MULTIPLE OP_DIVIDE OP_PERCENT OP_2PLUS OP_2MINUS OP_LESS OP_LE OP_GREATER OP_GE OP_2EQUAL OP_NE OP_EQUAL OP_AND OP_OR OP_NOT OP_POINTER OP_ADDR
%token PUNC_COLON PUNC_SEMICOLON PUNC_COMMA PUNC_DOT PUNC_LBRACKET PUNC_RBRACKET PUNC_LPERAN PUNC_RPERAN PUNC_LBRACE PUNC_RBRACE
%token KEY_VOID KEY_NULL KEY_FOR KEY_WHILE KEY_DO KEY_IF KEY_ELSE KEY_SWITCH KEY_RETURN KEY_BREAK KEY_CONTINUE KEY_CONST KEY_TRUE KEY_FALSE KEY_STRUCT KEY_CASE KEY_DEFAULT
%token STDIO_PRINTF STDIO_SCANF STDIO_GETC STDIO_GETS STDIO_GETCHAR STDIO_PUTS STDIO_PUTCHAR STDIO_CLEARERR STDIO_FOPEN STDIO_FCLOSE STDIO_GETW STDIO_PUTW STDIO_PUTC STDIO_FPUTC STDIO_FGETS STDIO_FPUTS STDIO_FEOF STDIO_FGETC STDIO_FPRINTF STDIO_FSCANF STDIO_FSEEK STDIO_FTELL STDIO_REWIND STDIO_SPRINTF STDIO_SSCANF STDIO_REMOVE STDIO_FFLUSH
%token TOKEN_ID TOKEN_STRING TOKEN_CHAR TOKEN_INTEGER TOKEN_DOUBLE TOKEN_SCI
%token OTHER_SPACE OTHER_COMMENT OTHER_MULTICOMMENT OTHRE_SOURCEON OTHER_SOURCEOFF OTHER_TOKENON OTHER_TOKENOFF
