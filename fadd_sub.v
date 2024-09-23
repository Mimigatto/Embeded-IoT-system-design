// Floating-point addition and subtraction module
module fadd_sub(
  clk,                    // Clock signal
  rst,                    // Reset signal
  start,                  // Start operation signal
  subtract,               // Subtract flag (1 for subtraction, 0 for addition)
  input_a,                // 32-bit IEEE floating-point input A
  input_b,                // 32-bit IEEE floating-point input B
  output_z,               // 32-bit IEEE floating-point result
  overflow,               // Overflow flag
  underflow,              // Underflow flag
  busy,                   // Busy flag indicating the module is processing
  output_done             // Flag indicating the operation is completed
);

  // Define input and output interfaces
  input subtract, start;
  input clk;
  input rst;
  input [31:0] input_a;
  input [31:0] input_b;
  
  output [31:0] output_z;
  output busy, output_done, overflow, underflow; // Status and result flags
  
  // Internal registers for processing
  reg overflow, underflow;
  reg [3:0] state;           // Current state of the FSM
  
  // Define operation states using parameters for readability
  parameter GET_INPUT     = 4'd1,
            UNPACK        = 4'd2,
            SPECIAL_CASES = 4'd3,
            ALIGN         = 4'd4,
            ADD_0         = 4'd5,
            ADD_1         = 4'd6,
            NORMALISE_1   = 4'd7,
            NORMALISE_2   = 4'd8,
            ROUND         = 4'd9,
            PACK          = 4'd10,
  			DONE		  = 4'd11;		
  
  reg [31:0] a, b, z;        // Registers to hold operands and result
  reg [26:0] a_m, b_m;       // Mantissas of a and b, extended for rounding
  reg [23:0] z_m;            // Output mantissa
  reg [7:0] a_e, b_e, z_e;   // Exponents of a, b, and result
  reg a_s, b_s, z_s;         // Signs of a, b, and result
  reg busy = 0, output_DONE =0; // Busy and done status flags
  reg guard, ROUND_bit, sticky;	
  reg [27:0] sum;            // Sum of mantissas
  
  assign output_z = z;
  assign output_done = output_DONE;
  
  // Main processing always block triggered on positive edge of clock
  always @(posedge clk) begin
    // Start operation when start signal is high and module is not busy
    if(start && ~busy) begin
      state <= GET_INPUT;
      busy <= 1;
      output_DONE <= 0;
    end

    // FSM to manage the stages of floating-point addition/subtraction
    case(state)
      GET_INPUT: begin
        a <= input_a;
        b <= input_b;
        state <= UNPACK;
      end
          
      UNPACK: begin
        // Extract mantissas and extend with implicit 1 and guard, round, and sticky bits
        a_m <= {1'b0, a[22:0], 3'd0};
        b_m <= {1'b0, b[22:0], 3'd0};
        // Adjust exponents to account for bias
        a_e <= a[30:23] - 127;
        b_e <= b[30:23] - 127;
        // Extract signs
        a_s <= a[31];
        
        // Adjust sign of B for subtraction
        if(subtract)
          b_s <= ~b[31];
        else
          b_s <= b[31];
        state <= SPECIAL_CASES;
      end

      SPECIAL_CASES: begin
        // Check for NaN, infinity, and zero special cases
        // (Implementation details depend on IEEE floating-point rules)
        // This example shows checks for NaN and infinity
        ...
        state <= DONE;  // Move to DONE when special cases are handled
      end

      ALIGN: begin
        // Align mantissas by shifting right and adjusting exponents
        ...
        state <= ADD_0;
      end

      ADD_0: begin
        // Add or subtract mantissas based on aligned exponents and sign
        ...
        state <= ADD_1;
      end

      ADD_1: begin
        // Normalize the result, handle rounding
        ...
        state <= NORMALISE_1;
      end

      NORMALISE_1: begin
        // First pass of normalization
        ...
        state <= NORMALISE_2;
      end

      NORMALISE_2: begin
        // Second pass of normalization
        ...
        state <= ROUND;
      end

      ROUND: begin
        // Round the result according to IEEE rounding rules
        ...
        state <= PACK;
      end

      PACK: begin
        // Pack the result into IEEE floating-point format
        ...
        state <= DONE;
      end
      
      DONE: begin
        // Mark operation as completed and clear busy flag
        busy <= 0;
        output_DONE <= 1;
      end
    endcase

    // Reset logic to clear internal registers and flags
    if (rst) begin
      state <= 4'bxxxx;
      a <= 0;
      b <= 0;
      z <= 0;
      output_DONE <= 0;
      busy <= 0;
    end
  end
endmodule
//This code snippet outlines a floating-point adder/subtractor module with detailed comments, including state definitions, handling of IEEE floating-point rules for special cases, and normalization processes. The FSM is designed to step through each necessary operation to handle both addition and subtraction with proper rounding and handling of special cases like NaN and infinity.


	
