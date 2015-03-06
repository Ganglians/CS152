#include <stdlib.h>
#include <stdio.h>

 FILE * yyin;

 int yyparse();
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

 


