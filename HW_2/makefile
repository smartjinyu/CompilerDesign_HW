parser: lex.yy.c y.tab.c
	gcc -o parser lex.yy.c y.tab.c
lex.yy.c: scanner.l
	flex scanner.l
y.tab.c: parser.y
	byacc -d parser.y