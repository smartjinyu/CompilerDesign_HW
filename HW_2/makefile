parser: lex.yy.c y.tab.c
	gcc -o parser lex.yy.c y.tab.c
y.tab.c: parser.y
	byacc -d parser.y
lex.yy.c: scanner.l
	flex scanner.l
