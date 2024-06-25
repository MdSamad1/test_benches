module moore_o_1010_tb;

    // Marking the start and end of Simulation
    initial $display("\033[7;36m TEST STARTED \033[0m");
    final   $display("\033[7;36m TEST ENDED \033[0m");

    //////////////////////////////////////////////////////////////////////////////
    //-SIGNALS
    //////////////////////////////////////////////////////////////////////////////

    logic   in;     // simulation timing clock
    logic   clk;    // simulation timing clock
    logic   rst_n;  // simulation timing clock
    logic   out;    //out output data

    //////////////////////////////////////////////////////////////////////////////
    //-VARIABLES
    //////////////////////////////////////////////////////////////////////////////

    int         pass;  // number of time results did matched
    int         fail;  // number of time results did not matched

    //////////////////////////////////////////////////////////////////////////////
    //-RTL CONNECTON
    //////////////////////////////////////////////////////////////////////////////

    moore_o_1010 u_moore (
        .in(in),
        .clk(clk),
        .rst_n(rst_n),
        .out(out)
    );

    //Driver Mailbox
    mailbox #(logic) dvr_mbx        = new();

    //Monitor Mailbox For I/O
    mailbox #(logic) mon_in_mbx     = new();
    mailbox #(logic) mon_out_mbx    = new();


    //////////////////////////////////////////////////////////////////////////////
    //-METHODS
    //////////////////////////////////////////////////////////////////////////////

    // Apply system reset and initialize all inputs
    task static apply_reset();
        #10ns;
        clk     <= '0;
        rst_n   <= '0;
        in      <= '0;
        #10ns;
        rst_n   <= '1;
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
                logic x;
                dvr_mbx.get(x);
                in <= x;
                @(posedge clk);
            end

            forever begin // in monitor
                @ (posedge clk);
                mon_in_mbx.put(in);
            end

            forever begin // out monitor
                @ (posedge clk);
                mon_out_mbx.put(out);
            end

            //////////////////////////////////////
            //////////// Scoreboard //////////////
            //////////////////////////////////////

            forever begin
                logic inputs;
                logic [3:0] in_seq;
                logic moore_out;

                mon_in_mbx.get(inputs);
                mon_out_mbx.get(moore_out);

           /////////// input sequence ////////////

                /*in_seq[0] <= inputs;
                in_seq[1] <= in_seq[0];
                in_seq[2] <= in_seq[1];
                in_seq[3] <= in_seq[2]; */
                in_seq <= {in_seq[2:0],inputs};

                $display("inputs sequence: %b",in_seq);
                $display("Output: %b",out);
                $display("input: %b",inputs);
 
                if(in_seq === 4'b1010) moore_out =1;
                else moore_out =0;

                if (moore_out === out)
                        pass++;
                else fail++;
            end
        join_none
    endtask
    /////////////////////////////////////////////
    ///////////////End Scoreboard////////////////
    /////////////////////////////////////////////


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
    repeat(100) begin
        dvr_mbx.put($urandom);
    end

    repeat(110) @(posedge clk);
    //driver_monitor_scoreboard();

    // printing out number of passes out of total
    $display("\033[1;33m%0d/%0d PASSED\033[0m", pass, pass + fail);

    // end simulation
    $finish;

  end

endmodule


