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
    a = 5;
    char abcdef[1000];
    char xyz[10] = "compiler";
    bool boo = true;
    //
    // // Array Check
    int arr[10] = {10,20,30,40,40,40};
    float arr_new[20];
    //
    // // Construct if check
    // //Nested if check
    if(true)
    {
        if(1)
        {
            if(c==d)
            {
                if(c!=d)
                {
                    int a = 200;
                }
            }
        }
    }
    if((a==b)&&(b==c)&&(d>=f)&&(p<q)||(boo))
    {
        cout<<"checking if multiple condiitons in if block works\n";
    }
    int sbdgjbsdjf;
    int xjhbfgjhbdfvzsdkf = 7823678263;
    // If else test
    if(m)
    {
        if(m==n)
        {
            cout<<"if else test\n";
        }
        else
            c=a+b;
    }
    else
        p = q*f;

    //For loop test:
    for(int i=0;i<10;i++)
    {
        for(;;)
        {
            cout<<"for test";
        }
    }
    for(;f>0;--f)
        cout<<f<<"\t";
    cout<<"\n";

    for(int qwe=0;qwe<5;++qwe)
    {
        if(qwe%2!=0)
            cout<<"qwe is odd\n";
        else
            cout<<"qwe is even\n";
        if(qwe+2==5)
            a = 20;
    }
}
