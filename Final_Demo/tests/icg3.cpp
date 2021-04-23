#include <stdio.h>

int main()
{
    int sum = 0;
    for(int i = 0;i < 3;i++)
    {
        sum += i;
    }
    int result = sum;
    sum *= 2;
    int new_result = sum;
}