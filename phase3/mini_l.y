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

start: program_start {}
 
;
 
program_start: program   identifier   semicolon   block   end_program {//***
		if(!Err) 
		{
			for(int i = 0; i < t; i++)
			{
				cout << "\t. t" << i << endl;
			}

			for(int j = 0; j < p; j ++)
			{
				cout << "\t. p" << j << endl;
			}

			cout << buff.str();
			cout << ": EndLabel" << endl;;
		}
} 

;

 

block: declaration_list   begin_program   statement_list
 
;

 

declaration_list: declaration_list   declaration   semicolon 

| declaration   semicolon
 
;

 

declaration: identifier_list   colon   optional_array   integer {//***
	while(!ID.empty()) 
	{
		buff << "\t. " << ID.top() << endl;
		ID.pop();
	}
} 

;

 

identifier_list: identifier_list comma identifier   

| identifier {//***
	// Error check %%%%%%%%%%%%%%%%%
	string id = "_" + string($1);
	map<string, int>::iterator i = Symbols.find(id);

	if (i != Symbols.end())
	{
		errors = "Error: " + id + " has been previously defined";
		yyerror(errors.c_str());
	}

	Symbols[id] = -1;
	ID.push(id);
} 

;

 

optional_array: array   l_bracket   number   r_bracket   of {//****
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
} //****************************

| /* epsilon */ 

;

statement: var   assign   expression {//**************************
	s2 = Var.top();

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
	Index.pop();
    
}

| if   bool_exp   then   statement_list   optional_elseif   optional_else   end_if {} 

| while   bool_exp   begin_loop   statement_list   end_loop {} 

| do   begin_loop   statement_list   dend_loop   while bool_exp {
//***
	int s1 = Pred.top();
	Pred.pop();
	int l1 = Label.top();

	buff << "\t== p" << p << ", p" << s1 << ", 0" << endl;
	buff << "\t?:= L" << l1 << ", p" << p << endl;
	++p;
	Label.pop();
} 

| read   var_list {//###### 

	cout << "read var_list" << endl;//*
	!Var.empty();
	Index.top() == "-1";
	Var.top();
	/*while(!Var.empty())
	{
		if(Index.top() == "-1")
		{
			stringstream convert;
			convert << "\t.< " << Var.top() << endl;
			Rev.push(convert.str());
			cout << convert.str() << endl;//*
		}			

		else
		{
			//cout << "in the else" << endl;//*
			stringstream convert2;
			convert2 << "\t.[]< " << Var.top() << ", " << Index.top() << endl;
			Rev.push(convert2.str()); 
		}
		
		Var.pop();
		Index.pop();

	}

		while(!Rev.empty())
		{

			buff << Rev.top();
			Rev.pop();
		
		}*/

} 

| write   var_list {//##############

	/*while(!Var.empty())
	{
	
		if(Index.top() == "-1")
		{
			stringstream convert;
			convert << "\t.> " << Var.top() << endl;
			Rev.push(convert.str());
		}			

		else
		{
			stringstream convert2;
			convert2 << "\t.[]> " << Var.top() << ", " << Index.top() << endl;
			Rev.push(convert2.str()); 
		}
		
		Var.pop();
		Index.pop();

	}

		while(!Rev.empty())
		{

			buff << Rev.top();
			Rev.pop();
		
		} */
			

} 

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

 

bool_exp: relation_and_exp   relation_and_exp_list //***
{

	int s2 = Pred.top();	
	Pred.pop();

	buff << "\t== p" << p << ", p" << s2 << ", 0" << endl;
	Pred.push(p);
	++p;

}

;

 

relation_and_exp_list: relation_and_exp_list   or   relation_and_exp
{//***

	int s2 = Pred.top();
	Pred.pop();
	int s1 = Pred.top();
	Pred.pop();

	buff << "\t|| p" << p << ", p" << s1 << ", p" << s2 << endl;
	Pred.push(p);
	p++;

} 

| or relation_and_exp 

| /* epsilon */ 

;

 

relation_and_exp: relation_exp   relation_exp_list 

;

 

relation_exp_list:  relation_exp_list   and   relation_exp //******
{

	int s2 = Pred.top();
	Pred.pop();
	int s1 = Pred.top();
	Pred.pop();

	buff << "\t&& p" << p << ", p" << s1 << ", p" << s2 << endl;
	Pred.push(p);
	++p;

} //***************************************

| and   relation_exp 

| /* epsilon */ 

;

 

relation_exp: not   expression   comp   expression {

	s2 = Var.top();
	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << "\t=[] t" << t << ", " << s2 << ", " << Index.top() << endl;
		s2 = "t" + convert.str();
		++t;
	}
	
	Index.pop();
	Var.pop();

	s1 = Var.top();

	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << "\t=[] t" << t << ", " << s1 << ", " << Index.top() << endl;
		
		s1 = "t" + convert.str();
		t++;
	}

	Var.pop();
	Index.pop();
	string ct = Comp.top();
	Comp.pop();

	buff << "\t" << ct << " p" << p << ", " << s1 << ", " << s2 << endl;
	buff << "\t== p" << p << ", p" << p << ", 0" << endl;
	++p;
	Pred.push(p);
	++p;

}

