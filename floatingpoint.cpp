#include "systemc.h"
#define MATRIX_SIZE 4

// Floating-point matrix multiplier module
SC_MODULE(FloatingPointMatrixMultiplier) {
  sc_in<bool> clk;
  sc_in<float> operand_1[MATRIX_SIZE][MATRIX_SIZE];
  sc_in<float> operand_2[MATRIX_SIZE][MATRIX_SIZE];
  sc_out<float> result[MATRIX_SIZE][MATRIX_SIZE];

  void multiply() {
    while (true) {
      wait(); // Wait for the rising edge of the clock

      // Perform floating-point matrix multiplication
      float product[MATRIX_SIZE][MATRIX_SIZE];
      for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
          product[i][j] = 0.0;
          for (int k = 0; k < MATRIX_SIZE; k++) {
            product[i][j] += operand_1[i][k].read() * operand_2[k][j].read();
          }
          result[i][j].write(product[i][j]);
        }
      }
    }
  }

  SC_CTOR(FloatingPointMatrixMultiplier) {
    SC_THREAD(multiply);
    sensitive << clk.pos();
  }
};

int sc_main(int argc, char* argv[]) {
  sc_clock clk("clk", 1, SC_NS);
  sc_signal<float> operand_1[MATRIX_SIZE][MATRIX_SIZE];
  sc_signal<float> operand_2[MATRIX_SIZE][MATRIX_SIZE];
  sc_signal<float> result[MATRIX_SIZE][MATRIX_SIZE];

  // Instantiate the matrix multiplier module
  FloatingPointMatrixMultiplier multiplier("multiplier");
  multiplier.clk(clk);
  for (int i = 0; i < MATRIX_SIZE; i++) {
    for (int j = 0; j < MATRIX_SIZE; j++) {
      multiplier.operand_1[i][j](operand_1[i][j]);
      multiplier.operand_2[i][j](operand_2[i][j]);
      multiplier.result[i][j](result[i][j]);
    }
  }

  // Initialize operand_1 matrix
  for (int i = 0; i < MATRIX_SIZE; i++) {
    for (int j = 0; j < MATRIX_SIZE; j++) {
      operand_1[i][j] = i * MATRIX_SIZE + j;  // Assigning consecutive values to the matrix
    }
  }

  // Initialize operand_2 matrix
  for (int i = 0; i < MATRIX_SIZE; i++) {
    for (int j = 0; j < MATRIX_SIZE; j++) {
      operand_2[i][j] = (i + j) % MATRIX_SIZE;  // Assigning a cyclic pattern to the matrix
    }
  }

  // Open VCD file
  sc_trace_file* wf = sc_create_vcd_trace_file("waveform");
  // Dump the desired signals
  for (int i = 0; i < MATRIX_SIZE; i++) {
    for (int j = 0; j < MATRIX_SIZE; j++) {
      std::string signal_name = "result_" + std::to_string(i) + "_" + std::to_string(j);
      sc_trace(wf, result[i][j], signal_name.c_str());
    }
  }

  sc_start(1, SC_NS);  // Allow some time for initialization

  // Print the result matrix
  cout << "Result Matrix:" << endl;
  for (int i = 0; i < MATRIX_SIZE; i++) {
    for (int j = 0; j < MATRIX_SIZE; j++) {
      cout << result[i][j] << "\t";
    }
    cout << endl;
  }

  // Close VCD file
  sc_close_vcd_trace_file(wf);

  return 0;
}
//This code compiles and runs as a standalone SystemC application that simulates a floating-point matrix multiplier. It sets up the matrices, performs the multiplication on every clock cycle, and outputs the result to the console and a waveform file for analysis
