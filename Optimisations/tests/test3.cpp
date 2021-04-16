#include<iostream>

using namespace std;

void my_function(int a)
{
    cout << "my function\n"; //scope 1 
}

void my_function2(double a)
{
    double b = 10.23; //scope 2
}

float add(int b , int c) 
{
    // scope 3
    // int a = 5 + 6723876 + c;
    // int c = 5;
    // b = 6 + 5;
    // return 5 + 4*a;
    return 5+4;
}

int main()
{
    // scope 4
    int a = 10;
    for(int i=0;i<10;i++)
    {
        for(;;)
        {
            cout<<"for test";
        }
    }


   
    
    int f;
    for(;f>0;--f)
        cout<<a<<"\t";
    cout<<"\n";


    for(int qwe=0;qwe<5;++qwe)
    {
        // else
        //     cout<<"qwe is even\n";
        if(qwe+2==5)
            a = 20;
    }
}