| not true 

| not false 

| not   l_paren   bool_exp   r_paren 

| expression   comp   expression {//*******************

	s2 = Var.top();
	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << "\t=[] t" << t << ", " << s2 << ", " << Index.top() << endl;
		s2 = "t" + convert.str();
		++t;
	}
	
	Index.pop();
	Var.pop();

	s1 = Var.top();

	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << "\t=[] t" << t << ", " << s1 << ", " << Index.top() << endl;
		
		s1 = "t" + convert.str();
		t++;
	}

	Var.pop();
	Index.pop();
	string ct = Comp.top();
	Comp.pop();

	buff << "\t" << ct << " p" << p << ", " << s1 << ", " << s2 << endl;
	
	Pred.push(p);
	p++;

} 

| true { //***
	buff << "\t== p" << p << ", 1, 1" << endl;
	Pred.push(p);
	++p;
}

| false { //***
	buff << "\t== p" << p << ", 1, 0" << endl;
	Pred.push(p);
	p++;
} 

| l_paren   bool_exp   r_paren //***

;

 

comp: equal_to { //************

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

 

multiplicative_exp_list: multiplicative_exp_list   add   multiplicative_exp { //***********


	s2 = Var.top();
	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		
		buff << "\t=[] t" << t << ", " << s2 << ", " << Index.top() << endl;
		s2 = "t" + convert.str();
		t++;
	}
	
	Index.pop();
	Var.pop();
 
	s1 = Var.top();

	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;

		buff << "\t=[] t" << t << ", " << s1 << Index.top() << endl;

		s1 = "t" + convert.str();
		++t;
	}

	Var.pop();
	Index.pop();

	buff << "\t+ t" << t << ", " << s1 << ", " << s2 << endl;

	stringstream convert2;
	convert2 << t;
	Var.push("t" + convert2.str());
	Index.push("-1");
	++t;

}

| multiplicative_exp_list   sub multiplicative_exp {//**********

	s2 = Var.top();
	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		
		buff << "\t=[] t" << t << ", " << s2 << ", " << Index.top() << endl;
		s2 = "t" + convert.str();
		t++;
	}
	
	Index.pop();
	Var.pop();
 
	s1 = Var.top();

	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;

		buff << "\t=[] t" << t << ", " << s1 << Index.top() << endl;

		s1 = "t" + convert.str();
		++t;
	}

	Var.pop();
	Index.pop();

	buff << "\t- t" << t << ", " << s1 << ", " << s2 << endl;

	stringstream convert2;
	convert2 << t;
	Var.push("t" + convert2.str());
	Index.push("-1");
	++t;
}

| add   multiplicative_exp 

| sub   multiplicative_exp 

|  /* epsilon */ 

;


multiplicative_exp: term   term_list //*******

;

 

term_list: term_list   multiply   term { //********

	s2 = Var.top();
	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << "\t=[] t" << t << ", " << s2 << ", " << Index.top() << endl;
		s2 = "t" + convert.str();
		++t;
	}

	Var.pop();
	Index.pop();
	
	s1 = Var.top();

	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << "\t=[] t" << t << ", " << s1 << ", " << Index.top() << endl;
		s1 = "t" + convert.str();
		++t;
	}

	Var.pop();
	Index.pop();

	buff << " * t" << t << ", " << s1 << ", " << s2 << endl;
	stringstream convert;
	convert << t;
	Var.push("t" + convert.str());
	Index.push("-1");
	++t;
}

| term_list   divide   term 

| term_list   mod   term { //*******
	s2 = Var.top();
	
	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << " =[] t" << t << ", " << s2 << ", " << Index.top() << endl;
		s2 = "t" + convert.str();
		++t;
	}
	
	Index.pop();
	Var.pop();
	
	s1 = Var.top();
	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << " =[] t" << t << ", " << s1 << ", " << Index.top() << endl;
		s1 = "t" + convert.str();
		++t;
	}

	Var.pop();
	Index.pop();
	
	buff << " % t" << t << ", " << s1 << ", " << s2 << endl;
	stringstream convert2;

	convert2 << t;
	Var.push("t" + convert2.str());
	Index.push("-1");
	++t;
}

| multiply  term 

| divide   term { //******************************

	s2 = Var.top();

	if(Index.top() != "-1")
	{
		stringstream convert;
		convert << t;
		buff << " =[] t" << t << ", " << s2 << ", " << Index.top() << endl;
		s2 = "t" + convert.str();
	}
	Var.pop();
	Index.pop();
	s1 = Var.top();
	if(Index.top() != "-1")
	{
		stringstream convert2;
		convert2 << t;
		buff << " =[] t" << t << ", " << s1 << ", " << Index.top() << endl;
		s1 = "t" + convert2.str();
		++t;
	}
	Var.pop();
	Index.pop();

	buff << " 	" << t << ", " << s1 << ", " << s2 << endl;

	stringstream convert3;
	convert3 << t;
	Var.push("t" + convert3.str());
	Index.push("-1");
	++t;
} 

| mod   term 

| /* epsilon */ 

