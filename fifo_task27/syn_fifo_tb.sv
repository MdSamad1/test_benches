`timescale 1ns/1ns

module syn_fifo_tb;

    // Marking the start and end of Simulation
    initial $display("\033[7;36m [time: %t] TEST STARTED \033[0m",$time);
    final   $display("\033[7;36m [time: %t]TEST ENDED \033[0m",$time);

    ////////////////////////////////////////////////////////////////////////////
    // LOCAL PARAMETERS
    ////////////////////////////////////////////////////////////////////////////

    // AS DUT
    localparam int WIDTH = 8;
    localparam int DEPTH = 8;

    //////////////////////////////////////////////////////////////////////////////
    //-SIGNALS
    //////////////////////////////////////////////////////////////////////////////

    logic             clk;    // simulation timing clock
    logic             rst_n;  // active low reset
    logic             w_en;   // write enable
    logic             r_en;   // read enable
    logic             full;   // high when fifo is full
    logic             empty;  // high when fifo is empty

    logic [WIDTH-1:0] data_in;  // gray input data
    logic [WIDTH-1:0] data_out;  // binary output data

    //////////////////////////////////////////////////////////////////////////////
    //-VARIABLES
    //////////////////////////////////////////////////////////////////////////////

    int         pass;  // number of time results did matched
    int         fail;  // number of time results did not matched


    //////////////////////////////////////////////////////////////////////////////
    //-QUEUE TO PUSH DATA-IN
    //////////////////////////////////////////////////////////////////////////////
    
    //logic [WIDTH-1:0] wdata_q [$];
    //logic [WIDTH-1:0] wdata;

    //////////////////////////////////////////////////////////////////////////////
    //-RTL CONNECTION
    //////////////////////////////////////////////////////////////////////////////

    syn_fifo #(
        .DATA_WIDTH(WIDTH),
        .DEPTH(DEPTH)
        ) dut_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .w_en(w_en),
        .r_en(r_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    //Driver Mailbox
    mailbox #(logic [WIDTH-1:0]) dvr_DataIn_mbx   = new();
    mailbox #(logic) dvr_wEn_mbx                  = new();
    mailbox #(logic) dvr_rEn_mbx                  = new();
  
    //Monitor Mailbox
    mailbox #(logic [WIDTH-1:0]) mon_DataIn_mbx   = new();
    mailbox #(logic) mon_wEn_mbx                  = new();
    mailbox #(logic) mon_rEn_mbx                  = new();
    mailbox #(logic [WIDTH-1:0]) mon_DataOut_mbx  = new();
    mailbox #(logic) mon_full_mbx                 = new();
    mailbox #(logic) mon_empty_mbx                = new();

    //////////////////////////////////////////////////////////////////////////////
    //-METHODS
    //////////////////////////////////////////////////////////////////////////////

    // Apply system reset and initialize all inputs
    task static apply_reset();
        #10ns;
        clk     <= '0;
        rst_n   <= '0;
        w_en    <= '0;
        r_en    <= '0;
        data_in <= '0;
        #5ns;
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
                logic [WIDTH-1:0] data;
                logic wEn;
                logic rEn;

                dvr_DataIn_mbx.get(data);
                dvr_wEn_mbx.get(wEn);
                dvr_rEn_mbx.get(rEn);
                data_in <= data;
                w_en    <= wEn;
                r_en    <= rEn;
                //wdata_q.push_back(data_in);
                $display("[%t]................w_en..................: %b",$time,wEn);
                $display("[%t]................r_en..................: %b",$time,rEn);
                @(posedge clk);
            end

            forever begin // in monitor
                @ (posedge clk);
                mon_DataIn_mbx.put(data_in);
                mon_wEn_mbx.put(w_en);
                mon_rEn_mbx.put(r_en);
                $display("[%0t]Input Data: %b",$time,data_in);
                $display("[%0t]Write Enable: %b",$time,w_en);
                $display("[%0t]Read Enable: %b",$time,r_en);
            end

            forever begin // out monitor
                @ (posedge clk);
                mon_DataOut_mbx.put(data_out);
                mon_full_mbx.put(full);
                mon_empty_mbx.put(empty);
                $display("[%0t]Output data: %b",$time,data_out);
                $display("[%0t]full: %b",$time,full);
                $display("[%0t]empty: %b",$time,empty);
            end
            ////////////Scoreboard//////////////

            forever begin
                //logic [WIDTH-1:0] expected_out;
                logic [WIDTH-1:0] wdata_q[$];
                logic [WIDTH-1:0] wdata;
                logic [WIDTH-1:0] dataIn_s;
                logic [WIDTH-1:0] dataOut_s;
                logic  w_en_s;
                logic  r_en_s;
                logic  full_s;
                logic  empty_s;

                mon_DataIn_mbx.get(dataIn_s);
                //mon_rEn_mbx.get(r_en_s);
                //mon_wEn_mbx.get(w_en_s);
                mon_empty_mbx.get(empty_s);
                mon_full_mbx.get(full_s);
                mon_DataOut_mbx.get(dataOut_s);

               if (w_en & !full_s) begin
                   wdata_q.push_back(dataIn_s);
               end
               if (r_en & !empty_s) begin
                   wdata = wdata_q.pop_front();
               end
               if(wdata === dataOut_s) pass++;
               //if(data_in === data_out) pass++;
               else begin
                   fail++;
                   $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, dataOut_s);
               end
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

        start_clock();
        apply_reset();

        driver_monitor_scoreboard();

        // letting things run for 10 posedge of clk
        @(posedge clk);
            fork
                for (int i=0; i<30; i++) begin
                    @(posedge clk);
                    if((i%2==1)&& !full) begin
                        dvr_DataIn_mbx.put($urandom);
                        dvr_wEn_mbx.put(i%2);
                        $display("[%t] w_en: %d",$time,w_en);
                    end
                end
                for (int i=1; i<31; i++) begin
                    @(posedge clk);
                    if(i%2) begin
                        dvr_rEn_mbx.put(1);
                        $display("[%t] r_en: %d",$time,r_en);
                    end
                end
            join

       repeat(30) @(posedge clk);
        //driver_monitor_scoreboard();

        // printing out number of passes out of total
        $display("\033[1;33m%0d/%0d PASSED\033[0m", pass, pass + fail);

        // end simulation
        $finish;

    end

endmodule

