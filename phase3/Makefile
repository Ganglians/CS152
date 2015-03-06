parse: mini_l.lex mini_l.y
	bison -v -d --file-prefix=y mini_l.y
	flex mini_l.lex
	g++ -o mini_l y.tab.c lex.yy.c -lfl
clean:
	rm -f lex.yy.c y.tab.* y.output *.o mini_l
