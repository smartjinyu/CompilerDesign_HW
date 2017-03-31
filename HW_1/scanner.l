%{
#include <string.h>
int cur_line_num = 1;
char cur_line_content[256];
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
{SINGLE_COMMENT}	{ return OTHER_COMMENT; }
"/*"				{ BEGIN(COMMENT);return OTHER_MULTICOMMENT; }
<COMMENT>[^*\n]*    { return OTHER_MULTICOMMENT; }
<COMMENT>"*"+[^*/\n]* { return OTHER_MULTICOMMENT; }
<COMMENT>\n 		{ newLine(); }
<COMMENT>"*"+"/"	{ BEGIN(INITIAL);return OTHER_MULTICOMMENT;}

{SOURCEON}			{ isSourceOn = 1;return OTHRE_SOURCEON; }
{SOURCEOFF}			{ isSourceOn = 0;return OTHER_SOURCEOFF; }
{TOKENON}			{ isTokenOn = 1;return OTHER_TOKENON; }
{TOKENOFF}			{ isTokenOn = 0;return OTHER_TOKENOFF; }

{STRING}			{ return TOKEN_STRING; }
{UNTERM_STRING}		{ print_error();return 0; }
{CHARACTER}			{ return TOKEN_CHAR; }
{MULTI_CHAR}		{ print_error();return 0; }
{UNTERM_CHAR}		{ print_error();return 0; }
{INTEGER}			{ return TOKEN_INTEGER;}
{INTEGER_ZERO}		{ return TOKEN_INTEGER;}
{INTEGER_INVALID}	{ print_error();return 0; }

{DOUBLE}			{ return TOKEN_DOUBLE; }
{DOUBLE_ZERO}		{ return TOKEN_DOUBLE; }
{DOUBLE_INVALID}	{ print_error();return 0; }
{SCI_NOTATION}		{ return TOKEN_SCI;}
{SCI_INVALID}		{ print_error();return 0; }

[\n]				{ newLine();}
[ \t\r]+          	{ return OTHER_SPACE;/* ignore all spaces */ }

"int"				{ BEGIN(VARDEF);return TYPE_INT; }
"double"			{ BEGIN(VARDEF);return TYPE_DOUBLE; }
"bool"				{ BEGIN(VARDEF);return TYPE_BOOL; }
"char"				{ BEGIN(VARDEF);return TYPE_CHAR; }
<VARDEF>"="			{ BEGIN(INITIAL);return OP_EQUAL; }
<VARDEF>";"			{ BEGIN(INITIAL);return PUNC_SEMICOLON; }
<VARDEF>[ \t\r]+   	{ return OTHER_SPACE;}
<VARDEF>"*"			{ return OP_MULTIPLE;}
<VARDEF>{KEY_WORDS}	{ print_error();return 0; }
<VARDEF>{IDENTIFIER} { BEGIN(INITIAL);return TOKEN_ID; }
<VARDEF>.			{ print_error();return 0; }





"void"				{ return KEY_VOID; }
"null"				{ return KEY_NULL; }
"for"				{ return KEY_FOR; }
"while"				{ return KEY_WHILE; }
"do"				{ return KEY_DO; }
"if"				{ return KEY_IF; }
"else"				{ return KEY_ELSE; }
"switch"			{ return KEY_SWITCH; }
"return"			{ return KEY_RETURN; }
"break"				{ return KEY_BREAK; }
"continue"			{ return KEY_CONTINUE; }
"const"				{ return KEY_CONST; }
"true"				{ return KEY_TRUE; }
"false"				{ return KEY_FALSE; }
"struct"			{ return KEY_STRUCT; }
"case"				{ return KEY_CASE; }
"default"			{ return KEY_DEFAULT; }

"printf"			{ return STDIO_PRINTF; }
"scanf"				{ return STDIO_SCANF; }
"getc"				{ return STDIO_GETC; }
"gets"				{ return STDIO_GETS; }
"getchar"			{ return STDIO_GETCHAR; }
"puts"				{ return STDIO_PUTS; }
"putchar"			{ return STDIO_PUTCHAR; }
"clearerr"			{ return STDIO_CLEARERR; }
"fopen"				{ return STDIO_FOPEN; }
"fclose"			{ return STDIO_FCLOSE; }
"getw"				{ return STDIO_GETW; }
"putw"				{ return STDIO_PUTW; }
"fgetc"				{ return STDIO_FGETC; }
"putc"				{ return STDIO_PUTC; }
"fputc"				{ return STDIO_FPUTC; }
"fgets"				{ return STDIO_FGETS; }
"fputs"				{ return STDIO_FPUTS; }
"feof"				{ return STDIO_FEOF; }
"fseek"				{ return STDIO_FSEEK; }
"ftell"				{ return STDIO_FTELL; }
"rewind"			{ return STDIO_REWIND; }
"sprintf"			{ return STDIO_SPRINTF; }
"sscanf"			{ return STDIO_SSCANF; }
"remove"			{ return STDIO_REMOVE; }
"fflush"			{ return STDIO_FFLUSH; }

"+"					{ return OP_PLUS; }
"-"					{ return OP_MINUS; }
"*"					{ return OP_MULTIPLE;  /*TODO*/}
"/"					{ return OP_DIVIDE; }
"%"					{ return OP_PERCENT; }
"++"				{ return OP_2PLUS; }
"--"				{ return OP_2MINUS; }
"<"					{ return OP_LESS; }
"<="				{ return OP_LE; }
">"					{ return OP_GREATER; }
">="				{ return OP_GE; }
"=="				{ return OP_2EQUAL; }
"!="				{ return OP_NE; }
"="					{ return OP_EQUAL; }
"&&"				{ return OP_AND; }
"||"				{ return OP_OR; }
"!"					{ return OP_NOT; }
"&"					{ return OP_ADDR; }

":"					{ return PUNC_COLON; }
";"					{ return PUNC_SEMICOLON; }
","					{ return PUNC_COMMA; }
"."					{ return PUNC_DOT; }
"["					{ return PUNC_LBRACKET; }
"]"					{ return PUNC_RBRACKET; }
"("					{ return PUNC_LPERAN; }
")"					{ return PUNC_RPERAN; }
"{"					{ return PUNC_LBRACE; }
"}"					{ return PUNC_RBRACE; }

{IDENTIFIER}		{ return TOKEN_ID; }
.					{ print_error(); return 0; }

%%

int main(){
	int token;
	while(token=yylex()){
		strcat(cur_line_content,yytext);
		if(isTokenOn==1){
			print_token(token);
		}
	}
	return 0;
}

int yywrap(){
	return 1;
}

void print_token(int token){
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
	}


	if(token == TOKEN_ID){
		// identifier
		fprintf(stdout,"#id:%s\n",yytext);
		return;
	}

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
	if(token == TOKEN_CHAR){
		// char
		fprintf(stdout,"#char:%s\n",yytext);
		return;
	}
	if(token == TOKEN_INTEGER){
		// integer
		fprintf(stdout,"#integer:%s\n",yytext);
		return;
	}
	if(token == TOKEN_DOUBLE){
		// double
		fprintf(stdout,"#double:%s\n",yytext);
		return;
	}
	if(token == TOKEN_SCI){
		// sci
		fprintf(stdout,"#sci:%s\n",yytext);
		return;
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