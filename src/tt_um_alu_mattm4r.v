

module tt_um_alu_mattm4r (
    input  wire [7:0] ui_in,     // Inputs
    output wire [7:0] uo_out,    // Outputs
    input  wire [7:0] uio_in,    // I/O Inputs (select)
    output wire [7:0] uio_out,   // I/O Outputs (overflow)
    output wire [7:0] uio_oe,    // Output enables
    input  wire       ena,       // Enable
    input  wire       clk,       // Clock
    input  wire       rst_n      // Reset (active low)
);

    // ALU Inputs
    wire [3:0] a, b;
    wire [1:0] select;    

    assign a = ui_in[3:0];
    assign b = ui_in[7:4];
    assign select = uio_in[1:0];

    // ALU Outputs
    reg [3:0] out;
    reg zero, carry, sign;

    // Synchronous ALU logic, triggered on the positive edge of the clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out   <= 4'b0000;
            carry <= 1'b0;
            zero  <= 1'b0;
            sign  <= 1'b0;
        end else begin
            case (select)
                2'b00: {carry, out} <= a + b;  
                2'b01: {carry, out} <= a - b;  
                2'b10: out          <= a & b;  // Bitwise AND
                2'b11: out          <= a | b;  // Bitwise OR
            endcase

            // Compute flags
            zero <= ~|out;
            sign <= out[3];
        end
    end

    // Assign outputs
    assign uo_out = {1'b0, sign, zero, carry, out}; // Remove parity and overflow from the output
    assign uio_out = 8'b0;   // All output pins must be assigned. If not used, assign to 0.
    assign uio_oe = 8'b0; // Only enable the relevant outputs

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, 1'b0, uio_in[7:2]};

endmodule

