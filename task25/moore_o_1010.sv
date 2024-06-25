////////////1010 Overlapping Moore Sequence Detector////////////
module moore_o_1010(
        input logic in,
        input logic clk, 
        input logic rst_n, 
        output logic out
);
        ////////////Parameter////////////
        parameter S0 = 3'b001;
        parameter S1 = 3'b010;
        parameter S2 = 3'b011;
        parameter S3 = 3'b100;
        parameter S4 = 3'b101; // extra state when compared with Mealy Machine
        ////////////State////////////  
        logic [3:0] p_state, n_state;
        ////////////Clock and Reset////////////
        always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            p_state <= S0;
        end
        else 
            p_state <= n_state;
        end
        ////////////Input Case////////////  
        always @(p_state or in) begin
         case(p_state)
            S0: begin
            if(in == 0) n_state = S0;
            else        n_state = S1;
            end
            S1: begin
            if(in == 0) n_state = S2;
            else        n_state = S1;
            end
            S2: begin
            if(in == 0) n_state = S0;
            else        n_state = S3;
            end
            S3: begin
            if(in == 0) n_state = S4;
            else        n_state = S1;
            end
            S4: begin
            if(in == 0) n_state = S0;
            else        n_state = S3;
            end
            default:    n_state = S0;
        endcase
        end
        ////////////Output Case////////////        
        always@(p_state) begin
         case(p_state)
            S0 :      out = 0;
            S1 :      out = 0;
            S2 :      out = 0;
            S3 :      out = 0;
            S4 :      out = 1;
            default : out = 0;
        endcase
        end
endmodule

