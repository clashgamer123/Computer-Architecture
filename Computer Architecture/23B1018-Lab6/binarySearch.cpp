#include<iostream>

int binarySearch(int *A, int n, int start, int end, int val)
{
    if (start == end) { return -1 ; }

    int mid = (start + end)/2 ;
    if (A[mid] == val)
    {
        return mid ;
    }
    else if (A[mid] > val)
    {
        return binarySearch(A, n, start, mid, val) ;
    }
    else
    {
        return binarySearch(A, n, mid+1, end, val) ;
    }
}

int main()
{
    int A[10] = {1, 2, 3, 4, 6, 9, 11, 12, 14, 15} ;
    int val; 
    std :: cin>>val ;
    std :: cout<<binarySearch(A, 10, 0, 10, val) ;
    return 0;
}