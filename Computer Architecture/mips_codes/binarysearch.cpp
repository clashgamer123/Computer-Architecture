#include<iostream>
using namespace std ;

int BinarySearch(int* A, int& n, int& val, int start, int end)
{
    if(start>end) { return -1 ; }
    int mid = (start + end)/2 ;
    if(A[mid] == val) { return mid ; }
    if(A[mid]>val)
    {
        end = mid - 1;
    }
    else
    {
        start = mid + 1;
    }
    return BinarySearch(A, n, val, start, end) ;
}

int main()
{ 
    int n = 10;
    int A[n] = {1, 2, 3, 4, 6, 12, 13, 15, 18, 21} ;
    int val ;
    cin>>val ;
    cout<<BinarySearch(A, n, val, 0, n-1) ;
    return 1; 
}