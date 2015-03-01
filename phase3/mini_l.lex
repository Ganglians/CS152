/* Kenneth Mayorga and Juan Chavez */

    /* cs152 Winter 2015 */

   /* A flex scanner specification for the mini language */

 

%{

   #include "y.tab.h"

   #include <string.h>

   #include <stdio.h>

   #include <stdlib.h>

   int currLine = 1, currPos = 1;

%}

 

DIGIT   [0-9]

ALPHA   [a-zA-Z]

ALPHANUM        [a-zA-Z0-9]

%%

 

"program"       {currPos += yyleng; return PROGRAM;}

"beginprogram"  {currPos += yyleng; return BEGIN_PROGRAM;}

"endprogram"    {currPos += yyleng; return END_PROGRAM;}

"integer"       {currPos += yyleng; return INTEGER;}

"array" {currPos += yyleng; return ARRAY;}

"of"    {currPos += yyleng; return OF;}

"if"    {currPos += yyleng; return IF;}

"then"  {currPos += yyleng; return THEN;}

"endif" {currPos += yyleng; return ENDIF;}

"else"  {currPos += yyleng; return ELSE;}

"elseif"        {currPos += yyleng; return ELSEIF;}

"while" {currPos += yyleng; return WHILE;}

"do"    {currPos += yyleng; return DO;}

"beginloop"     {currPos += yyleng; return BEGINLOOP;}

"endloop"       {currPos += yyleng; return ENDLOOP;}

"break" {currPos += yyleng; return BREAK;}

"continue"      {currPos += yyleng; return CONTINUE;}

"exit"  {currPos += yyleng; return EXIT;}

"read"  {currPos += yyleng; return READ;}

"write" {currPos += yyleng; return WRITE;}

"and"   {currPos += yyleng; return AND;}

"or"    {currPos += yyleng; return OR;}

"not"   {currPos += yyleng; return NOT;}

"true"  {currPos += yyleng; return TRUE;}

"false" {currPos += yyleng; return FALSE;}

"-"     {currPos += yyleng; return SUB;}

"+"     {currPos += yyleng; return ADD;}

"*"     {currPos += yyleng; return MULT;}

"/"     {currPos += yyleng; return DIV;}

"%"     {currPos += yyleng; return MOD;}

"=="    {currPos += yyleng; return EQ;}

"<>"    {currPos += yyleng; return NEQ;}

"<"     {currPos += yyleng; return LT;}

">"     {currPos += yyleng; return GT;}

"<="    {currPos += yyleng; return LTE;}

">="    {currPos += yyleng; return GTE;}

";"     {currPos += yyleng; return SEMICOLON;}

":"     {currPos += yyleng; return COLON;}

","     {currPos += yyleng; return COMMA;}

"?"     {currPos += yyleng; return QUESTION;}

"["     {currPos += yyleng; return L_BRACKET;}

"]"     {currPos += yyleng; return R_BRACKET;}

"("     {currPos += yyleng; return L_PAREN;}

")"     {currPos += yyleng; return R_PAREN;}

":="    {currPos += yyleng; return ASSIGN;}

{DIGIT}+        {yylval.number = atoi(yytext); currPos += yyleng; return NUMBER;}

[ \t]+  {currPos += yyleng;}

"\n"    {currLine++; currPos = 1;}

{ALPHA}+("_"*{ALPHANUM}+)*      {currPos+= yyleng; yylval.string = strdup(yytext); return IDENT;}

"_"+("_"*{ALPHANUM}+"_"*)+      {printf("Error at line %d identifier %s can not begin with underscores\n", currLine, yytext);}

{DIGIT}+("_"*{ALPHANUM}+"_"*)+  {printf("Error at line %d identifier %s can not begin numbers\n", currLine, yytext);}

{ALPHA}+("_"*{ALPHANUM}+"_"+)+  {printf("Error at line %d identifier %s can not end with underscores\n", currLine, yytext);}

"##".*  /* ignore comments */

.       {printf("Error at line %d  unrecognized symbol %s \n", currLine, yytext);}

 

%%
