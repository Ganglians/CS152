/* Kenneth Mayorga and Juan Chavez Compiler Project Phase 2 */

%{

 #include <stdio.h>

 #include <stdlib.h>

 void yyerror(const char *msg);

 int yylex();

 extern int currLine;

 extern int currPos;

 FILE * yyin;

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

 

start:       program_start { printf( "start -> program_start\n"); }

;

 

program_start:      program   identifier   semicolon   block   end_program { printf( "program_start -> program identifier semicolon block end_program\n"); }

	| error program identifier semicolon block end_program { yyerrok; yyclearin; }
;

 

block:     declaration_list   begin_program   statement_list { printf( "block -> declaration_list   begin_program   statement_list\n"); }

                ;

 

declaration_list:    declaration_list   declaration   semicolon { printf( "declaration_list -> declaration_list semicolon\n"); } 

| declaration   semicolon { printf( "declaration_list -> declaration semicolon\n" ); }

                                ;

 

declaration :          identifier_list   colon   optional_array   integer { printf( "declaration -> identifier_list colon optional_array integer\n" ); }

;

 

identifier_list:   identifier_list comma identifier   { printf( "identifier_list -> identifier_list identifier comma \n"); }

| identifier { printf( "identifier_list -> identifier\n"); }

;

 

optional_array:     array   l_bracket   number   r_bracket   of { printf( "optional_array -> array l_bracket number r_bracket of\n"); } 

| /* epsilon */ { printf( "optional_array -> epsilon\n"); }

;

 

statement:             var   assign   expression { printf( "statement -> var assign expression\n"); }  

| var   assign   bool_exp   question   expression   colon   expression { printf( "statement -> var assign bool_exp question expression colon expression\n"); } 

| if   bool_exp   then   statement_list   optional_elseif   optional_else   end_if { printf( "statement -> if bool_exp then statement_list optional_elseif optional_else end_if \n"); } 

| while   bool_exp   begin_loop   statement_list   end_loop { printf( "statement -> while bool_exp begin_loop statement_list end_loop\n"); } 

| do   begin_loop   statement_list   end_loop   while bool_exp { printf( "statement -> do begin_loop statement_list end_loop while bool_exp\n"); } 

| read   var_list { printf( "statement -> read var_list\n"); } 

| write   var_list { printf( "statement -> write var_list\n"); } 

| break { printf( "statement -> break\n"); }  

| continue { printf( "statement -> continue\n"); } 

| exit { printf( "statement -> exit\n"); }

;

 

optional_elseif:     optional_elseif   elseif   bool_exp   statement_list { printf( "optional_elseif -> optional_elseif elseif bool_exp statement_list\n"); } 

| elseif   bool_exp   statement_list   optional_else { printf( "optional_elseif -> elseif bool_exp statement_list optional_else\n"); }

| /* epsilon */ { printf( "optional_elseif -> epsilon\n"); }

;

 

optional_else:       else   statement_list { printf( "optional_else -> else statement_list\n"); }  

| /* epsilon */ { printf( "optional_else -> epsilon\n"); }

;

 

var_list:  var_list   comma   var { printf( "var_list -> var_list comma var\n"); } 

| var { printf( "var_list -> var\n"); }

;

 

statement_list:      statement_list   statement   semicolon { printf( "statement_list -> statement_list statement semicolon\n"); } 

| statement   semicolon { printf( "statement_list -> statement semicolon\n"); }

;

 

bool_exp:              relation_and_exp   relation_and_exp_list { printf( "bool_exp -> relation_and_exp relation_and_exp_list \n"); }

                                ;

 

relation_and_exp_list:         relation_and_exp_list   or   relation_and_exp { printf( "relation_and_exp_list -> relation_and_exp_list or relation_and_exp\n"); }  

| or relation_and_exp { printf( "relation_and_exp_list -> or relation_and_exp\n"); }  

| /* epsilon */ { printf( "relation_and_exp_list -> epsilon\n"); }

;

 

relation_and_exp:                relation_exp   relation_exp_list { printf( "relation_and_exp -> relation_exp relation_exp_list\n"); }

                                                ;

 

relation_exp_list:  relation_exp_list   and   relation_exp { printf( "relation_exp_list -> relation_exp_list and relation_exp\n"); }  

| and   relation_exp { printf("relation_exp_list -> and relation_exp\n"); }  

| /* epsilon */ { printf("relation_exp_list -> epsilon\n"); }

;

 

relation_exp:         not   expression   comp   expression { printf( "relation_exp -> not expression comp expression\n"); }  

| not true { printf( "relation_exp -> not true\n"); }  

| not   false { printf( "relation_exp -> not false\n"); } 

| not   l_paren   bool_exp   r_paren { printf( "relation_exp -> not l_paren bool_exp r_paren\n"); } 

| expression   comp   expression { printf( "relation_exp -> expression comp expression\n"); } 

| true { printf( "relation_exp -> true\n"); }    

| false { printf( "relation_exp -> false\n"); }   

| l_paren   bool_exp   r_paren { printf( "relation_exp -> l_paren bool_exp r_paren\n"); }

;

 

comp:     equal_to { printf( "comp -> equal_to\n"); } 

| not_equal_to { printf( "comp -> not_equal_to\n"); }  

| less_than { printf( "comp -> less_than\n"); } 

| greater_than { printf( "comp -> greater_than\n"); } 

| less_than_or_equal_to { printf( "comp -> less_than_or_equal_to\n"); } 

| greater_than_or_equal_to { printf( "comp -> greater_than_or_equal_to\n"); }

;

 

expression:           multiplicative_exp   multiplicative_exp_list { printf( "expression -> multiplicative_exp multiplicative_exp_list\n"); }

                                ;

 

multiplicative_exp_list:       multiplicative_exp_list   add   multiplicative_exp { printf( "multiplicative_exp_list -> multiplicative_exp_list add multiplicative_exp \n"); }  

| multiplicative_exp_list   sub multiplicative_exp { printf( "multiplicative_exp_list -> | multiplicative_exp_list   sub multiplicative_exp\n"); }  

| add   multiplicative_exp { printf( "multiplicative_exp_list -> add multiplicative_exp\n"); }

| sub   multiplicative_exp { printf( "multiplicative_exp_list -> sub multiplicative_exp\n"); } 

|  /* epsilon */ { printf( "multiplicative_exp_list -> epsilon\n"); }

;

 

multiplicative_exp:               term   term_list { printf( "multiplicative_exp -> term term_list\n"); }

                                                ;

 

term_list:               term_list   multiply   term { printf( "term_list -> term_list multiply term\n"); }  

| term_list   divide   term { printf( "term_list -> term_list divide term\n"); } 

| term_list   mod   term { printf( "term_list -> term_list mod term\n"); } 

| multiply  term { printf( "term_list -> multiply term\n"); } 

| divide   term { printf( "term_list -> divide term\n"); } 

| mod   term { printf( "term_list -> mod term\n"); } 

| /* epsilon */ { printf( "term_list -> epsilon\n"); }

;

 

term:       sub   var %prec NEG { printf( "term -> sub var\n"); }  

| sub   number var %prec NEG { printf( "term -> sub number\n"); }  

| sub   l_paren   expression r_paren %prec NEG { printf( "term -> sub l_paren expression r_paren\n"); }  

| var { printf( "term -> var\n"); } 

| number { printf( "term -> number\n"); } 

| l_paren   expression   r_paren { printf( "term -> l_paren expression r_paren\n"); }

;

 

var:         identifier { printf( "var -> identifier\n"); } 

| identifier   l_bracket   expression   r_bracket { printf( "var -> identifier l_bracket expression r_bracket\n"); }

;

 

program:                PROGRAM { printf( "program -> PROGRAM\n"); }

                                ;

 

identifier:               IDENT { printf( "identifier -> IDENT (%s)\n", $1); }

                                ;

 

semicolon:            SEMICOLON { printf( "semicolon -> SEMICOLON\n"); }

                                ;

 

end_program:       END_PROGRAM { printf( "end_program -> ENDPROGRAM\n"); }

                                ;

 

begin_program:    BEGIN_PROGRAM { printf( "begin_program -> BEGINPROGRAM\n"); }

                                ;

 

comma:  COMMA { printf( "comma -> COMMA\n"); }

                ;

 

colon:     COLON { printf( "colon -> COLON\n"); }

                ;

array:      ARRAY { printf( "array -> ARRAY\n"); }

                ;

 

l_bracket:               L_BRACKET { printf( "l_bracket -> L_BRACKET\n"); }

                                ;

 

number: NUMBER { printf( "number -> NUMBER (%d)\n", $1); }

                                ;

 

r_bracket:              R_BRACKET { printf( "r_bracket -> R_BRACKET\n"); }

                                ;



l_paren:		L_PAREN { printf( "l_paren -> L_PAREN\n"); }
				;



r_paren:		R_PAREN { printf( "r_paren -> R_PAREN\n"); }
				;

 

of:           OF { printf( "of -> OF\n"); }

                ;

integer:  INTEGER { printf( "integer -> INTEGER\n"); }

                ;

 

assign:   ASSIGN { printf( "assign -> ASSIGN\n"); }

                ;

 

question:               QUESTION { printf( "question -> QUESTION\n"); }

                                ;

 

if:            IF { printf( "if -> IF\n"); }

                ;

 

then:       THEN { printf( "then -> THEN\n"); }

                ;

 

end_if:    ENDIF { printf( "endif -> ENDIF\n"); }

                ;

 

elseif:     ELSEIF { printf( "elseif -> ELSEIF\n"); }

                ;

 

else:        ELSE { printf( "else -> ELSE\n"); }

                ;

 

while:     WHILE { printf( "while -> WHILE\n"); }

                ;

 

begin_loop:           BEGINLOOP { printf( "begin_loop -> BEGINLOOP\n"); }

                                ;

 

end_loop:              ENDLOOP { printf( "end_loop -> ENDLOOP\n"); }

                                ;

 

do:          DO { printf( "do -> DO\n"); }

                ;

 

read:       READ { printf( "read -> READ\n"); }

                ;

 

write:      WRITE { printf( "write -> WRITE\n"); }

                ;

 

 

break:     BREAK { printf( "break -> BREAK\n"); }

                ;

 

continue:               CONTINUE { printf( "continue -> CONTINUE\n"); }

                                ;

exit:        EXIT { printf( "exit -> EXIT\n"); }

                ;

 

or:           OR { printf( "or -> OR\n"); }

                ;

 

and:        AND { printf( "and -> AND\n"); }

                ;

 

not:         NOT { printf( "not -> NOT\n"); }

                ;

 

true:        TRUE { printf( "true -> TRUE\n"); }

                ;

 

false:      FALSE { printf( "false -> FALSE\n"); }

                ;

 

equal_to:               EQ { printf( "equal_to -> EQ\n"); }

                                ;

 

not_equal_to:       NEQ { printf( "not_equal_to -> NEQ\n"); }

                                ;

 

less_than:              LT { printf( "less_than -> LT\n"); }

                                ;

 

greater_than:        GT { printf( "greater_than -> GT\n"); }

                                ;

 

less_than_or_equal_to:       LTE { printf( "less_than_or_equal_to -> LTE\n"); }

;

 

greater_than_or_equal_to: GTE { printf( "greater_than_or_equal_to -> GTE\n"); }

                                                                ;

add:        ADD { printf( "add -> ADD\n"); }

                ;

 

sub:        SUB { printf( "sub -> SUB\n"); }

                ;

 

multiply:                MULT { printf( "multiply -> MULT\n"); }

                                ;

 

divide:    DIV { printf( "divide -> DIVIDE\n"); }

                ;

 

mod:       MOD { printf( "mod -> MOD\n"); }

                ;

 

%%

 

int main(int argc, char **argv) {

   if (argc > 1) {

      yyin = fopen(argv[1], "r");

      if (yyin == NULL){

         printf("syntax: %s filename\n", argv[0]);

      }//end if

   }//end if

   yyparse(); // Calls yylex() for tokens.

   return 0;

}

 

void yyerror(const char *msg) {

   printf("** Line %d %s\n", currLine, msg);
}
