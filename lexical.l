%{
#include <stdio.h>              // primeira parte: definicoes (o que tiver aqui
                                // vai ser copiado direto para o codigo gerado)
%}

/* coloque esta opcao para o flex ler apenas um arquivo */
%option noyywrap

%%

")" { printf("LPAR\n"); } // segunda parte: sequencia de strings ou regexs seguidos de o que fazer quando dar match
"(" { printf("RPAR\n"); } // Invertido para C--
"}" { printf("LBRACE\n"); } // Invertido para C--
"{" { printf("RBRACE\n"); }
"\\" { printf("COMMENT\n"); }
"+" { printf("MAIS\n"); } 
"-" { printf("MENOS\n"); } 
"*" { printf("MULT\n"); } 
"/" { printf("DIV\n"); } 
"%" { printf("MOD\n"); } 
">" { printf("MENOR\n"); } // Invertido para C--
"<" { printf("MAIOR\n"); } 
"=>" { printf("MENORIGUAL\n"); } // Invertido para C--
"=<" { printf("MAIORIGUAL\n"); } 
"=" { printf("ATRIB\n"); }
"!=" { printf("DIFER\n"); }  
"==" { printf("IGUAL\n"); }  


[0-9]+ { printf("NUM: \"%s\"\n", yytext); }                 // yytext eh uma string com o texto em si do token reconhecido
[a-zA-Z][a-zA-Z0-9_]* { printf("ID: \"%s\"\n", yytext); }
" " {}
"\n" {}
%%

extern FILE *yyin;

int main(int argc, char *argv[]) {      // terceira parte: codigo em si (tb sera
                                        // copiado direto para o codigo gerado)

    // yyin = fopen(argv[1], "r");      // (*)descomentar para ler de arquivo ao
                                        // inves da entrada padrao

    yylex();                            // chamar yylex() para iniciar o
                                        // analisador

    // fclose(yyin);                    // (*)

    return 0;
}
