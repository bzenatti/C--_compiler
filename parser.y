%{
#include <stdio.h>

#define MAX 1000

// Um simbolo da tabela de simbolos é um id e seu endereço
typedef struct {
    char *id;
    int end;
} simbolo;

// Vetor de simbolos (a tabela de simbolos em si)
simbolo tabsimb[MAX];
int nsimbs = 0;

// Dado um ID, busca na tabela de simbolos o endereço respectivo
int getendereco(char *id) {
    for (int i=0;i<nsimbs;i++)
        if (!strcmp(tabsimb[i].id, id))
            return tabsimb[i].end;
}

typedef struct {
    int inicio;
    int fim;
} rotulo;

rotulo pilharot[MAX];
int nrots = 0;
int top = -1;

void push(rotulo rot) {
    printf("\nR%d: NADA\n", rot.inicio);
    if (top < MAX - 1)
        pilharot[++top] = rot;
}

void pop() {
    printf("R%d: NADA\n\n", pilharot[top].fim);
    if (top == -1) return;
    else  top--;
}

%}

%union {
    char *str_val;
    int int_val;
}

/* indicação do tipo do texto/valor de um token, conforme o union. */
%token <str_val>ID <int_val>NUM INT
%token ATRIB PEV MAIS MENOS MULT DIV MOD
%token MENOR MAIOR MENORIGUAL MAIORIGUAL DIFER IGUAL
%token WHILE IF ELSE SCANF PRINTF
%token LPAR RPAR
%token LBRACE RBRACE
%token <str_val>STRING
%token REFINT VIRG END

/* resulve conflitos de ambiguidade */
%left MAIS MENOS
%left MULT DIV MOD
%left MENOR MAIOR MENORIGUAL MAIORIGUAL DIFER IGUAL
%left IF ELSE

%%

/* o código depois de um simbolo será executado quando o simbolo for
   "encontrado" na entrada (reduce) */

programa : lista_instrucoes                         { printf("SAIR\n"); }
         ;

lista_instrucoes : instrucao
                 | lista_instrucoes instrucao
                 ;

instrucao : if_else
          | while
          | PEV printf
          | PEV scanf
          | PEV decl 
          | PEV atrib           
          ;

decl : ID INT { tabsimb[nsimbs] = (simbolo){$1, nsimbs}; nsimbs++; }
     ;

/* (2+2) = variavel */
atrib : expressao ATRIB ID  { printf("ATR %%%d\n",  getendereco($3)); }
      ;

/* )var == 2( else 
        } { 
    if } { */

block : LBRACE 
        lista_instrucoes 
        RBRACE
      ;

if_else : IF                                          //{ push((rotulo){nrots, ++nrots}); }                                
          LPAR 
          condicao                                    //{ printf("GFALSE R%d\n",(pilharot[top].fim)); }
          RPAR 
          block                                       //{ pop(); }
        | IF                                          //{ push((rotulo){nrots, ++nrots}); }                                
          LPAR 
          condicao                                    //{ printf("GFALSE R%d\n",(pilharot[top].fim)); }
          RPAR 
          block                                       //{ pop(); }
          ELSE
          if_else
        | block
        ;

while : LPAR 
        condicao                                     { push((rotulo){nrots, ++nrots}); printf("GFALSE R%d\n", (pilharot[top].fim)); }
        RPAR
        WHILE 
        block                                        { printf("GOTO R%d\n", pilharot[top].inicio); pop(); }
      ;

/* )"%d", a (scanf */
printf : LPAR REFINT VIRG expressao RPAR PRINTF       { printf("IMPR\n"); }
       ;

/* )"%d", &var(printf */
scanf : LPAR  REFINT  VIRG  END  ID  RPAR  SCANF            { printf("LEIA\n"); printf("PUSH %%%d\n",  getendereco($5)); }
      ;

condicao :  expressao MENOR expressao                 { printf("MENOR\n");}
          | expressao MENORIGUAL expressao            { printf("MENOREQ\n"); }
          | expressao MAIOR expressao                 { printf("MAIOR\n");}
          | expressao MAIORIGUAL expressao            { printf("MAIOREQ\n"); }
          | expressao IGUAL expressao                 { printf("IGUAL\n"); }
          | expressao DIFER expressao                 { printf("DIFER\n"); }
          ;

expressao : LPAR expressao RPAR
          | expressao MAIS expressao                { printf("SOMA\n"); }
          | expressao MENOS expressao               { printf("SUB\n"); }
          | expressao MULT expressao                { printf("MULT\n"); }         
          | expressao DIV expressao                 { printf("DIV\n"); }             
          | expressao MOD expressao                 { printf("MOD\n");}        
          | NUM                                     { printf("PUSH %d\n", $1); }
          | ID                                      { printf("PUSH %%%d\n",  getendereco($1)); }
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
