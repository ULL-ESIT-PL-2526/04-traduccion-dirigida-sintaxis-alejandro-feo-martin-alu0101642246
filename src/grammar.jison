/* Lexer */
%lex
%%
\/\/.*						   { /* skip comentarios una linea */; }
\s+                                                { /* skip whitespace */; }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?                { /* punto flotante */       return 'NUMBER';       }
"**"                                               { return 'OP';           }
[-+*/]                                             { return 'OP';           }
<<EOF>>                                            { return 'EOF';          }
.                                                  { return 'INVALID';      }
/lex

/* Parser */
%start expressions
%token NUMBER
%%

expressions
    : expression EOF
        { return $expression; }
    ;

expression
    : expression OP term
        { $$ = operate($OP, $expression, $term); }
    | term
        { $$ = $term; }
    ;

term
    : NUMBER
        { $$ = Number(yytext); }
    ;
%%

function operate(op, left, right) {
    switch (op) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': return left / right;
        case '**': return Math.pow(left, right);
    }
}
