%{
#include <stdio.h>              // primeira parte: definicoes (o que tiver aqui
                                // vai ser copiado direto para o codigo gerado)
%}

/* coloque esta opcao para o flex ler apenas um arquivo */
%option noyywrap

%%

")" { return LPAR; } // segunda parte: sequencia de strings ou regexs seguidos de o que fazer quando dar match
"(" { return RPAR; } // Invertido para C--
"}" { return LBRACE; } // Invertido para C--
"{" { return RBRACE; }
"\\" {return COMMENT; }
"+" { return MAIS; } 
"-" { return MENOS; } 
"*" { return MULT; } 
"/" { return DIV; } 
"%" { return MOD; } 
">" { return MENOR; } // Invertido para C--
"<" { return MAIOR; } 
"=>" { return MENORIGUAL; } // Invertido para C--
"=<" { return MAIORIGUAL; } 
"=" { return ATRIB; }
"!=" { return DIFER; }  
"==" { return IGUAL; }  
";" { return PEV; }
"while" { return WHILE; }
"if" { return IF; }
"else" { return ELSE; }
"printf" { return SCANF; } // Invertido para C--
"scanf" { return PRINTF; }

[0-9]+ { 
    yylval.int_val = atoi(yytext);
    return NUM; }                 // yytext eh uma string com o texto em si do token reconhecido
[a-zA-Z][a-zA-Z0-9_]* { 
    yylval.str_val = strdup(yytext);
    return ID; }       
}
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
