%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 10000

FILE *output;
char buffer[MAX], straux[MAX];
int aux = 0;

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

    printf("ERRO SEMÂNTICO: variável \"%s\" não declarada.\n", id);
    exit(1);
    return -1;
}

// Dado um ID, verifica se a respectiva variável já foi declarada
void checkendereco(char *id) {
    for (int i=0;i<nsimbs;i++) {
            if (!strcmp(tabsimb[i].id, id)) {
                printf("ERRO SEMÂNTICO: variável \"%s\" declarada mais de uma vez.\n", id);
                exit(1);
            }
     }
}

void imprimir_buffer() {
    fprintf(output, "%s", buffer);
    memset(buffer, 0, sizeof buffer);
}

// Tupla de rotulos para gerenciar desvios condicionais
typedef struct {
    int inicio;
    int fim;
} rotulo;

// Pilha de rótulos
rotulo pilharot[MAX];
int nrots = -1;
int top = -1;

void push(rotulo rot) {
    if (top < MAX - 1) pilharot[++top] = rot;
}

void pop() {
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
%token REFINT VIRG END

/* resulve conflitos de ambiguidade */
%left MAIS MENOS
%left MULT DIV MOD
%left MENOR MAIOR MENORIGUAL MAIORIGUAL DIFER IGUAL

%precedence LBRACE

%%

/* o código depois de um simbolo será executado quando o simbolo for
   "encontrado" na entrada (reduce) */

programa : lista_instrucoes                         {   fprintf(output, "\tSAIR\n");                         }
         ;

lista_instrucoes : instrucao
                 | lista_instrucoes instrucao
                 ;

instrucao : LPAR  condicao  RPAR desv_condicionais
          | PEV printf
          | PEV scanf
          | PEV decl 
          | PEV atrib           
          ;

/* 
    ; a char
    ; 3 = a char
*/
decl : ID INT                                       { 
                                                        checkendereco($1);
                                                        tabsimb[nsimbs] = (simbolo){$1, nsimbs}; 
                                                        nsimbs++; 
                                                    }
      | expressao ATRIB ID INT                      {   
                                                        imprimir_buffer();
                                                        checkendereco($3);
                                                        tabsimb[nsimbs] = (simbolo){$3, nsimbs}; 
                                                        nsimbs++;   
                                                        fprintf(output, "\tATR %%%d\n",  getendereco($3)); 
                                                    }
     ;

/* ;(2+2) = variavel */
atrib : expressao ATRIB ID                          {   
                                                        imprimir_buffer();
                                                        fprintf(output, "\tATR %%%d\n",  getendereco($3));   
                                                    }
      ;

/* 
    ) a < c ( while } {
    ) a != 0 ( else } { if  } {
*/

desv_condicionais : WHILE                           {  
                                                        push((rotulo){++nrots, ++nrots});
                                                        fprintf(output, "R%d: NADA\n", pilharot[top].inicio);
                                                        imprimir_buffer();
                                                        fprintf(output, "\tGFALSE R%d\n", (pilharot[top].fim));
                                                    }	
                    LBRACE lista_instrucoes RBRACE  { 
                                                        fprintf(output, "\tGOTO R%d\n", pilharot[top].inicio);
                                                        fprintf(output, "R%d: NADA\n", pilharot[top].fim);
                                                        pop(); 
                                                    }
                  | IF                              {
                                                        push((rotulo){nrots, ++nrots});
                                                        fprintf(output, "\tGFALSE R%d\n", (pilharot[top].inicio)); 
                                                    }
                    LBRACE lista_instrucoes RBRACE  { 
                                                        fprintf(output, "\tGOTO R%d\n", pilharot[top].fim); 
                                                        fprintf(output, "R%d: NADA\n", pilharot[top].inicio); 
                                                    }
                  else                              {
                                                        fprintf(output, "R%d: NADA\n", pilharot[top].fim);
                                                        pop();
                                                    }
                  ;
else : ELSE LBRACE lista_instrucoes RBRACE  | ;

/* )"%d", a (scanf */
printf : LPAR REFINT VIRG expressao                 {   imprimir_buffer();                                        }
         RPAR PRINTF                                {   fprintf(output, "\tIMPR\n");                            }
       ;

/* )"%d", &var(printf */
scanf : LPAR  REFINT  VIRG  END  ID  RPAR  SCANF    {   
                                                        fprintf(output, "\tLEIA\n");       
                                                        fprintf(output, "\tPUSH %%%d\n", getendereco($5)); 
                                                    }
      ;

condicao :  expressao MENOR expressao               {   strcat(buffer, "\tMENOR\n");                        }
          | expressao MENORIGUAL expressao          {   strcat(buffer, "\tMENOREQ\n");                      }
          | expressao MAIOR expressao               {   strcat(buffer, "\tMAIOR\n");                        }
          | expressao MAIORIGUAL expressao          {   strcat(buffer, "\tMAIOREQ\n");                      }
          | expressao IGUAL expressao               {   strcat(buffer, "\tIGUAL\n");                        }
          | expressao DIFER expressao               {   strcat(buffer, "\tDIFER\n");                        }
          | expressao
          ;

expressao : LPAR expressao RPAR
          | expressao MAIS expressao                {   strcat(buffer, "\tSOMA\n");                         }
          | expressao MENOS expressao               {   strcat(buffer, "\tSUB\n");                          }
          | expressao MULT expressao                {   strcat(buffer, "\tMULT\n");                         }         
          | expressao DIV expressao                 {   strcat(buffer, "\tDIV\n");                          }
          | expressao MOD expressao                 {   strcat(buffer, "\tMOD\n");                          }        
          | NUM                                     {   
                                                        sprintf(straux, "\tPUSH %d\n", $1);
                                                        strcat(buffer, straux);                  
                                                        memset(straux, 0, sizeof straux);
                                                    }
          | ID                                      {    
                                                        sprintf(straux, "\tPUSH %%%d\n",  getendereco($1));
                                                        strcat(buffer, straux);   
                                                        aux = getendereco($1);
                                                        memset(straux, 0, sizeof straux);
                                                    }
          ; 

%%

extern FILE *yyin;                   

int main(int argc, char *argv[]) {
    output = fopen("programa.pil", "w");
    if (output == NULL) {
        printf("Erro ao abrir o arquivo.\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");       
    yyparse();
    fclose(yyin); 
                    
    fclose(output);
    return 0;
}

void yyerror(char *s) { fprintf(stderr,"ERRO: %s\n", s); }
