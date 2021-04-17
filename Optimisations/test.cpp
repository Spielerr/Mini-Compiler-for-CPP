#include <stdio.h>

int main()
{
    // Constant folding
    // int a = 1+2+3+4;
    // int b = 10+20/10;
    // int ab = a + b + 10;
    // Algebraic identities
    // int c = a + 0;
    // int d = a * 1;
    // bool e = true && a;
    // int f = 0/a;


    // Constant Propagation
    // int a = 10;
    // int b = 20;
    // int c = a + b + 30;
    // a = 100;
    // c = a + b + 200;


    // Common Subexpression elimination
    // 1
    // int a = 4 + 5;
    // int b = a + 5;
    // int z = a/5;
    // int c = 4 + 5;
    // int d = c * c;
    // d = c+5;
    // int e = d + d;

    // 2
    // int a = 10;
    // int b = a + 1;
    // int temp = 10 + 20;
    // int c = a + 1;
    // temp = c;

    // 3
    // int a = 10;
    // int b = a + 1;
    // a = 20;
    // int c = a + 1;


    // Strength Reduction
    // int a = 4;
    // int b = a * 8;
    // int c = 11 / 8;
    // int d = 5 / 16;
}