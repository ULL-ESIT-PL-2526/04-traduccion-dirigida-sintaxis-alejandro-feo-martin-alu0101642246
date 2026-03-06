# Practica 4: Traducción dirigida por sintaxis

# Ejercicio 3:

1. Para que siga analizando y no devuelva nada al encontrar el espacio.
2. NUMBER OP NUMBER OP INVALID
3. Para que no se confunda con el operador *, que tiene un solo caracter.
4. Cuando hay un EOF
5. Para cualquier otro número


## Nuevo código
```
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
```


## Nuevas pruebas:
```
  describe('Flotantes y comentarios una linea', () => {
  test('should parse float numbers and comments', () => {
    expect(parse("2.35e-3")).toBe(0.00235);
    expect(parse("2.35e+3")).toBe(2350);
    expect(parse("2.35E-3")).toBe(0.00235);
    expect(parse("2.35")).toBe(2.35);
    expect(parse("23")).toBe(23);
    expect(parse("// Hola \n 23")).toBe(23);
  });

```


