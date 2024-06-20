module gray_to_binary_tb;

  // Marking the start and end of Simulation
  initial $display("\033[7;36m TEST STARTED \033[0m");
  final   $display("\033[7;36m TEST ENDED \033[0m");

  ////////////////////////////////////////////////////////////////////////////
  // LOCAL PARAMETERS
  ////////////////////////////////////////////////////////////////////////////

  // AS DUT
  localparam int WIDTH = 4;

  //////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////

  logic             clk;  // simulation timing clock

  logic [WIDTH-1:0] gray;  // input data
  logic [WIDTH-1:0] binary;  // parity out

  //////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////

  int         pass;  // number of time results did matched
  int         fail;  // number of time results did not matched

  //////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////

  gray_to_binary #(
      .WIDTH(WIDTH)
      ) dut_gb (
      .gray(gray),
      .binary(binary)
  );


  //Driver Mailbox
  mailbox #(logic [WIDTH-1:0]) dvr_in_mbx  = new();
  
  //Monitor Mailbox
  mailbox #(logic [WIDTH-1:0]) moni_in_mbx  = new();
  mailbox #(logic [WIDTH-1:0]) moni_out_mbx  = new();




  //////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////

  // Apply system reset and initialize all inputs
  task static apply_reset();
    #100ns;
    clk  <= '0;
    gray <= '0;
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
        logic [WIDTH-1:0] data;
        dvr_in_mbx.get(data);
        gray       <= data;
     end

     forever begin // in monitor
        @ (posedge clk);
           moni_in_mbx.put(gray);
     end

     forever begin // out monitor
        @ (posedge clk);
           moni_out_mbx.put(binary);
     end

     forever begin // scoreboard
        logic [WIDTH-1:0] data_in;
        logic [WIDTH-1:0] expected_out;
        moni_in_mbx.get(data_in);
        moni_out_mbx.get(expected_out);
        repeat(10) @(negedge clk) begin
            if (data_in === expected_out) pass++;
            else                      fail++;
        end
     end
    join_none
  endtask

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
    repeat (10) @(posedge clk) begin
        dvr_in_mbx.put($urandom);
    end

    // printing out number of passes out of total
    $display("\033[1;33m%0d/%0d PASSED\033[0m", pass, pass + fail);

    // end simulation
    $finish;

  end

endmodule
