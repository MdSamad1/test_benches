module demux_1_to_4 (
    input  logic [1:0] sel,      // 2-bit select line
    input  logic       data_in,  // Input data
    output logic [3:0] data_out  // Output data
);

    always_comb begin
        // Default all outputs to 0
        data_out = 4'b0000;
        
        // Set the appropriate output based on the select lines
        case (sel)
            2'b00: data_out[0] = data_in;
            2'b01: data_out[1] = data_in;
            2'b10: data_out[2] = data_in;
            2'b11: data_out[3] = data_in;// 
            default: data_out = 4'b0000; // Default case, though not strictly necessary
        endcase
    end
endmodule
