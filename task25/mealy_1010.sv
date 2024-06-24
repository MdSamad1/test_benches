module mealy_1010(input logic clk, rst_n, x, output z); //FSM sequence dectector 1010 (Overlapping)

////////////// Parameters for 4 states //////////////////
  parameter S0 = 2'b00;
  parameter S1 = 2'b01;
  parameter S2 = 2'b10;
  parameter S3 = 2'b11;

  /////////////// State Declaration ///////////////
  logic [1:0] present_state, next_state;

  /////////////// NextState Logic ////////////////
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
      present_state <= S0;
    end
    else present_state <= next_state;
  end
  
  always @(present_state or x) begin
    case(present_state)
      S0: begin
           if(x === 0) next_state = S0;
           else       next_state = S1;
         end
      S1: begin
           if(x === 0) next_state = S2;
           else       next_state = S1;
         end
      S2: begin
           if(x === 0) next_state = S0;
           else       next_state = S3;
         end
      S3: begin
           if(x === 0) next_state = S2;
           else       next_state = S1;
         end
      default: next_state = S0;
    endcase
  end
  /////////////// Output Logic /////////////

  assign z = (present_state === S3) && (x === 0)? 1:0;
endmodule
