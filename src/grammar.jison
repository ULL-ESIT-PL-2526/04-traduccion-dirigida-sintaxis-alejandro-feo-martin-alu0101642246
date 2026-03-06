/* Lexer */
%lex
%%
\/\/.*						                       { /* skip comentarios una linea */; }
\s+                                                { /* skip whitespace */; }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?                { /* punto flotante */       return 'NUMBER';       }
"**"                                               { return 'opow';           }
[-+]                                             { return 'opad';           }
[*/]							{ return 'opmu'; }
<<EOF>>                                            { return 'EOF';          }
.                                                  { return 'INVALID';      }
/lex

/* Parser */
%start expressions
%token NUMBER
%%

expressions
    : e EOF
        { return $e; }
    ;

e
    : e opad t
        { $$ = operate($opad, $e, $t); }
    | t
        { $$ = $t; }
    ;

t
    : t opmu r   
        { $$ = operate($opmu, $t, $r); }
    | r   
        { $$ = $r; }
    ;

r
    : f opow r   
        { $$ = operate($opow, $f, $r); }
    | f   
        { $$ = $f; }
    ;

f
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
