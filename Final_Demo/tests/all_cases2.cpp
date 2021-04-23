#include<iostream>

using namespace std;

/* Note this is a comment to check the correctness of the comment removal code in Lex
   This comment spans multiple lines.
*/
// This is a single comment line.....

void my_function(int a)
{
    int my_fn = 10; //scope 1 
    cout << my_fn;
}

void my_function2(double a)
{
    double my_fn_2 = 10.23; //scope 2
}

float add(int b , int c) 
{
    return 5+4;
}

int main()
{
    // Lexer special cases (Errors)
    // Unterminating string
    // char x[] = "sadfjsdlkafjsdalf lskdjfsdlkdjfl

    // Unterminating character
    // char a = 'd

    // invalid character, continues parsing after detecting it
    // @
    // double b = 10.0;
    // float f = 3.14f;

    // invalid operators
    // int a = 10;
    // a+++;

    // invalid identifier names
    // int longnameidontknowwhattowritesimplyiamwritinghopeitsenough = 200;;

    // Array checking
    char abcdef[1000];
    char xyz[10] = "compiler";
    cout << xyz[8] << "\n";
    int arr[10] = {10,20,30,40,40,40};
    float arr_new[20];

    // Shorthand assignment operators
    s += 5;
    s -= 5;
    s /= 10;
    s *= 10;
    s %= 2;

    // Variable declaration check
    int a = 5;
    int b = 6;
    int c = a * b;
    int d = c+b;
    int e = a*b+d-b+a;
    int f = a*5 + 8-4 + 7*3 +d*e/1;
    int g = (4+5)*f+e-d/c+b;
    int k = c + 4;
    g = d+4;

    int sum = 0;
    // Simple for loop
    for(int i=0;i<10;i++)
    {
        sum = sum + 1;
    }

    // Double nested for loop
    for(int i=0;i<10;i++)
    {
        for(int j=i;j<10;j++)
        {
            sum = sum + 1;
        }
    }

    // Simple if condition
    if(a>b)
    {
        g = c + 4;
    }

    // Simple if condition
    if(sum==55)
    {
        int k = 2;
    }  

    // Multi-Nested if-else
    if(a+b==c)
    {
        if(b+c>=f)
        {
            k =2;
        }
        else
        {
            if(a-b>0)
            {
                k = 5;
            }
            else
            {
                k = 4;
            }
            g = 3;
        }
        b = g + 1;
        e = f - 1;
    }
    else if(b+c==d)
    {
        a = g - 1;
        b = f*2;
    }
    else
    {
        a = g-2;
    }

    int x = 5;
    x+=6;
    x-=a;

    int mx = 4+5-3;
    mx = -mx;
    mx = +5;

    // constant expression as if condition
    if(1+2)
        k = 1;

    // if-else inside a for loop
    for(int j=1;j<10;j++)
    {
        if(a+b>c)
        {
            k = 1+2;
        }
        if(1)
            x = 1;
        else
            x = -1;
    }

    // Different type of if condition
    if((a+b>x)&&(c+d>b))
    {
        a =100; 
    }

    // Nested for with if inside
    for(int q=10;q>0;--q)
    {
        for(int p=0;p<5;++p)
        {
            sum+=p+q;
            if(p+q>10)
            {
                a = a - 1;
            }
        }
    }

    // Simple if construct
    if(a)
    {
        a =20;
    }

    if((a+b>c))
    {
        for(int z=0;z<6;z=z+5)
        {
            if(z)
            {
                a-=1;
            }
            else
                a+=1;
        }
    }

    // Special cases of for loops
    for(;a>10;)
    {
        a -=1;
    }

    for(;;)
    {
        sum-=1;
    }

    for(a=0;;a+=1)
    {
        sum+=1;
    }
}