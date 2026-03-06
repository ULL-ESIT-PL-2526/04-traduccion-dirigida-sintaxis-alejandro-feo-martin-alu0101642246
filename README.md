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


# Práctica 5: Traducción dirigida por la sintaxis: gramática

4.0-2.0*3.0
2**3**2
7-4/2

Derivación: 
E => E op T => E op T op T => T op T op T =>* 4.0 - 2.0 * 3
E => E op T => E op T op T => T op T op T =>* 2 ** 3 ** 2
E => E op T => E op T op T => T op T op T =>* 7 - 4 / 2

El árbol para todos es común, solo cambia OP1 y OP2, donde OP1 es el primero que aparece y el otro el segundo; y n es cada número :
        E              OP2     T
  E   OP1     T                n  
  T           n
  n
  
Como podemos ver, no respeta el orden de predecencia, porque opera de izquierda a derecha independientemente del operando.


## 1.4 Tests fallan:
```
 PASS  __tests__/parser.test.js

Test Suites: 1 failed, 1 passed, 2 total
Tests:       18 passed, 18 total
Snapshots:   0 total
Time:        0.664 s, estimated 1 s
Ran all test suites.
```

# 2 Gramatica modificada:

```
/* Lexer */
%lex
%%
\/\/.*                                                                 { /* skip comentarios una linea */; }
\s+                                                { /* skip whitespace */; }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?                { /* punto flotante */       return 'NUMBER';       }
"**"                                               { return 'opow';           }
[-+]                                             { return 'opad';           }
[*/]                                                    { return 'opmu'; }
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
    
```

## Tests para punto flotante (mezclados con los anteriores):
```
describe('Parser Passing Tests', () => {
test('should handle multiplication and division before addition and subtraction', () => {
expect(parse("2.0 + 3.0 * 4")).toBe(14); // 2 + (3 * 4) = 14
expect(parse("10 - 6 / 2")).toBe(7); // 10 - (6 / 2) = 7
expect(parse("5 * 2.0 + 3")).toBe(13); // (5 * 2) + 3 = 13
expect(parse("20 / 4 - 2")).toBe(3); // (20 / 4) - 2 = 3
});
test('should handle exponentiation with highest precedence', () => {
expect(parse("2 + 3 ** 2")).toBe(11); // 2 + (3 ** 2) = 11
expect(parse("2.0 * 3.0 ** 2.0")).toBe(18); // 2 * (3 ** 2) = 18
expect(parse("10 - 2 ** 3")).toBe(2); // 10 - (2 ** 3) = 2
});
test('should handle right associativity for exponentiation', () => {
expect(parse("2.0 ** 3 ** 2")).toBe(512); // 2 ** (3 ** 2) = 2 ** 9 = 512
expect(parse("3 ** 2.0 ** 2")).toBe(81); // 3 ** (2 ** 2) = 3 ** 4 = 81
});
test('should handle mixed operations with correct precedence', () => {
expect(parse("1 + 2 * 3 - 4")).toBe(3); // 1 + (2 * 3) - 4 = 3
expect(parse("15 / 3.0 + 2 * 4")).toBe(13); // (15 / 3) + (2 * 4) = 13
expect(parse("10 - 3 * 2 + 1")).toBe(5); // 10 - (3 * 2) + 1 = 5
});
test('should handle expressions with exponentiation precedence', () => {
expect(parse("2 ** 3.0 + 1")).toBe(9); // (2 ** 3) + 1 = 9
expect(parse("3 + 2 ** 4")).toBe(19); // 3 + (2 ** 4) = 19
expect(parse("2 * 3 ** 2 + 1")).toBe(19); // 2 * (3 ** 2) + 1 = 19
});
test('should handle various realistic calculations with correct precedence', () => {
expect(parse("1 + 2 * 3")).toBe(7); // 1 + (2 * 3) = 7
expect(parse("6 / 2.0 + 4")).toBe(7); // (6 / 2) + 4 = 7
expect(parse("2 ** 2 + 1")).toBe(5); // (2 ** 2) + 1 = 5
expect(parse("10 / 2 / 5")).toBe(1); // (10 / 2) / 5 = 1
expect(parse("100 - 50.0 + 25")).toBe(75); // (100 - 50) + 25 = 75
expect(parse("2 * 3 + 4 * 5")).toBe(26); // (2 * 3) + (4 * 5) = 26
});
});
```

## Gramatica modificada ()
```
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
"("                                               { return 'open';           }
")"                                               { return 'close';           }
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

    | open e close
	{ $$ = $e;  }
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
```

## Test ejemplo ()
```
test('reconoce parentesis', () => {
expect(parse("2.0 + (3.0 * 4)")).toBe(14); // 2 + (3 * 4) = 14
expect(parse("10 - (6 / 2)")).toBe(7); // 10 - (6 / 2) = 7
expect(parse("(5 * 2.0= + 3")).toBe(13); // (5 * 2) + 3 = 13
expect(parse("(20 / 4) - 2")).toBe(3); // (20 / 4) - 2 = 3
});
```
