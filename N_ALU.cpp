#include <iostream> 

#include <array> 

 

using namespace std; 

 

const int SIZE = 4; // Matrix size is 4x4 

 

// Function to perform matrix multiplication 

void matrix_multiplication(const array<array<float, SIZE>, SIZE>& A,  

                           const array<array<float, SIZE>, SIZE>& B,  

                           array<array<float, SIZE>, SIZE>& C) { 

    for (int i = 0; i < SIZE; i++) { 

        for (int j = 0; j < SIZE; j++) { 

            C[i][j] = 0; 

            for (int k = 0; k < SIZE; k++) { 

                C[i][j] += A[i][k] * B[k][j]; 

            } 

        } 

    } 

} 

 

// Function to perform scalar multiplication 

void scalar_multiplication(const array<array<float, SIZE>, SIZE>& A,  

                           float alpha,  

                           array<array<float, SIZE>, SIZE>& C) { 

    for (int i = 0; i < SIZE; i++) { 

        for (int j = 0; j < SIZE; j++) { 

            C[i][j] = A[i][j] * alpha; 

        } 

    } 

} 

 

// Function to perform scalar division 

void scalar_division(const array<array<float, SIZE>, SIZE>& A,  

                     float alpha,  

                     array<array<float, SIZE>, SIZE>& C) { 

    for (int i = 0; i < SIZE; i++) { 

        for (int j = 0; j < SIZE; j++) { 

            C[i][j] = A[i][j] / alpha; 

        } 

    } 

} 

 

// Function to perform matrix transpose 

void matrix_transpose(const array<array<float, SIZE>, SIZE>& A,  

                      array<array<float, SIZE>, SIZE>& C) { 

    for (int i = 0; i < SIZE; i++) { 

        for (int j = 0; j < SIZE; j++) { 

            C[j][i] = A[i][j]; 

        } 

    } 

} 

 

// Helper function to get submatrix (for determinant calculation) 

void get_submatrix(const array<array<float, SIZE>, SIZE>& A,  

                   int row, int col,  

                   array<array<float, SIZE-1>, SIZE-1>& submatrix) { 

    int sub_i = 0; 

    for (int i = 0; i < SIZE; i++) { 

        if (i == row) continue; 

        int sub_j = 0; 

        for (int j = 0; j < SIZE; j++) { 

            if (j == col) continue; 

            submatrix[sub_i][sub_j] = A[i][j]; 

            sub_j++; 

        } 

        sub_i++; 

    } 

} 

 

// Recursive function to calculate the determinant of a matrix 

float matrix_determinant_recursive(const array<array<float, SIZE-1>, SIZE-1>& A) { 

    float det = 0; 

    if (SIZE-1 == 1) { 

        return A[0][0]; 

    } else { 

        for (int j = 0; j < SIZE-1; j++) { 

            array<array<float, SIZE-2>, SIZE-2> submatrix; 

            get_submatrix(A, 0, j, submatrix); 

            det += ((j % 2 == 0 ? 1 : -1) * A[0][j] * matrix_determinant_recursive(submatrix)); 

        } 

    } 

    return det; 

} 

 

// Function to calculate the determinant of a matrix 

float matrix_determinant(const array<array<float, SIZE>, SIZE>& A) { 

    float det = 0; 

    for (int j = 0; j < SIZE; j++) { 

        array<array<float, SIZE-1>, SIZE-1> submatrix; 

        get_submatrix(A, 0, j, submatrix); 

        det += ((j % 2 == 0 ? 1 : -1) * A[0][j] * matrix_determinant_recursive(submatrix)); 

    } 

    return det; 

} 

 

// Function to calculate the trace of a matrix 

float matrix_trace(const array<array<float, SIZE>, SIZE>& A) { 

    float trace = 0; 

    for (int i = 0; i < SIZE; i++) { 

        trace += A[i][i]; 

    } 

    return trace; 

} 

 

// N_ALU operation selector 

void N_ALU(int op_sel, const array<array<float, SIZE>, SIZE>& A,  

           const array<array<float, SIZE>, SIZE>& B, float alpha,  

           array<array<float, SIZE>, SIZE>& C, float& result_scalar) { 

    switch(op_sel) { 

        case 0: // Matrix Multiplication 

            matrix_multiplication(A, B, C); 

            break; 

        case 1: // Scalar Multiplication 

            scalar_multiplication(A, alpha, C); 

            break; 

        case 2: // Scalar Division 

            scalar_division(A, alpha, C); 

            break; 

        case 3: // Matrix Transpose 

            matrix_transpose(A, C); 

            break; 

        case 4: // Matrix Determinant 

            result_scalar = matrix_determinant(A); 

            break; 

        case 5: // Trace of a Matrix 

            result_scalar = matrix_trace(A); 

            break; 

        default: // Default Case 

            for (int i = 0; i < SIZE; i++) { 

                for (int j = 0; j < SIZE; j++) { 

                    C[i][j] = 0; 

                } 

            } 

            result_scalar = 0; 

            break; 

    } 

} 

 

int main() { 

    // Example matrices and scalar 

    array<array<float, SIZE>, SIZE> A = {{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 14, 15, 16}}}; 

    array<array<float, SIZE>, SIZE> B = {{{16, 15, 14, 13}, {12, 11, 10, 9}, {8, 7, 6, 5}, {4, 3, 2, 1}}}; 

    array<array<float, SIZE>, SIZE> C = {}; 

    float alpha = 2.5; 

    float result_scalar = 0; 

     

    // Test N_ALU operation (for example, matrix multiplication) 

    N_ALU(0, A, B, alpha, C, result_scalar); 

     

    // Print the result matrix 

    cout << "Result Matrix C: " << endl; 

    for (int i = 0; i < SIZE; i++) { 

        for (int j = 0; j < SIZE; j++) { 

            cout << C[i][j] << " "; 

        } 

        cout << endl; 

    } 

 

    return 0; 

} 