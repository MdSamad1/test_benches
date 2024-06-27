`timescale 1ns/1ns
module syn_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
  input clk, rst_n,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out,
  output full, empty
);
  
  reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
  reg [DATA_WIDTH-1:0] fifo[DEPTH];
  reg [$clog2(DEPTH)-1:0] count;
  
  // Set Default values on reset.
  always@(posedge clk) begin
    if(!rst_n) begin
      w_ptr <= 0;
      r_ptr <= 0;
      count <= 0;
      $display("HERE --------------------------------------------------------------------------------------------------------");
    end
    else begin
        case({w_en && ~full,r_en && ~empty})
      //case({w_en,r_en})
     
            2'b01: count <= count - 1;
            2'b10: count <= count + 1;
            default: count <= count;
        endcase
        if(w_en & !full)begin
            fifo[w_ptr] <= data_in;
            w_ptr <= w_ptr + 1;
        end
        if(r_en & !empty) begin
            data_out <= fifo[r_ptr]; // To read data from FIFO
            r_ptr <= r_ptr + 1;
        end
    end
  end
  
  
  assign full = (count == DEPTH)? 1'b1 : 1'b0;
  assign empty = (count == 0)? 1'b1 : 1'b0;
endmodule
