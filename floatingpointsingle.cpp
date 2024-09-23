#include <systemc>

using namespace sc_core;
using namespace sc_dt;

SC_MODULE(MatrixMultiplier) {
    sc_in<bool> clk;
    sc_in<bool> reset;
    sc_in<bool> start;
    sc_out<bool> done;

    sc_in<sc_lv<32>> m1[4][4];
    sc_in<sc_lv<32>> m2[4][4];
    sc_out<sc_lv<32>> m_res[4][4];

    SC_CTOR(MatrixMultiplier) {
        SC_THREAD(process);
        sensitive << clk.pos();
        async_reset_signal_is(reset, true);
    }

    void process() {
        while (true) {
            if (start.read()) {
                float mat1[4][4], mat2[4][4], result[4][4];

                // Reading input matrices
                for (int i = 0; i < 4; ++i) {
                    for (int j = 0; j < 4; ++j) {
                        mat1[i][j] = m1[i][j].to_uint();
                        mat2[i][j] = m2[i][j].to_uint();
                    }
                }

                // Matrix multiplication
                for (int i = 0; i < 4; ++i) {
                    for (int j = 0; j < 4; ++j) {
                        result[i][j] = 0;
                        for (int k = 0; k < 4; ++k) {
                            result[i][j] += mat1[i][k] * mat2[k][j];
                        }
                    }
                }

                // Writing the result
                for (int i = 0; i < 4; ++i) {
                    for (int j = 0; j < 4; ++j) {
                        m_res[i][j].write(sc_lv<32>(result[i][j]));
                    }
                }

                done.write(true);
            } else {
                done.write(false);
                // Initialize m_res with default value
                for (int i = 0; i < 4; ++i) {
                    for (int j = 0; j < 4; ++j) {
                        m_res[i][j].write(sc_lv<32>(0));
                    }
                }
            }
        }
    }
};