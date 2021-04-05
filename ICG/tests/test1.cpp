#include<iostream>

using namespace std;

/* Note this is a comment to check the correctness of the comment removal code in Lex
   This comment spans multiple lines.
*/
// This is a single comment line.....

int main()
{
    // Variable declaration check
    int a = 5 & 6;
    int b;
    int c,d,e,f=5 + 6;
    int x = 25;
    int p = 40,q=30;
    float m,n=3.1415f;
    double exp = 10.3411e2;
    a = 5;

    char abcdef[1000];
    char xyz[10] = "compiler";
    cout << xyz[8] << "\n";
    bool boo = true;
    
    // // Array Check
    int arr[10] = {10,20,30,40,40,40};
    float arr_new[20];

    cout << "Compiler Design Phase\n";
    int s;
    cin >> s;

    // Assignment operators
    s += 5;
    s -= 5;
    s /= 10;
    s *= 10;
    s %= 2;
}
