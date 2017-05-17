%{
#include <string.h>
//#include "y.tab.h"

int isSourceOn = 1;
int isTokenOn = 1;
void print_token(int token);
void print_error();
void newLine();

typedef enum{
	TYPE_INT=10,TYPE_DOUBLE,TYPE_BOOL,TYPE_CHAR
} TYPES;

typedef enum{
	OP_PLUS=30,OP_MINUS,OP_MULTIPLE,OP_DIVIDE,OP_PERCENT,OP_2PLUS,
	OP_2MINUS,OP_LESS,OP_LE,OP_GREATER,OP_GE,OP_2EQUAL,OP_NE,
	OP_EQUAL,OP_AND,OP_OR,OP_NOT,OP_POINTER,OP_ADDR
} OPERATORS;

typedef enum{
	PUNC_COLON=60,PUNC_SEMICOLON,PUNC_COMMA,PUNC_DOT,
	PUNC_LBRACKET,PUNC_RBRACKET,PUNC_LPERAN,PUNC_RPERAN,
	PUNC_LBRACE,PUNC_RBRACE
} PUNCTUATIONS;

typedef enum{
	KEY_VOID=80,KEY_NULL,KEY_FOR,KEY_WHILE,KEY_DO,KEY_IF,
	KEY_ELSE,KEY_SWITCH,KEY_RETURN,KEY_BREAK,KEY_CONTINUE,
	KEY_CONST,KEY_TRUE,KEY_FALSE,KEY_STRUCT,KEY_CASE,
	KEY_DEFAULT
} KEYWORDS;

typedef enum{
	STDIO_PRINTF=120,STDIO_SCANF,STDIO_GETC,STDIO_GETS,
	STDIO_GETCHAR,STDIO_PUTS,STDIO_PUTCHAR,STDIO_CLEARERR,
	STDIO_FOPEN,STDIO_FCLOSE,STDIO_GETW,STDIO_PUTW,
	STDIO_PUTC,STDIO_FPUTC,STDIO_FGETS,STDIO_FPUTS,STDIO_FEOF,
	STDIO_FGETC,STDIO_FPRINTF,STDIO_FSCANF,STDIO_FSEEK,STDIO_FTELL,
	STDIO_REWIND,STDIO_SPRINTF,STDIO_SSCANF,STDIO_REMOVE,STDIO_FFLUSH
} STDIOFUNC;

typedef enum{
	TOKEN_ID = 300,TOKEN_STRING, TOKEN_CHAR, TOKEN_INTEGER, 
	TOKEN_DOUBLE,TOKEN_SCI
} TokenType;

typedef enum{
	OTHER_SPACE=500,OTHER_COMMENT,OTHER_MULTICOMMENT,OTHRE_SOURCEON,
	OTHER_SOURCEOFF,OTHER_TOKENON,OTHER_TOKENOFF
} Others;
%}


