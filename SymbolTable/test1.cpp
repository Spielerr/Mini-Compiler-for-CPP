#include<iostream>

using namespace std;

int x();
int y(int a, float b);
int z(int, float);
int t(int a = 5 + 3, int b = 5, int c);

float add(int a = 5 + 3, int b = 5, int c) {
    int a = 5;
    int c = 5;
    b = 6 + 5;
    return 5 + 4 == a;
}

void main() {

    int a = 5;
    int b = 4;
    int c, d, e = 5, f;
    if ( (a = b + c) + 5 + 4 + ( 3  - 4 ) )
        cout << b;
    else { cout << c; }
    for(int i = 0; i == 5; i = i + 1) {
        cout << 5;
    }
    for(;;)
    {
        if(a==0)
        {
            a = a - 1;
        }
    }
    for(;a==0;a = a - 1 )
        if (a == 5)
            for(;a==0;a = a - 1)
                cout << 5 + (5 +(6 + 4) );
    int e;
    cout << a << b == c;
    if ( (5 + 3) ) { cout << a; }
    int a = 6, b = 4, c = 6;
    cout << (a = b == c) << endl;
}
