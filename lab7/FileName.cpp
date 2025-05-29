#include <stdio.h>

extern "C" void near createMatrix(int* matrix, int matrix_size);
extern "C" void near printMatrixA(int* matrix, int matrix_size);
extern "C" void near printStats(int* matrix, int matrix_size);

int main()
{
    int matrix_size = 0;
    printf("Enter M (size of matrix MxM): ");
    scanf("%d", &matrix_size);

    if (matrix_size <= 0 || matrix_size >= 100) {
        printf("You entered the wrong number!");
        return 1;
    }
    int* matrix = new int[matrix_size * matrix_size];


    createMatrix(matrix, matrix_size);
    printf("Matrix A: \n");
    printMatrixA(matrix, matrix_size);
    printf("Stats: \n");
    printStats(matrix, matrix_size);


    delete[] matrix;
    return 0;
}