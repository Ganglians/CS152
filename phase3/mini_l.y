/* Kenneth Mayorga and Juan Chavez Compiler Project Phase 2 */

%{
 #include <stdlib.h>
 #include <stdio.h>
 #include <string>
 #include <iostream>
 #include <sstream>
 #include <vector>
 #include <stack>
 using namespace std;

 int yylex(void);

 void yyerror(const char *msg);
 int yylex(void); 

 extern int currLine;
 extern int currPos;

 bool Err = false;
 int t = 0, p = 0, l = 0;
 
 stringstream Out;
 string s1 = "", s2 = "", errors = "";

 // Storage Vectors
 vector<string> ID;
 vector<string> Var;
 vector<string> Cmp;
 vector<string> Index;
 vector<string> Rev;
 vector<string> Label;
 vector<string> Loop;
 vector<string> Pred;

%}

 

%union{
  int number;

  char *string;
}

 /* %error-verbose */

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

%%
start: program_start {
	Out << ": START\n";
} 

;

 

program_start: program   identifier   semicolon   block   end_program {
	{
		for(int i = 0; i < t; i++)
		{
			cout << "\t. t" << i << endl;
		}

		for(int j = 0; j < p; j ++)
		{
			cout << "\t. p" << j << endl;
		}

		cout << Out.str();
	}
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
		Out << "\t. " << ID.back() << endl;
		ID.pop_back();
	}
} 

;

 

identifier_list: identifier_list comma identifier   

| identifier 

;

 

optional_array: array   l_bracket   number   r_bracket   of {
/* if(atoi($3)) 
 {
	errors = "Error: Declaring array of invalid size.";
	yyerror(errors.c_str());	
 } */
} 

| /* epsilon */ 

;

 

statement: var   assign   expression 

| var   assign   bool_exp   question   expression   colon   expression 

| if   bool_exp   then   statement_list   optional_elseif   optional_else   end_if 

| while   bool_exp   begin_loop   statement_list   end_loop 

| do   begin_loop   statement_list   end_loop   while bool_exp 

| read   var_list 

| write   var_list 

| break 

| continue 

| exit 

;

 

optional_elseif:     optional_elseif   elseif   bool_exp   statement_list 

| elseif   bool_exp   statement_list

| /* epsilon */ 

;

 

optional_else:       else   statement_list 

| /* epsilon */ 

;

 

var_list:  var_list   comma   var 

| var 

;

 

statement_list:      statement_list   statement   semicolon 

| statement   semicolon 

;

 

bool_exp:              relation_and_exp   relation_and_exp_list 

;

 

relation_and_exp_list:         relation_and_exp_list   or   relation_and_exp 

| or relation_and_exp 

| /* epsilon */ 

;

 

relation_and_exp:                relation_exp   relation_exp_list 

                                                ;

 

relation_exp_list:  relation_exp_list   and   relation_exp 

| and   relation_exp 

| /* epsilon */ 

;

 

relation_exp:         not   expression   comp   expression 

| not true 

| not   false 

| not   l_paren   bool_exp   r_paren 

| expression   comp   expression 

| true 

| false 

| l_paren   bool_exp   r_paren 

;

 

comp:     equal_to 

| not_equal_to 

| less_than 

| greater_than 

| less_than_or_equal_to 

| greater_than_or_equal_to 

;

 

expression:           multiplicative_exp   multiplicative_exp_list 

                                ;

 

multiplicative_exp_list:       multiplicative_exp_list   add   multiplicative_exp 

| multiplicative_exp_list   sub multiplicative_exp 

| add   multiplicative_exp 

| sub   multiplicative_exp 

|  /* epsilon */ 

;

 

multiplicative_exp:               term   term_list 

                                                ;

 

term_list:               term_list   multiply   term 

| term_list   divide   term 

| term_list   mod   term 

| multiply  term 

| divide   term 

| mod   term 

| /* epsilon */ 

;

 

term:       sub   var %prec NEG 

| sub   number var %prec NEG 

| sub   l_paren   expression r_paren %prec NEG 

| var 

| number 

| l_paren   expression   r_paren 

;

 

var:         identifier 

| identifier   l_bracket   expression   r_bracket 

;

 

program: PROGRAM 

;

 

identifier: IDENT 

;

 

semicolon:            SEMICOLON 

;

 

end_program:       END_PROGRAM 

;

 

begin_program:    BEGIN_PROGRAM 

;

 

comma:  COMMA 

;

 

colon:     COLON 

;

array:      ARRAY 

;

 

l_bracket:               L_BRACKET 

;

 

number: NUMBER 

;

 

r_bracket:              R_BRACKET 

;



l_paren:		L_PAREN 

;



r_paren:		R_PAREN 

;

 

of:           OF 

;

integer: INTEGER 

;

 

assign: ASSIGN 

;

 

question: QUESTION 

;

 

if: IF 

;

 

then: THEN 

;

 

end_if: ENDIF 

;

 

elseif: ELSEIF 

;

 

else: ELSE 

;

 

while: WHILE 

;

 

begin_loop: BEGINLOOP 

;

 

end_loop: ENDLOOP 

;

 

do: DO 

;

 

read: READ 

;

 

write: WRITE 

;

 

 

break:     BREAK 

;

 

continue:               CONTINUE 

;

exit:        EXIT 

;

 

or:           OR 

;

 

and:        AND 

;

 

not:         NOT 

;

 

true:        TRUE 

;

 

false:      FALSE 

;

 

equal_to:               EQ 

;

 

not_equal_to:       NEQ 

;

 

less_than:              LT 

;

 

greater_than:        GT 

;

 

less_than_or_equal_to:       LTE 

;

 

greater_than_or_equal_to: GTE 

;

add:        ADD 

;

 

sub:        SUB 

;

 

multiply:                MULT 

;

 

divide:    DIV 

;

 

mod:       MOD 

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
