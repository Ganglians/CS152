/*
	Names:		Juan Chavez
				Kenneth Mayorga

	Class:		CS152 Winter 2015

    Assignment: Phase 3; Code Generation

	File: mini_l.y
*/

%{

	#include <stdlib.h>
	#include <stdio.h>
	#include <string>
	#include <iostream>
	#include <sstream>
	#include <stack>
	#include <vector>
	#include <map>

	using namespace std;

	void yyerror(const char *msg);
	int yylex(void); 

	extern int currLine;
	extern int currPos;

	bool Err = false;
	int t = 0, p = 0, l = 0;
	
	// Intermediate code buffer
	ostringstream buff;
	string s1 = "";
	string s2 = "";

	// Error message string
	string errors = "";

	// Storage stacks
	stack<string> ID;
	stack<string> Var;
	stack<string> Comp;
	stack<string> Index;
	stack<string> Rev;
	stack<int> Label;
	stack<int> Loop;
	stack<int> Pred;

	// Symbol table
	map<string, int> Symbols;

	// Keywords
	static const string Key_words[] = { "_program", "_endprogram", "_array", "_if", "_endif", "_while", "_beginloop", "_continue", "_write", "_or", "_true", "_begin_program", "_integer", "_of", "_then", "_else", "_do", "_endloop", "_read", "_and", "_not", "_false" };

	vector<string> Keywords (Key_words, Key_words + sizeof(Key_words) / sizeof(Key_words[0]));

%}

%union
{

	int number;
	char *string;

}

%start start

%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE ELSEIF

%token WHILE DO BEGINLOOP ENDLOOP BREAK CONTINUE EXIT READ WRITE AND OR NOT TRUE

%token FALSE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA QUESTION

%token L_BRACKET R_BRACKET L_PAREN R_PAREN ASSIGN

%token <number> NUMBER

%token <string> IDENT

%right ASSIGN

%right QUESTION COLON

%left OR

%left AND

%right NOT

%left EQ NEQ LT GT LTE GTE

%left SUB ADD

%left MULT DIV MOD

%right NEG

%left L_BRACKET R_BRACKET L_PAREN R_PAREN

%type <number> number

%type <string> identifier var expression assign statement
%%
start: program_start {
	buff << ": START\n";
} 
;
 
program_start: program   identifier   semicolon   block   end_program {
		/*if(!Err) */
	//	{
			for(int i = 0; i < t; i++)
			{
				cout << "\t. t" << i << endl;
			}

			for(int j = 0; j < p; j ++)
			{
				cout << "\t. p" << j << endl;
			}

			cout << buff.str();
	//	}
} 

| error program identifier semicolon block end_program
 
;

 

block: declaration_list   begin_program   statement_list
 
;

 

declaration_list: declaration_list   declaration   semicolon 

| declaration   semicolon
 
;

 

declaration: identifier_list   colon   optional_array   integer {
	while(!ID.empty()) 
	{
		buff << "\t. " << ID.top() << endl;
		ID.pop();
	}
} 

;

 

identifier_list: identifier_list comma identifier   

| identifier {
	// Error check
	string id = "_" + string($1);
	/*map<string, int>::iterator i = Symbols.find(id);

	if (i != Symbols.end())
	{
		errors = "Error: " + id + " has been previously defined";
		yyerror(errors.c_str());
	}*/

	Symbols[id] = -1;
	ID.push(id);
} 

;

 

optional_array: array   l_bracket   number   r_bracket   of {
	int num = $3;

    //Error check
	if(num <= 0) 
	{	
		errors = "Error: Declaring array of invalid size.";
		yyerror(errors.c_str());	
	}

	while(!ID.empty())
	{
		buff << "\t.[] " << ID.top() << ", " << num << endl;

		string id = ID.top();

		Symbols[id] = num;
		ID.pop(); 
	} 
} 

| /* epsilon */ 

;

statement: var   assign   expression {
	// Segfault
	/*s2 = Var.top();
	if(Index.top() != "-1")
	{
		ostringstream convert;
		convert << t;
		buff << "\t=[] t" << t << ", " << s2 << ", " << Index.top() << endl;

		s2 = "t" + convert.str();
		t++;
	}

	Var.pop();
	Index.pop();
	s1 = Var.top();

	if(Index.top() != "-1")
	{
		buff << "\t[]= " << s1 << ", " << Index.top() << ", " << s2 << endl;
	}

	else
	{
		buff << "\t= " << s1 << ", " << s2 << endl;
	}

	Var.pop();
	Index.pop();*/
    
}

| if   bool_exp   then   statement_list   optional_elseif   optional_else   end_if {} 

| while   bool_exp   begin_loop   statement_list   end_loop {} 

| do   begin_loop   statement_list   end_loop   while bool_exp {} 

| read   var_list {} 

| write   var_list {} 

| break {} 

| continue {} 

| exit {} 

;

 

optional_elseif: optional_elseif   elseif   bool_exp   statement_list 

| elseif   bool_exp   statement_list

| /* epsilon */ 

;

 

optional_else: else   statement_list 

| /* epsilon */ 

;

 

var_list: var_list   comma   var 

| var {} 

;

 

statement_list: statement_list   statement   semicolon 

| statement   semicolon {} 

