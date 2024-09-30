#include<iostream>
using namespace std;

struct complex
{
    int re;
    int im;
}

int isLessThan(complex e1, complex e2)
{
    if(e1.re<e2.re)
    {
        return 1;
    }
    else if(e1.re == e2.re && e1.im<e2.im)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

int numLessThan(complex elt, complex*A, int start, int end)
{
    int count = 0;
    for (int i = start; i<end; i++)
    {
        if(isLessThan(A[i], elt)) { count++ ; }
    }
    return count ;
}

int main()
{
    A = 
    complex x;
    cin>>x.re ;
    cin>>x.im ;
    cout<<numLessThan(x, A, 0, n)
}