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
    // int sum = 0;
    // for(int i=0;i<10;i++)
    // {
    //     sum = sum + 1;
    // }
    int sum = 0;
    for(int i=0;i<10;i++)
    {
        for(int j=0;j<5;++j)
        {
            if(i<j)
            {
                if(j>i)
                {
                    sum = sum + 1;
                }
                int k = 2;
            }
            int x = 3;
        }
    }
    if(sum>55)
    {
        for(int z=0;z<2;z=z+1)
        {
            if(z<1)
            {
                int r = z+sum;
            }
            if(z>1)
            {
                int q=4;
            }
            sum = 66;
        }
        sum = 0;
    }
    if(a>b)
    {
        g = c + 4;
    }
    if(sum==55)
    {
        int k = 2;
    }

    if(a+b==c)
    {
        if(b>a)
        {
            if(c>a)
            {
                b = g + 1;
                e = f - 1;
            }
        }
     
    }
}