;

 

bool_exp: relation_and_exp   relation_and_exp_list 

;

 

relation_and_exp_list: relation_and_exp_list   or   relation_and_exp 

| or relation_and_exp 

| /* epsilon */ 

;

 

relation_and_exp: relation_exp   relation_exp_list 

;

 

relation_exp_list:  relation_exp_list   and   relation_exp 

| and   relation_exp 

| /* epsilon */ 

;

 

relation_exp: not   expression   comp   expression 

| not true 

| not   false 

| not   l_paren   bool_exp   r_paren 

| expression   comp   expression {} 

| true 

| false 

| l_paren   bool_exp   r_paren 

;

 

comp: equal_to {

	Comp.push("==");

} 

| not_equal_to {

	Comp.push("!=");

}

| less_than {

	Comp.push("<");

}

| greater_than {

	Comp.push(">");

}

| less_than_or_equal_to {

	Comp.push("<=");

}

| greater_than_or_equal_to {

	Comp.push(">=");

}

;

 

expression: multiplicative_exp   multiplicative_exp_list {} 

;

 

multiplicative_exp_list: multiplicative_exp_list   add   multiplicative_exp 

| multiplicative_exp_list   sub multiplicative_exp 

| add   multiplicative_exp 

| sub   multiplicative_exp 

|  /* epsilon */ 

;

 

multiplicative_exp: term   term_list 

;

 

term_list: term_list   multiply   term 

| term_list   divide   term 

| term_list   mod   term 

| multiply  term 

| divide   term 

| mod   term 

| /* epsilon */ 

;

 

term: sub   var %prec NEG 

| sub   number var %prec NEG 

| sub   l_paren   expression r_paren %prec NEG 

| var {} 

| number {} 

| l_paren   expression   r_paren 

;

 

var: identifier 

| identifier   l_bracket   expression   r_bracket 

;

 

program: PROGRAM 

;

 

identifier: IDENT {

	// Search symbol table for identifier
	string id = "_" + string($1);
	map <string, int>::iterator i = Symbols.find(id);

	// Error check
	/*if (i != Symbols.end())
	{
		errors = "Error: " + id + " was previously defined";
		yyerror(errors.c_str());
	}*/

	bool keybool = false;
	int size = Keywords.size();

	for(int j = 0; j < size; j++)
	{
		(id == Keywords[j]) ? keybool = true : keybool;	
	}
	
	if(keybool == true)
	{
		errors = "Error: " + id + " has been defined as a keyword and cannot be used";
		yyerror(errors.c_str());
	}

	Var.push(id);

}

;

 

semicolon: SEMICOLON  

;

 

end_program: END_PROGRAM 

;

 

begin_program: BEGIN_PROGRAM 

;

 

comma: COMMA 

;

 

colon: COLON 

;

array: ARRAY 

;

 

l_bracket: L_BRACKET 

;

 

number: NUMBER 

;

 

r_bracket: R_BRACKET 

;



l_paren: L_PAREN 

;



r_paren: R_PAREN 

;

of: OF 

;

integer: INTEGER 

;

 

assign: ASSIGN {} 

;

 

question: QUESTION 

;

 

if: IF 

;

 

then: THEN 
{
	// Segfault

	/*int s2 = Pred.top();
	Pred.pop();

	buff << "\t?:= L" << l << ", p" << s2 << endl;
	Label.push(l);
	l++;*/ 	
}

;

 

end_if: ENDIF {

	/*buff << ": L" << Label.top() << endl;
	Label.pop();*/

} 

;

 

elseif: ELSEIF 

;

 

else: ELSE {

	/*buff << "\t:= L" << l << endl;
	buff << ": L" << Label.top() << endl;
	Label.pop();
	Label.push(l);

	l++;*/

}

;

 

while: WHILE {

	buff << ": L" << l << endl;

	Loop.push(l);
	Label.push(l);
	++l;
	
} 

;

 

begin_loop: BEGINLOOP {
	//int t = Pred.top();
} 

;

 

end_loop: ENDLOOP 

;

 

do: DO 

;

 

read: READ 

;

 

write: WRITE 

;

 

 

break: BREAK 

;

 

continue: CONTINUE {
	if(!Loop.empty())
	{
		buff << "\t:= L" << Loop.top() << endl;
	}
} 

;

exit: EXIT 

;

 

or: OR 

;

 

and: AND 

;

 

not: NOT 

;

 

true: TRUE 

;

 

false: FALSE 

;

 

equal_to: EQ 

;

 

not_equal_to: NEQ 

;

 

less_than: LT 

;

 

greater_than: GT 

;

 

less_than_or_equal_to: LTE 

;

 

greater_than_or_equal_to: GTE 

;

add: ADD 

;

 

sub: SUB 

;

 

multiply: MULT 

;

 

divide: DIV 

;

 

mod: MOD 

;

 

%%

int main(int argc, char **argv) {
   if (argc > 1) 
   {

      if (freopen(argv[1], "r", stdin) == NULL)
      {

		 printf("syntax: %s filename\n", argv[0]);

      }//end if

   }//end if

   yyparse(); // Calls yylex() for tokens.

   return 0;

}

void yyerror(const char *msg) {

   printf("** Line %d %s\n", currLine, msg);
}
