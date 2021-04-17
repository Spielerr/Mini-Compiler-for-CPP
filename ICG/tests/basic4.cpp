#include<iostream>

using namespace std;

/* Note this is a comment to check the correctness of the comment removal code in Lex
   This comment spans multiple lines.
*/
// This is a single comment line.....

int main()
{
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
    for(int i=0;i<10;i++)
    {
        sum = sum + 1;
    }
    for(int i=0;i<10;i++)
    {
        for(int j=i;j<10;j++)
        {
            sum = sum + 1;
        }
    }
    if(a>b)
    {
        g = c + 4;
    }
    if(sum==55)
    {
        int k = 2;
    }
    // cout<<"hello\n";    
    if(a+b==c)
    {
        // cout<<"im here\n";
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

    if(1+2)
        k = 1;

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
    if((a+b>x)&&(c+d>b))
    {
        a =100; 
    }
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
    // for(;;)
    // {
    //     sum +=1;
    // }
}