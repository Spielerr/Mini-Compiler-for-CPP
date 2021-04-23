#include <stdio.h>

int main()
{
    int a = 0;
    double b = 1.5;
    int sum;
    if(b)
    {
        sum = 0;
        for(int i = 0;i<2;i++)
        {
            sum = sum + b;
        }
        if(sum > 3)
        {
            sum  = 10;
        }
        else
        {
            sum = 0;
        }
    }
    int result = sum;
}