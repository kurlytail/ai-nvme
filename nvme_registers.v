// nvme_registers.v
module nvme_registers (
    input wire clk,
    input wire reset_n,
    input wire [15:0] addr,
    input wire [31:0] wr_data,
    input wire wr_en,
    output wire [31:0] rd_data
);

// NVMe Registers
reg [63:0] CAP; // Controller Capabilities
reg [31:0] CC;  // Controller Configuration
reg [31:0] CSTS; // Controller Status

// Read data output
reg [31:0] rd_data_reg; // Change this line from 'wire' to 'reg'
assign rd_data = rd_data_reg;

// Register write and read logic
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        CAP <= 64'h0000_0000_0000_0001;
        CC <= 32'h0000_0000;
        CSTS <= 32'h0000_0000;
    end else begin
        if (wr_en) begin
            case (addr)
                16'h0000: CAP[31:0] <= wr_data;
                16'h0004: CAP[63:32] <= wr_data;
                16'h0014: CC <= wr_data;
            endcase
        end

        case (addr)
            16'h0000: rd_data_reg <= CAP[31:0];
            16'h0004: rd_data_reg <= CAP[63:32];
            16'h0014: rd_data_reg <= CC;
            16'h001C: rd_data_reg <= CSTS;
            default: rd_data_reg <= 32'h0000_0000;
        endcase
    end
end

endmodule