/* Definitions */
%x VARDEF
%s COMMENT
UNTERM_STRING	(\042[^\042\n]*)
STRING 			(\042[^\042\n]*\042)
CHARACTER		(\047[^\047\n]\047)
MULTI_CHAR		(\047[^\047\n]+\047)
UNTERM_CHAR		(\047[^\047\n]*)
INTEGER_ZERO	(0)
INTEGER			([1-9]+[0-9]*)
INTEGER_INVALID	(0[0-9]+)
DOUBLE 			([1-9]+[0-9]*"."[0-9]+)
DOUBLE_ZERO		(0.[0-9]+)
DOUBLE_INVALID	([0-9]+".")
SCI_NOTATION	([0-9]+["."[0-9]*]?[eE][+-]?[0-9]+)
SCI_INVALID		([0-9]+["."[0-9]*]?[eE][+-]?[0-9]+"."[0-9]*)
KEY_WORDS		("double"|"int"|"char"|"bool"|"void"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"|"printf"|"scanf"|"getc"|"gets"|"getchar"|"puts"|"putchar"|"clearerr"|"fopen"|"fclose"|"getw"|"putw"|"fgetc"|"putc"|"fputc"|"fgets"|"fputs"|"feof"|"fseek"|"ftell"|"rewind"|"sprintf"|"sscanf"|"remove"|"fflush")

SINGLE_COMMENT	("//"[^\n]*)

IDENTIFIER		([_a-zA-Z][_a-zA-Z0-9]*)

SOURCEOFF		("#pragma source off")
SOURCEON		("#pragma source on")
TOKENOFF		("#pragma token off")
TOKENON			("#pragma token on")


%%
{SINGLE_COMMENT}	{ strcat(cur_line_content,yytext); return OTHER_COMMENT; }
"/*"				{ BEGIN(COMMENT); strcat(cur_line_content,yytext); return OTHER_MULTICOMMENT; }
<COMMENT>[^*\n]*    { strcat(cur_line_content,yytext); return OTHER_MULTICOMMENT; }
<COMMENT>"*"+[^*/\n]* { strcat(cur_line_content,yytext); return OTHER_MULTICOMMENT; }
<COMMENT>\n 		{ newLine(); }
<COMMENT>"*"+"/"	{ BEGIN(INITIAL); strcat(cur_line_content,yytext); return OTHER_MULTICOMMENT;}

{SOURCEON}			{ isSourceOn = 1; strcat(cur_line_content,yytext); return OTHRE_SOURCEON; }
{SOURCEOFF}			{ isSourceOn = 0; strcat(cur_line_content,yytext); return OTHER_SOURCEOFF; }
{TOKENON}			{ isTokenOn = 1; strcat(cur_line_content,yytext); return OTHER_TOKENON; }
{TOKENOFF}			{ isTokenOn = 0; strcat(cur_line_content,yytext); return OTHER_TOKENOFF; }

{STRING}			{ strcat(cur_line_content,yytext); print_token(4); return TOKEN_STRING; }
{UNTERM_STRING}		{ print_error();return 0; }
{CHARACTER}			{ strcat(cur_line_content,yytext); print_token(5); return TOKEN_CHAR; }
{MULTI_CHAR}		{ print_error();return 0; }
{UNTERM_CHAR}		{ print_error();return 0; }
{INTEGER}			{ strcat(cur_line_content,yytext); print_token(6); return TOKEN_INTEGER;}
{INTEGER_ZERO}		{ strcat(cur_line_content,yytext); print_token(6); return TOKEN_INTEGER;}
{INTEGER_INVALID}	{ print_error();return 0; }

{DOUBLE}			{ strcat(cur_line_content,yytext); print_token(7); return TOKEN_DOUBLE; }
{DOUBLE_ZERO}		{ strcat(cur_line_content,yytext); print_token(7); return TOKEN_DOUBLE; }
{DOUBLE_INVALID}	{ print_error();return 0; }
{SCI_NOTATION}		{ strcat(cur_line_content,yytext); print_token(8); return TOKEN_SCI;}
{SCI_INVALID}		{ print_error();return 0; }

[\n]				{ newLine();}
[ \t\r]+          	{ strcat(cur_line_content,yytext); return OTHER_SPACE;/* ignore all spaces */ }

"int"				{ BEGIN(VARDEF); strcat(cur_line_content,yytext); print_token(0); return TYPE_INT; }
"double"			{ BEGIN(VARDEF); strcat(cur_line_content,yytext); print_token(0); return TYPE_DOUBLE; }
"bool"				{ BEGIN(VARDEF); strcat(cur_line_content,yytext); print_token(0); return TYPE_BOOL; }
"char"				{ BEGIN(VARDEF); strcat(cur_line_content,yytext); print_token(0); return TYPE_CHAR; }
<VARDEF>"="			{ BEGIN(INITIAL); strcat(cur_line_content,yytext); print_token(2); return OP_EQUAL; }
<VARDEF>";"			{ BEGIN(INITIAL); strcat(cur_line_content,yytext); print_token(3); return PUNC_SEMICOLON; }
<VARDEF>[ \t\r]+   	{ strcat(cur_line_content,yytext); return OTHER_SPACE;}
<VARDEF>"*"			{ strcat(cur_line_content,yytext); print_token(2); return OP_MULTIPLE;}
<VARDEF>{KEY_WORDS}	{ print_error();return 0; }
<VARDEF>{IDENTIFIER} { BEGIN(INITIAL);strcat(cur_line_content,yytext); print_token(1); return TOKEN_ID; }
<VARDEF>.			{ print_error();return 0; }





"void"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_VOID; }
"null"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_NULL; }
"for"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_FOR; }
"while"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_WHILE; }
"do"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_DO; }
"if"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_IF; }
"else"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_ELSE; }
"switch"			{ strcat(cur_line_content,yytext); print_token(0); return KEY_SWITCH; }
"return"			{ strcat(cur_line_content,yytext); print_token(0); return KEY_RETURN; }
"break"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_BREAK; }
"continue"			{ strcat(cur_line_content,yytext); print_token(0); return KEY_CONTINUE; }
"const"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_CONST; }
"true"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_TRUE; }
"false"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_FALSE; }
"struct"			{ strcat(cur_line_content,yytext); print_token(0); return KEY_STRUCT; }
"case"				{ strcat(cur_line_content,yytext); print_token(0); return KEY_CASE; }
"default"			{ strcat(cur_line_content,yytext); print_token(0); return KEY_DEFAULT; }

