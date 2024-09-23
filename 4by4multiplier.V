// Module for multiplying two IEEE 754 floating-point numbers
module FloatingPointMultiplier_4x4(
  input [31:0] operand1,
  input [31:0] operand2,
  output reg [31:0] result
);

  // Internal registers for decomposed floating-point components
  reg [7:0] exponent1, exponent2;
  reg [22:0] mantissa1, mantissa2;
  reg sign1, sign2;
  reg [7:0] exponent_out;
  reg [47:0] mantissa_product; // 24*24 = 48 bits needed for the full precision product
  reg [22:0] mantissa_out;
  reg sign_out;
  reg [8:0] exponent_temp;  // Temporary exponent with an extra bit for overflow

  // Splitting the operands into sign, exponent, and mantissa
  assign sign1 = operand1[31];
  assign sign2 = operand2[31];
  assign exponent1 = operand1[30:23];
  assign exponent2 = operand2[30:23];
  assign mantissa1 = {1'b1, operand1[22:0]}; // Implicit leading one for normalized numbers
  assign mantissa2 = {1'b1, operand2[22:0]}; // Implicit leading one for normalized numbers

  // Calculate the sign of the output
  always @* begin
    sign_out = sign1 ^ sign2;
  end

  // Calculate the exponent of the output
  always @* begin
    // Check for zero exponents which represent zero or subnormal numbers
    if (exponent1 == 0 || exponent2 == 0) begin
      exponent_temp = 0; // Result is zero if either operand is zero
    end else begin
      exponent_temp = exponent1 + exponent2 - 127 + 1; // Add bias back for true exponent calculation
    end
  end

  // Multiply the mantissas
  always @* begin
    mantissa_product = mantissa1 * mantissa2; // 24-bit x 24-bit multiplication
    // Normalize the product (checking if the product has shifted beyond 24 bits)
    if (mantissa_product[47]) begin
      mantissa_out = mantissa_product[46:24];
      exponent_temp = exponent_temp + 1;
    end else begin
      mantissa_out = mantissa_product[45:23];
    end
  end

  // Pack the results into the IEEE 754 format
  always @* begin
    if (exponent_temp == 0) begin
      result = 0; // Return zero if resulting exponent is zero
    end else if (exponent_temp >= 255) begin
      // Overflow to infinity
      result = {sign_out, 8'hFF, 23'h0};
    end else if (exponent_temp <= 1) begin
      // Underflow to zero or handle subnormal numbers
      result = {sign_out, 8'h0, mantissa_out[22:0]};
    end else begin
      // Normalized number output
      result = {sign_out, exponent_temp[7:0], mantissa_out[22:0]};
    end
  end

endmodule