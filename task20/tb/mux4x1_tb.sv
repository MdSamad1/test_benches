module mux4x1_tb;

  // Marking the start and end of Simulation
  initial $display("\033[7;36m TEST STARTED \033[0m");
  final   $display("\033[7;36m TEST ENDED \033[0m");


  //////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////

  logic             clk;  // simulation timing clock

  logic [3:0] a;    // a input data
  logic [3:0] b;    // b input data
  logic [3:0] c;    // c input data
  logic [3:0] d;    // b input data
  logic [1:0] sel;  // sel input selection data

  logic [3:0] out;  //out output data

  //////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////

  int         pass;  // number of time results did matched
  int         fail;  // number of time results did not matched

  //////////////////////////////////////////////////////////////////////////////
  //-RTL CONNECTON
  //////////////////////////////////////////////////////////////////////////////

  mux4x1 dut_gb (
      .a(a),
      .b(b),
      .c(c),
      .d(d),
      .sel(sel),
      .out(out)
  );

  //Driver Mailbox
  mailbox #(logic [3:0]) dvr_inA_mbx    = new();
  mailbox #(logic [3:0]) dvr_inB_mbx    = new();
  mailbox #(logic [3:0]) dvr_inC_mbx    = new();
  mailbox #(logic [3:0]) dvr_inD_mbx    = new();
  mailbox #(logic [1:0]) dvr_SEL_mbx  = new();
  
  //Monitor Mailbox For I/O
  mailbox #(logic [3:0]) moni_inA_mbx    = new();
  mailbox #(logic [3:0]) moni_inB_mbx    = new();
  mailbox #(logic [3:0]) moni_inC_mbx    = new();
  mailbox #(logic [3:0]) moni_inD_mbx    = new();
  mailbox #(logic [1:0]) moni_SEL_mbx  = new();

  mailbox #(logic [3:0]) moni_out_mbx    = new();




  //////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////

  // Apply system reset and initialize all inputs
  task static apply_reset();
    #100ns;
    clk  <= '0;
    a    <= '0;
    b    <= '0;
    c    <= '0;
    d    <= '0;
    sel  <= '0;
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
            logic [3:0] in [3:0];
            logic [1:0] select;

            dvr_inA_mbx.get(in[0]);
            dvr_inB_mbx.get(in[1]);
            dvr_inC_mbx.get(in[2]);
            dvr_inD_mbx.get(in[3]);
            dvr_SEL_mbx.get(select);

            a   <=  in[0];
            b   <=  in[1];
            c   <=  in[2];
            d   <=  in[3];
            sel <=  select;

            @(posedge clk);
        end

        forever begin // in monitor
            @ (posedge clk);
            moni_inA_mbx.put(a);
            moni_inB_mbx.put(b);
            moni_inC_mbx.put(c);
            moni_inD_mbx.put(d);
            moni_SEL_mbx.put(sel);
            $display("input A: %b input B: %b",a,b);
            $display("input C: %b input D: %b",c,d);
            $display("input SEL: %b",sel);
        end

        forever begin // out monitor
            @ (posedge clk);
            moni_out_mbx.put(out);
            $display("Output: %b",out);
        end

    ////////////Scoreboard//////////////
 
        forever begin
            logic [3:0] expected_out;
            logic [3:0] inA;
            logic [3:0] inB;
            logic [3:0] inC;
            logic [3:0] inD;
            logic [1:0] inSEL;
            logic [3:0] mux_out;

            moni_inA_mbx.get(inA);
            moni_inB_mbx.get(inB);
            moni_inC_mbx.get(inC);
            moni_inD_mbx.get(inD);
            moni_SEL_mbx.get(inSEL);
            moni_out_mbx.get(mux_out);

            expected_out = inSEL[1] ? (inSEL[0] ? inD : inC) : (inSEL[0] ? inB : inA);

            if(expected_out === mux_out) pass++;
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
        dvr_inA_mbx.put($urandom);
        dvr_inB_mbx.put($urandom);
        dvr_inC_mbx.put($urandom);
        dvr_inD_mbx.put($urandom);
        dvr_SEL_mbx.put($urandom);
    end

    repeat(15) @(posedge clk);
    //driver_monitor_scoreboard();

    // printing out number of passes out of total
    $display("\033[1;33m%0d/%0d PASSED\033[0m", pass, pass + fail);

    // end simulation
    $finish;

  end

endmodule