"printf"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_PRINTF; }
"scanf"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_SCANF; }
"getc"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_GETC; }
"gets"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_GETS; }
"getchar"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_GETCHAR; }
"puts"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_PUTS; }
"putchar"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_PUTCHAR; }
"clearerr"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_CLEARERR; }
"fopen"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FOPEN; }
"fclose"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FCLOSE; }
"getw"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_GETW; }
"putw"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_PUTW; }
"fgetc"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FGETC; }
"putc"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_PUTC; }
"fputc"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FPUTC; }
"fgets"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FGETS; }
"fputs"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FPUTS; }
"feof"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FEOF; }
"fseek"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FSEEK; }
"ftell"				{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FTELL; }
"rewind"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_REWIND; }
"sprintf"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_SPRINTF; }
"sscanf"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_SSCANF; }
"remove"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_REMOVE; }
"fflush"			{ strcat(cur_line_content,yytext); print_token(0); return STDIO_FFLUSH; }

"+"					{ strcat(cur_line_content,yytext); print_token(2); return OP_PLUS; }
"-"					{ strcat(cur_line_content,yytext); print_token(2); return OP_MINUS; }
"*"					{ strcat(cur_line_content,yytext); print_token(2); return OP_MULTIPLE; }
"/"					{ strcat(cur_line_content,yytext); print_token(2); return OP_DIVIDE; }
"%"					{ strcat(cur_line_content,yytext); print_token(2); return OP_PERCENT; }
"++"				{ strcat(cur_line_content,yytext); print_token(2); return OP_2PLUS; }
"--"				{ strcat(cur_line_content,yytext); print_token(2); return OP_2MINUS; }
"<"					{ strcat(cur_line_content,yytext); print_token(2); return OP_LESS; }
"<="				{ strcat(cur_line_content,yytext); print_token(2); return OP_LE; }
">"					{ strcat(cur_line_content,yytext); print_token(2); return OP_GREATER; }
">="				{ strcat(cur_line_content,yytext); print_token(2); return OP_GE; }
"=="				{ strcat(cur_line_content,yytext); print_token(2); return OP_2EQUAL; }
"!="				{ strcat(cur_line_content,yytext); print_token(2); return OP_NE; }
"="					{ strcat(cur_line_content,yytext); print_token(2); return OP_EQUAL; }
"&&"				{ strcat(cur_line_content,yytext); print_token(2); return OP_AND; }
"||"				{ strcat(cur_line_content,yytext); print_token(2); return OP_OR; }
"!"					{ strcat(cur_line_content,yytext); print_token(2); return OP_NOT; }
"&"					{ strcat(cur_line_content,yytext); print_token(2); return OP_ADDR; }

":"					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_COLON; }
";"					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_SEMICOLON; }
","					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_COMMA; }
"."					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_DOT; }
"["					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_LBRACKET; }
"]"					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_RBRACKET; }
"("					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_LPERAN; }
")"					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_RPERAN; }
"{"					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_LBRACE; }
"}"					{ strcat(cur_line_content,yytext); print_token(3); return PUNC_RBRACE; }

