module N_ALU( 

    input clk, 

    input reset, 

    input [2:0] op_sel, 

    input [31:0] A [3:0][3:0], // IEEE 754 single-precision floating-point matrix 

    input [31:0] B [3:0][3:0], // IEEE 754 single-precision floating-point matrix 

    input [31:0] alpha,        // IEEE 754 single-precision floating-point scalar 

    output reg [31:0] C [3:0][3:0], // IEEE 754 single-precision floating-point matrix 

    output reg [31:0] result_scalar  // IEEE 754 single-precision floating-point scalar 

); 

  

// Internal variables 

reg [31:0] temp_C [3:0][3:0]; 

reg [31:0] temp_scalar; 

integer i, j, k; 

  

always @(posedge clk or posedge reset) begin 

    if (reset) begin 

        for (i = 0; i < 4; i = i + 1) begin 

            for (j = 0; j < 4; j = j + 1) begin 

                temp_C[i][j] <= 32'b0; 

            end 

        end 

        temp_scalar <= 32'b0; 

    end else begin 

        case (op_sel) 

            3'b000: begin // Matrix Multiplication 

                matrix_multiplication(A, B, temp_C); 

            end 

            3'b001: begin // Scalar Multiplication 

                scalar_multiplication(A, alpha, temp_C); 

            end 

            3'b010: begin // Scalar Division 

                scalar_division(A, alpha, temp_C); 

            end 

            3'b011: begin // Matrix Transpose 

                matrix_transpose(A, temp_C); 

            end 

            3'b100: begin // Matrix Determinant 

                temp_scalar <= matrix_determinant(A); 

            end 

            3'b101: begin // Trace of a Matrix 

                temp_scalar <= matrix_trace(A); 

            end 

            default: begin 

                for (i = 0; i < 4; i = i + 1) begin 

                    for (j = 0; j < 4; j = j + 1) begin 

                        temp_C[i][j] <= 32'b0; 

                    end 

                end 

                temp_scalar <= 32'b0; 

            end 

        endcase 

    end 

end 

  

assign C = temp_C; 

assign result_scalar = temp_scalar; 

  

// Task for Matrix Multiplication 

task matrix_multiplication; 

    input [31:0] A [3:0][3:0]; 

    input [31:0] B [3:0][3:0]; 

    output [31:0] C [3:0][3:0]; 

    reg [31:0] sum; 

    integer i, j, k; 

    begin 

        for (i = 0; i < 4; i = i + 1) begin 

            for (j = 0; j < 4; j = j + 1) begin 

                sum = 32'b0; 

                for (k = 0; k < 4; k = k + 1) begin 

                    sum = sum + A[i][k] * B[k][j]; 

                end 

                C[i][j] = sum; 

            end 

        end 

    end 

endtask 

  

// Task for Scalar Multiplication 

task scalar_multiplication; 

    input [31:0] A [3:0][3:0]; 

    input [31:0] alpha; 

    output [31:0] C [3:0][3:0]; 

    integer i, j; 

    begin 

        for (i = 0; i < 4; i = i + 1) begin 

            for (j = 0; j < 4; j = j + 1) begin 

                C[i][j] = A[i][j] * alpha; 

            end 

        end 

    end 

endtask 

  

// Task for Scalar Division 

task scalar_division; 

    input [31:0] A [3:0][3:0]; 

    input [31:0] alpha; 

    output [31:0] C [3:0][3:0]; 

    integer i, j; 

    begin 

        for (i = 0; i < 4; i = i + 1) begin 

            for (j = 0; j < 4; j = j + 1) begin 

                C[i][j] = A[i][j] / alpha; 

            end 

        end 

    end 

endtask 

  

// Task for Matrix Transpose 

task matrix_transpose; 

    input [31:0] A [3:0][3:0]; 

    output [31:0] C [3:0][3:0]; 

    integer i, j; 

    begin 

        for (i = 0; i < 4; i = i + 1) begin 

            for (j = 0; j < 4; j = j + 1) begin 

                C[j][i] = A[i][j]; 

            end 

        end 

    end 

endtask 

  

// Function for Matrix Determinant 

function [31:0] matrix_determinant; 

    input [31:0] A [3:0][3:0]; 

    reg [31:0] det; 

    reg [31:0] submatrix [2:0][2:0]; 

    integer j; 

    begin 

        det = 32'b0; 

        for (j = 0; j < 4; j = j + 1) begin 

            get_submatrix(A, 0, j, submatrix); 

            det = det + ((-1)  j) * A[0][j] * matrix_determinant_recursive(submatrix); 

        end 

        matrix_determinant = det; 

    end 

endfunction 

  

// Helper Function for Recursive Determinant Calculation 

function [31:0] matrix_determinant_recursive; 

    input [31:0] A [2:0][2:0]; 

    reg [31:0] det; 

    reg [31:0] submatrix [1:0][1:0]; 

    integer j; 

    begin 

        if ($bits(A) == 32) begin // Base case for 1x1 matrix 

            matrix_determinant_recursive = A[0][0]; 

        end else begin 

            det = 32'b0; 

            for (j = 0; j < 3; j = j + 1) begin 

                get_submatrix(A, 0, j, submatrix); 

                det = det + ((-1)  j) * A[0][j] * matrix_determinant_recursive(submatrix); 

            end 

            matrix_determinant_recursive = det; 

        end 

    end 

endfunction 

  

// Task to Get Submatrix for Determinant Calculation 

task get_submatrix; 

    input [31:0] A [3:0][3:0]; 

    input integer row, col; 

    output [31:0] submatrix [2:0][2:0]; 

    integer i, j, sub_i, sub_j; 

    begin 

        sub_i = 0; 

        for (i = 0; i < 4; i = i + 1) begin 

            if (i != row) begin 

                sub_j = 0; 

                for (j = 0; j < 4; j = j + 1) begin 

                    if (j != col) begin 

                        submatrix[sub_i][sub_j] = A[i][j]; 

                        sub_j = sub_j + 1; 

                    end 

                end 

                sub_i = sub_i + 1; 

            end 

        end 

    end 

endtask 

  

// Function for Trace of a Matrix 

function [31:0] matrix_trace; 

    input [31:0] A [3:0][3:0]; 

    reg [31:0] trace; 

    integer i; 

    begin 

        trace = 32'b0; 

        for (i = 0; i < 4; i = i + 1) begin 

            trace = trace + A[i][i]; 

        end 

        matrix_trace = trace; 

    end 

endfunction 

  

endmodule 