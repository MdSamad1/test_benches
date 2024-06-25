module mux4x1_tb;

    // Marking the start and end of Simulation
    initial $display("\033[7;36m TEST STARTED \033[0m");
    final   $display("\033[7;36m TEST ENDED \033[0m");

    typedef struct packed {
        logic [3:0] a;    // a input data
        logic [3:0] b;    // b input data
        logic [3:0] c;    // c input data
        logic [3:0] d;    // b input data
        logic [1:0] sel;  // sel input selection data
    } input_t;

    //////////////////////////////////////////////////////////////////////////////
    //-SIGNALS
    //////////////////////////////////////////////////////////////////////////////

    logic             clk;  // simulation timing clock
    input_t           inputs;
    logic [3:0] out;  //out output data

    //////////////////////////////////////////////////////////////////////////////
    //-VARIABLES
    //////////////////////////////////////////////////////////////////////////////

    int         pass;  // number of time results did matched
    int         fail;  // number of time results did not matched

    //////////////////////////////////////////////////////////////////////////////
    //-RTL CONNECTON
    //////////////////////////////////////////////////////////////////////////////

    mux4x1 u_mux4x1 (
        .a  (inputs.a),
        .b  (inputs.b),
        .c  (inputs.c),
        .d  (inputs.d),
        .sel(inputs.sel),
        .out(out)
    );

    //Driver Mailbox
    mailbox #(input_t) dvr_mbx  = new();

    //Monitor Mailbox For I/O
    mailbox #(input_t) mon_in_mbx  = new();

    mailbox #(logic [3:0]) mon_out_mbx    = new();




    //////////////////////////////////////////////////////////////////////////////
    //-METHODS
    //////////////////////////////////////////////////////////////////////////////

    // Apply system reset and initialize all inputs
    task static apply_reset();
        #100ns;
        clk  <= '0;
        inputs  <= '0;
        #100ns;
    endtask

    // start toggling system clock forever every 5ns
    task static start_clock();
        fork
            forever begin
                clk <= '1;
                #5ns;
                clk <= '0;
                #5ns;
        end
        join_none
    endtask

    task static driver_monitor_scoreboard();
        fork
            forever begin // in driver
                input_t ins;

                dvr_mbx.get(ins);

                inputs <= ins;

                @(posedge clk);
            end

            forever begin // in monitor
                @ (posedge clk);
                mon_in_mbx.put(inputs);
            end

            forever begin // out monitor
                @ (posedge clk);
                mon_out_mbx.put(out);
            end

            ////////////Scoreboard//////////////

            forever begin
                input_t ins;
                logic [3:0] mux_out;

                mon_in_mbx.get(ins);
                mon_out_mbx.get(mux_out);

                $display("inputs: %p",inputs);
                $display("Output: %d",out);

                if (mux_out === ( ins.sel[1] ?
                    (ins.sel[0] ? ins.d : ins.c) :
                    (ins.sel[0] ? ins.b : ins.a)))
                        pass++;
                else fail++;
            end
        join_none
    endtask

    ///////////////End Scoreboard////////////////

  //////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial
    $dumpfile("dump.vcd");
    $dumpvars;

    apply_reset();
    start_clock();

    driver_monitor_scoreboard();

    // letting things run for 10 posedge of clk
    @(posedge clk);
    repeat(10) begin
        dvr_mbx.put($urandom);
    end

    repeat(15) @(posedge clk);
    //driver_monitor_scoreboard();

    // printing out number of passes out of total
    $display("\033[1;33m%0d/%0d PASSED\033[0m", pass, pass + fail);

    // end simulation
    $finish;

  end

endmodule

