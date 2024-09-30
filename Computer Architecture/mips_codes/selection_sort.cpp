#include<iostream>
using namespace std;

void swap(int& a, int& b)
{
    int temp = a;
    a = b;
    b = temp;
    return ;
}

void SelectionSort(int* A, int n)
{
    for(int i = 0; i<n; i++)
    {
        int m = i;
        for(int j = i+1; j<n; j++)
        {
            if(A[j]<A[m]) { m = j ; }
        }
        swap(A[i], A[m]) ;
    }
    return ;
}

int main()
{
    int n = 10;
    int A[n] = {2, 6, 1, 5, 8, 11, 21, 14, 13, 29} ;
    SelectionSort(A, n) ;
    for(int i = 0; i<10; i++)
    {
        cout<<A[i]<<" " ;
    }
    cout<<'\n' ;
    return 0;
}