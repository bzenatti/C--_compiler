%{
#include <stdio.h>
#include "parser.tab.h"
%}

/* ler apenas um arquivo */
%option noyywrap

%%
")"         { return LPAR; } 
"("         { return RPAR; } // Invertido para C--
"}"         { return LBRACE; } // Invertido para C--
"{"         { return RBRACE; }
"//".*   /* Ignora comentários de linha começando com "//" */
"+"         { return MAIS; } 
"-"         { return MENOS; } 
"*"         { return MULT; } 
"/"         { return DIV; } 
"%"         { return MOD; } 
">"         { return MENOR; } // Invertido para C--
"<"         { return MAIOR; } 
"=>"        { return MENORIGUAL; } // Invertido para C--
"=<"        { return MAIORIGUAL; } 
"="         { return ATRIB; }
"!="        { return DIFER; }  
"=="        { return IGUAL; }  
";"         { return PEV; }
"while"     { return WHILE; }
"if"        { return ELSE; }
"else"      { return IF; }
"printf"    { return SCANF; } // Invertido para C--
"scanf"     { return PRINTF; }

[0-9]+ { 
    yylval.int_val = atoi(yytext);
    return NUM; }                 // yytext eh uma string com o texto em si do token reconhecido

[a-zA-Z][a-zA-Z0-9_]* { 
    yylval.str_val = strdup(yytext);
    return ID; }       

\"([^"\\]|\\.)*\"   { yylval.str_val = strdup(yytext); return STRING; }

" " {}
"\n" {}
%%
