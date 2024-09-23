#include "systemc.h"
// Floating-point single-precision matrix multiplier module
SC_MODULE(MatrixMultiplier) {
  sc_in<bool> clk;
  sc_in<bool> reset;
  sc_in<sc_uint<32>> m_1[4][4]; // Input matrix m_1
  sc_in<sc_uint<32>> m_2[4][4]; // Input matrix m_2
  sc_out<sc_uint<32>> m_res[4][4]; // Output matrix m_res


  void multiply() {
    while (true) {
      wait(); // Wait for the rising edge of the clock

      if (reset) {
        // Reset output matrix
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 4; j++) {
            m_res[i][j] = 0;
          }
        }
      } else {
        // Perform matrix multiplication
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 4; j++) {
            sc_uint<32> sum = 0;
            for (int k = 0; k < 4; k++) {
              // Perform floating-point multiplication and addition
              float val_1 = *(float*)&m_1[i][k];
              float val_2 = *(float*)&m_2[k][j];
              sum += *(sc_uint<32>*)(float*)&val_1 * *(sc_uint<32>*)(float*)&val_2;
            }
            m_res[i][j] = sum;
          }
        }
      }
    }
  }

  SC_CTOR(MatrixMultiplier) {
    SC_THREAD(multiply);
    sensitive << clk.pos();
  }
};

int sc_main(int argc, char* argv[]) {
  // Signals
  sc_clock clk("clk", 1, SC_NS);
  sc_signal<bool> reset;
  sc_signal<sc_uint<32>> m_1[4][4];
  sc_signal<sc_uint<32>> m_2[4][4];
  sc_signal<sc_uint<32>> m_res[4][4];

  // Open VCD file
  sc_trace_file* wf = sc_create_vcd_trace_file("waveform");
  // Dump the desired signals
  sc_trace(wf, clk, "clk");
  sc_trace(wf, reset, "reset");
  // ... add more signals to trace if needed

  // Instantiate the matrix multiplier module
  MatrixMultiplier multiplier("multiplier");
  multiplier.clk(clk);
  multiplier.reset(reset);
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      multiplier.m_1[i][j](m_1[i][j]);
      multiplier.m_2[i][j](m_2[i][j]);
      multiplier.m_res[i][j](m_res[i][j]);
    }
  }

  // Simulation
  reset = true;
  sc_start(1, SC_NS);
  reset = false;

  // Set input matrices m_1 and m_2
  // ...

  // Wait for a few clock cycles for the output to stabilize
  sc_start(10, SC_NS);

  // Print the result matrix m_res
  cout << "Result Matrix (m_res):" << endl;
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      cout << m_res[i][j].read() << "\t";
    }
    cout << endl;
  }

  // Close VCD file
  sc_close_vcd_trace_file(wf);

  return 0;
}
