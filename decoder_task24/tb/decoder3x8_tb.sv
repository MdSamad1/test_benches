module decoder3x8_tb;

  // Marking the start and end of Simulation
  initial $display("\033[7;36m TEST STARTED \033[0m");
  final   $display("\033[7;36m TEST ENDED \033[0m");


  //////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////

  logic         clk;  // simulation timing clock
  logic [2:0]   in;   // 3 bit input data

  logic [7:0]   out;  //out output data

  //////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////

  int         pass;  // number of time results did matched
  int         fail;  // number of time results did not matched

  //////////////////////////////////////////////////////////////////////////////
  //-RTL CONNECTON
  //////////////////////////////////////////////////////////////////////////////

  decoder3x8 dut01 (
      .in(in),
      .out(out)
  );

  //Driver Mailbox
  mailbox #(logic [2:0]) dvr_in_mbx    = new();
  
  //Monitor Mailbox For I/O
  mailbox #(logic [2:0]) moni_in_mbx   = new();
  mailbox #(logic [7:0]) moni_out_mbx  = new();




  //////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////

  // Apply system reset and initialize all inputs
  task static apply_reset();
    #100ns;
    clk  <= '0;
    in   <= '0;
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
            logic [2:0] data_in;
            dvr_in_mbx.get(data_in);
            in   <=  data_in;
            @(posedge clk);
        end

        forever begin // in monitor
            @ (posedge clk);
            moni_in_mbx.put(in);
            $display("input: %b",in);
        end

        forever begin // out monitor
            @ (posedge clk);
            moni_out_mbx.put(out);
            $display("Output: %b",out);
        end

    ////////////Scoreboard//////////////
 
        forever begin
            logic [7:0] expected_out;
            logic [2:0] A;
            logic [7:0] decoder_out;

            moni_in_mbx.get(A);
            moni_out_mbx.get(decoder_out);

            expected_out = 
                (A == 3'b000) ? 8'b00000001 : 
                (A == 3'b001) ? 8'b00000010 : 
                (A == 3'b010) ? 8'b00000100 : 
                (A == 3'b011) ? 8'b00001000 : 
                (A == 3'b100) ? 8'b00010000 : 
                (A == 3'b101) ? 8'b00100000 : 
                (A == 3'b110) ? 8'b01000000 : 
                (A == 3'b111) ? 8'b10000000 : 8'b00000000; 

            if(expected_out === decoder_out) pass++;
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
        dvr_in_mbx.put($urandom);
    end

    repeat(15) @(posedge clk);
    //driver_monitor_scoreboard();

    // printing out number of passes out of total
    $display("\033[1;33m%0d/%0d PASSED\033[0m", pass, pass + fail);

    // end simulation
    $finish;

  end

endmodule


