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
}
//List of things that doesn't work:
// if(1)
// if(a)

//if else
// t21 = a + b
// t22 = t21 == c  
// if t22 goto L0      
// goto L1
// L0:
// t23 = g + 1
// b = t23
// t24 = f - 1
// e = t24
// goto L2
// L1:
// t25 = g - 2
// a = t25
// L2:

// //if:
// if t22 goto L0
// goto L1
// L0:
// t23 = g + 1
// b = t23
// t24 = f - 1
// e = t24
// goto L2
// L2:
// L1:

// //now - if else
// t21 = a + b
// t22 = t21 == c  
// if t22 goto L0      
// goto L1
// L0:
// t23 = g + 1
// b = t23
// t24 = f - 1
// e = t24
// goto L2 -> after ifthis can be done
// L1: -> after if
// t25 = g - 2
// a = t25
// L2: -> block construct grammar



// //now - if only
// t21 = a + b
// t22 = t21 == c  
// if t22 goto L0      
// goto L1
// L0:
// t23 = g + 1
// b = t23
// t24 = f - 1
// e = t24
// goto L2 -> after ifthis can be done
// L1: -> after if
// L2: -> block construct grammar