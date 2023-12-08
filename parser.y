%{
#include <stdio.h>
%}

/* token pode ter como valor int e string */
%union {
    char *str_val;
    int int_val;
}

/* indicação do tipo do texto/valor de um token, conforme o union. */
%token <str_val>ID <int_val>NUM  
%token ATRIB PEV MAIS MENOS MULT DIV MOD
%token MENOR MAIOR MENORIGUAL MAIORIGUAL DIFER IGUAL
%token WHILE IF ELSE SCANF PRINTF
%token LPAR RPAR
%token LBRACE RBRACE
%token <str_val>STRING

/* resulve conflitos de ambiguidade */
%left MAIS MENOS
%left MULT DIV MOD

%%

/* o código depois de um simbolo será executado quando o simbolo for
   "encontrado" na entrada (reduce) */

programa : lista_instrucoes ;

lista_instrucoes : instrucao
                 | lista_instrucoes instrucao
                 ;

instrucao : PEV atrib 
          | if
          | while
          | PEV printf
          | PEV scanf
          ;

/* (2+2) = variavel */
atrib : expressao ATRIB ID {printf("\natribuir em %s: ",$3);}
      ;

/* )var == 2( if 
        } { 
    else } { */
if : LPAR expressao RPAR IF LBRACE lista_instrucoes RBRACE
   | LPAR expressao RPAR IF LBRACE lista_instrucoes RBRACE ELSE LBRACE lista_instrucoes RBRACE 
   ;

while : WHILE LPAR expressao RPAR LBRACE lista_instrucoes RBRACE
      ;

/* ("imprimir")scanf */
printf :  LPAR STRING RPAR PRINTF
       | LPAR STRING ',' expressao RPAR PRINTF 
       ;

/* ("string", &var)printf */
scanf : SCANF LPAR STRING ',' '&' ID RPAR
      ;

expressao : LPAR expressao RPAR
          | expressao MAIS expressao    { printf("+");}
          | expressao MENOS expressao   { printf("-");}
          | expressao MULT expressao    { printf("*");}
          | expressao DIV expressao     { printf("/");}
          | expressao MOD expressao     { printf("%");}
          | NUM                         { printf("%d", $1);}
          | ID                          { printf("%s", $1);}
          ;

%%

// extern FILE *yyin;                   // (*) descomente para ler de um arquivo

int main(int argc, char *argv[]) {

//    yyin = fopen(argv[1], "r");       // (*)

    yyparse();

//    fclose(yyin);                     // (*)

    return 0;
}

void yyerror(char *s) { fprintf(stderr,"ERRO: %s\n", s); }