{IDENTIFIER}		{ strcat(cur_line_content,yytext); print_token(1); return TOKEN_ID; }
.					{ print_error(); return 0; }

%%

int main(){
	int token;
	while(token=yylex()){
		
	}
	return 0;
}

int yywrap(){
	return 1;
}
/*
* tokenType
* 0:key, 1:identifier, 2:operation, 3:punctuation, 4:string constant, 5:char constant, 6:integer constant, 7:double constant, 8:sci constant
*/
void print_token(int tokenType){
	if(isTokenOn == 1){
		/*
		if(token>=10 && token<=13){
			// type
			fprintf(stdout,"#key:%s\n",yytext);
			return;
		}
		if(token>=80 && token<=96){
			// other keywords
			fprintf(stdout,"#key:%s\n",yytext);
			return;
		}

		if(token>=120 && token<=147){
			// sdtiofuncs
			fprintf(stdout,"#key:%s\n",yytext);
			return;
		}*/
		if(tokenType == 0){
			// key
			fprintf(stdout,"#key:%s\n",yytext);
			return;
		}

		/*
		if(token == TOKEN_ID){
			// identifier
			fprintf(stdout,"#id:%s\n",yytext);
			return;
		}
		*/
		if(tokenType == 1){
			// identifier
			fprintf(stdout,"#id:%s\n",yytext);
			return;
		}

		if(tokenType == 2){
			// operation
			fprintf(stdout,"#op:%s\n",yytext);
			return;
		}

		if(tokenType == 3){
			// punctuation
			fprintf(stdout,"#punc:%s\n",yytext);
			return;
		}

		/*

		if(token>=30 && token<=49){
			// operation
			fprintf(stdout,"#op:%s\n",yytext);
			return;
		}
		if(token>=60 && token<=69){
			// punctuation
			fprintf(stdout,"#punc:%s\n",yytext);
			return;
		}
		*/

		if(tokenType == 4){
			// string constant
			char text[256];
			int i;
			for(i=1;yytext[i]!='\042';i++){
				text[i-1]=yytext[i];
			}
			text[i-1]='\0';
			fprintf(stdout,"#string:%s\n",text);
			return;

		}

		/*
		if(token == TOKEN_STRING){
			// string
			char text[256];
			int i;
			for(i=1;yytext[i]!='\042';i++){
				text[i-1]=yytext[i];
			}
			text[i-1]='\0';
			fprintf(stdout,"#string:%s\n",text);
			return;
		}
		*/

		if(tokenType == 5){
			// char constant
			fprintf(stdout,"#char:%s\n",yytext);
			return;
		}
		/*
		if(token == TOKEN_CHAR){
			// char
			fprintf(stdout,"#char:%s\n",yytext);
			return;
		}
		*/

		if(tokenType == 6){
			// integer constant
			fprintf(stdout,"#integer:%s\n",yytext);
			return;
		}
		/*
		if(token == TOKEN_INTEGER){
			// integer
			fprintf(stdout,"#integer:%s\n",yytext);
			return;
		}
		*/
		if(tokenType == 7){
			// double constant
			fprintf(stdout,"#double:%s\n",yytext);
			return;
		}
		/*
		if(token == TOKEN_DOUBLE){
			// double
			fprintf(stdout,"#double:%s\n",yytext);
			return;
		}
		*/

		if(tokenType == 8){
			// sci constant
			fprintf(stdout,"#sci:%s\n",yytext);
			return;
		}
		/*
		if(token == TOKEN_SCI){
			// sci
			fprintf(stdout,"#sci:%s\n",yytext);
			return;
		}*/

	}

}

void print_error(){
	fprintf(stderr, "Error at line %d: %s\n",cur_line_num,yytext);
	exit(1);
}

void newLine(){
	if(isSourceOn == 1){
		fprintf(stdout,"%d:%s\n",cur_line_num,cur_line_content);
	}
	memset(cur_line_content,0,sizeof(cur_line_content));
	cur_line_num++;
}