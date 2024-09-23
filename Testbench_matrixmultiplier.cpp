#include <systemc> 
#include "MatrixMultiplier.h" // Include the module definition

// Define a Testbench module using the SC_MODULE macro

SC_MODULE(Testbench) { 

sc_signal<bool> clk; 

sc_signal<bool> reset; 

sc_signal<bool> start; 

sc_signal<bool> done; 

 

sc_signal<sc_lv<32>> m1[4][4]; 

sc_signal<sc_lv<32>> m2[4][4]; 

sc_signal<sc_lv<32>> m_res[4][4]; 

 

MatrixMultiplier* uut; // Unit Under Test 

 

SC_CTOR(Testbench) { 

uut = new MatrixMultiplier("MatrixMultiplier"); 

uut->clk(clk); 

uut->reset(reset); 

uut->start(start); 

uut->done(done); 

 

for (int i = 0; i < 4; ++i) { 

for (int j = 0; j < 4; ++j) { 

uut->m1[i][j](m1[i][j]); 

uut->m2[i][j](m2[i][j]); 

uut->m_res[i][j](m_res[i][j]); 

} 

} 

 

SC_THREAD(run); 

} 

 

void run() { 

// Initialize inputs 

reset.write(true); 

wait(10, SC_NS); 

reset.write(false); 

 

float mat1[4][4] = { 

{1.0, 2.0, 3.0, 4.0}, 

{5.0, 6.0, 7.0, 8.0}, 

{9.0, 10.0, 11.0, 12.0}, 

{13.0, 14.0, 15.0, 16.0} 

}; 

 

float mat2[4][4] = { 

{16.0, 15.0, 14.0, 13.0}, 

{12.0, 11.0, 10.0, 9.0}, 

{8.0, 7.0, 6.0, 5.0}, 

{4.0, 3.0, 2.0, 1.0} 

}; 

 

for (int i = 0; i < 4; ++i) { 

for (int j = 0; j < 4; ++j) { 

m1[i][j].write(*reinterpret_cast<sc_lv<32>*>(&mat1[i][j])); 

m2[i][j].write(*reinterpret_cast<sc_lv<32>*>(&mat2[i][j])); 

} 

} 

 

// Start the computation 

start.write(true); 

wait(10, SC_NS); 

start.write(false); 

 

// Wait for the done signal 

wait(done.posedge_event()); 

 

// Capture the result 

float result[4][4]; 

for (int i = 0; i < 4; ++i) { 

for (int j = 0; j < 4; ++j) { 

result[i][j] = *reinterpret_cast<const float*>(&m_res[i][j].read()); 

} 

} 

 

// Print the result 

std::cout << "Resulting Matrix:" << std::endl; 

for (int i = 0; i < 4; ++i) { 

for (int j = 0; j < 4; ++j) { 

std::cout << result[i][j] << " "; 

} 

std::cout << std::endl; 

} 

 

// End simulation 

sc_stop(); 

} 

}; 

 

int sc_main(int argc, char* argv[]) { 

Testbench tb("Testbench"); 

sc_start(); 

return 0; 

} 