// Module for floating-point multiplication
module mul(
    input [31:0] flp_a, flp_b,  // 32-bit floating-point inputs
    output sign,                // Output sign of the result
    output [7:0] exponent,      // Output exponent of the result
    output [7:0] exp_unbiased,  // Output unbiased exponent
    output [8:0] exp_sum,       // Sum of biased exponents
    output [22:0] prod,         // Output product of mantissas
    output [31:0] sum           // Final 32-bit floating-point result
);

// Internal registers for signs and exponents of inputs
reg sign_a, sign_b;
reg [7:0] exp_a, exp_b;
reg [7:0] exp_a_bias, exp_b_bias;

// Register for sum of biased exponents
reg [8:0] exp_sum;

// Registers for mantissas and product
reg [22:0] fract_a, fract_b;
reg [45:0] prod_dbl;
reg [22:0] prod;

// Register for final computed sign, exponent, and sum (result)
reg sign;
reg [31:0] sum;
reg [7:0] exponent, exp_unbiased;

// Compute sign, exponent, and fraction from inputs
always @(flp_a or flp_b) begin
    sign_a = flp_a[31];  // Extract sign from flp_a
    sign_b = flp_b[31];  // Extract sign from flp_b
    exp_a = flp_a[30:23];  // Extract exponent from flp_a
    exp_b = flp_b[30:23];  // Extract exponent from flp_b
    fract_a = flp_a[22:0];  // Extract mantissa from flp_a
    fract_b = flp_b[22:0];  // Extract mantissa from flp_b

    // Bias the exponents by adding 127 (0x7F)
    exp_a_bias = exp_a + 8'b0111_1111;
    exp_b_bias = exp_b + 8'b0111_1111;

    // Add biased exponents
    exp_sum = exp_a_bias + exp_b_bias;

    // Compute the true exponent by subtracting one bias (127)
    exponent = exp_sum - 8'b0111_1111;

    // Further adjust exponent by subtracting another 127 to normalize
    exp_unbiased = exponent - 8'b0111_1111;

    // Multiply mantissas (considered normalized to 1.m)
    prod_dbl = fract_a * fract_b;

    // Normalize the product: adjust until the most significant bit is 1
    while (prod[22] == 0) begin
        prod = prod << 1;
        exp_unbiased = exp_unbiased - 1;
    end

    // Compute the sign of the result (XOR of the input signs)
    sign = sign_a ^ sign_b;

    // Construct the final result if the product is not zero
    if (prod != 0) begin
        sum = {sign, exp_unbiased, prod};
    end else begin
        sum = 32'b0;  // Set result to zero if product is zero
    end
end

endmodule
//This Verilog module reads the inputs flp_a and flp_b, which are 32-bit floating-point numbers, performs multiplication, and outputs the result in IEEE 754 format. It includes handling for sign determination, exponent adjustment, and mantissa multiplication, along with normalization of the product.