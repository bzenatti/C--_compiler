%{
#include <stdio.h>
#include "parser.tab.h"
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

%%

/* o código depois de um simbolo será executado quando o simbolo for
   "encontrado" na entrada (reduce) */

atrib : ID ATRIB expr PEV {printf("\natribuir em %s\n", $1); };

/* note que '+' será impresso só depois das impressoes em expr e termo */
expr : expr MAIS termo {printf("+ ");}
     | termo ;

termo : termo DIV fator {printf("/ ");}
      | fator ;

fator : ID {printf("%s ", $1);}
      | NUM {printf("%d ", $1);}
      | LPAR expr RPAR ;

%%

// extern FILE *yyin;                   // (*) descomente para ler de um arquivo

int main(int argc, char *argv[]) {

//    yyin = fopen(argv[1], "r");       // (*)

    yyparse();

//    fclose(yyin);                     // (*)

    return 0;
}

void yyerror(char *s) { fprintf(stderr,"ERRO: %s\n", s); }