;

 

term: sub   var %prec NEG { //***

	s2 = Var.top();
	if(Index.top() != "-1")
	{
		std::stringstream convert;
		convert << t;

		buff << "=[] t" << t << ", " << s2 << Index.top() << endl;

		s2 = "t" + convert.str();
		t++;
	}
	Var.pop();
	buff << " - t" << t << ", 0, " << s2 << endl;
	stringstream convert;
	convert << t;
	Var.push("t" + convert.str());
	Index.push("-1");
	t++;	
	
}

 

| sub   number var %prec NEG 

| sub   l_paren   expression r_paren %prec NEG {// ***
	s2 = Var.top();
	Var.pop();
	buff << " - t" << t << ", 0, " << s2 << endl;
	stringstream convert;
	convert << t;
	
	Var.push("t" + convert.str());
	Index.push("-1");
	++t;
}

| var {} 

| number {// ***
	stringstream convert;
	convert << $1;

	Var.push(convert.str());
	Index.push("-1");
} 

| l_paren   expression   r_paren 

;

 

var: identifier {// ***
	map<string, int>::iterator i;
	
	i = Symbols.find(Var.top());
	if(i != Symbols.end())
	{
		if((*i).second != -1)
		{
			errors = "Error: the array " + Var.top().substr(1, Var.top().length()-1) + " lacks an index";
			yyerror(errors.c_str());
		}
	}

	Index.push("-1");
} 

| identifier   l_bracket   expression   r_bracket { //@@@

	Index.pop();
	Index.push(Var.top());
	Var.pop();

}

;

 

program: PROGRAM 

;

 

identifier: IDENT { //***

	string id = "_" + string($1);
	if(Symbols.find(id) == Symbols.end())
	{
		errors = "Error: " + id + " is undeclared";
		yyerror(errors.c_str());
	}
	bool keybool = false;

		//bool keybool = false;
		int size = Keywords.size();
		for(int j =0; j < size; j++)
		{
			(id == Keywords[j]) ? keybool = true : keybool;	
		}

	if(keybool == true)
	{
		errors = "Error: " + id + " has been defined as a keyword and cannot be used";
		yyerror(errors.c_str());
	}

	Var.push(id);
	// Search symbol table for identifier
	/*string id = "_" + string($1);
	map <string, int>::iterator i = Symbols.find(id);

	// Error check
	if (i != Symbols.end())
	{
		errors = "Error: " + id + " was previously defined";
		yyerror(errors.c_str());
	}
	
	Symbols[id] = -1;
	ID.push(id);*/

	/*bool keybool = false;
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

	Var.push(id);*/

}

;

 

semicolon: SEMICOLON  

;

 

end_program: END_PROGRAM 

;

 

begin_program: BEGIN_PROGRAM {
	buff << ": START" << endl;
} 

;

 

comma: COMMA 

;

 

colon: COLON 

;

array: ARRAY 

;

 

l_bracket: L_BRACKET 

;

 

number: NUMBER { //***
	stringstream convert1;
	convert1 << $1;
	buff << " - t" << t << ", 0, " << convert1.str() << endl;

	stringstream convert2;
	convert2 << t;
	
	Var.push("t" + convert2.str());
	Index.push("-1");
	++t;
} 

;

 

r_bracket: R_BRACKET 

;



l_paren: L_PAREN {
	map<string, int>::iterator i;
	i = Symbols.find(Var.top());

	if(i != Symbols.end())
	{
		if((*i).second == -1)
		{
			errors = "Error: the variable " + Var.top().substr(1, Var.top().length() - 1) + " cannot have index";
			yyerror(errors.c_str());
		}
	}
}

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
{ //$$$ 

	int s2 = Pred.top();
	Pred.pop();

	buff << "\t?:= L" << l << ", p" << s2 << endl;
	Label.push(l);
	l++;	
}

;

 

end_if: ENDIF {//***

	buff << ": L" << Label.top() << endl;
	Label.pop();

} 

;

 

elseif: ELSEIF 

;

 

else: ELSE {//***

	buff << "\t:= L" << l << endl;
	buff << ": L" << Label.top() << endl;
	Label.pop();
	Label.push(l);

	l++;

}

;

 

while: WHILE {//***

	buff << ": L" << l << endl;

	Loop.push(l);
	Label.push(l);
	++l;
	
} 

;

 

begin_loop: BEGINLOOP { // $$$$$

	int s2 = Pred.top();
	Pred.pop();
	buff << "\t?:= L" << l << ", p" << s2 << endl;
	Label.push(l);
	++l;
} 

;

 
dend_loop: ENDLOOP { // $$$$$$$$$

	int l1 = Loop.top();
	buff << ": L " << l1 << endl;
	Loop.pop();


}


end_loop: ENDLOOP { // $$$
	int s2 = Label.top();
	Label.pop();

	int s1 = Label.top();
	Label.pop();

	buff << "\t:= L" << s1 << endl << ": L" << s2 << endl;
	Loop.pop();
}

;

 

do: DO {// ***
	buff << ": L" << l << endl;
	Label.push(l);
	++l;
	Loop.push(l);
	++l;
}

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
