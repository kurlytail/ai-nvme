// nvme_registers.v
module nvme_registers (
    input wire clk,
    input wire reset_n,
    input wire [15:0] addr,
    input wire [31:0] wr_data,
    input wire wr_en,
    output reg [31:0] rd_data,
    output wire [4:0] mqes,       // Max Queue Entries Supported
    output wire [3:0] cqr,        // Contiguous Queues Required
    output wire [7:0] ams,        // Arbitration Mechanism Supported
    output wire [3:0] to,         // Timeout
    output wire [3:0] dstrd,      // Doorbell Stride
    output wire [15:0] nssrs,     // NVM Subsystem Reset Supported
    output wire css_nvm,          // Command Set Supported - NVM
    output wire [6:0] mpsmin,     // Memory Page Size Minimum
    output wire [6:0] mpsmax,     // Memory Page Size Maximum
    output wire [3:0] EN,
    output wire [2:0] CSS,
    output wire [2:0] MPS,
    output wire [3:0] AMS,
    output wire SHN,
    output wire RDY,
    output wire [2:0] CFS,
    output wire SHST,
    output wire [11:0] ASQS,
    output wire [11:0] ACQS
);

// Define CAP register field constants
localparam CAP_MQES = 16'h0001;
localparam CAP_CQR = 1'b0;
localparam CAP_AMS = 8'b01000000;
localparam CAP_TO = 8'b00000001; // Note that the bit width is 8, not 4 as previously mentioned
localparam CAP_DSTRD = 4'b0000;
localparam CAP_NSSRS = 1'b0;
localparam CAP_CSS_NVM = 1'b1;
localparam CAP_MPSMIN = 4'b0001;
localparam CAP_MPSMAX = 4'b0000;

// Define CC register field constants
localparam CC_EN = 4'b0000;
localparam CC_CSS = 3'b000;
localparam CC_MPS = 3'b000;
localparam CC_AMS = 4'b0000;
localparam CC_SHN = 2'b00;

// Define CSTS register field constants
localparam CSTS_RDY = 1'b0;
localparam CSTS_CFS = 3'b000;
localparam CSTS_SHST = 2'b00;

// Define AQA register field constants
localparam AQA_ASQS = 12'b0000_0000_0001;
localparam AQA_ACQS = 12'b0000_0000_0001;

// NVMe Mandatory Registers
reg [63:0] CAP;  // Controller Capabilities
reg [31:0] CC;   // Controller Configuration
reg [31:0] CSTS; // Controller Status
reg [31:0] AQA;  // Admin Queue Attributes
reg [63:0] ASQ;  // Admin Submission Queue Base Address
reg [63:0] ACQ;  // Admin Completion Queue Base Address

// Assign CAP fields to output signals
assign mqes = CAP[15:0];
assign cqr = CAP[16];
assign ams = CAP[18:11];
assign to = CAP[23:20];
assign dstrd = CAP[27:24];
assign nssrs = CAP[36];
assign css_nvm = CAP[37];
assign mpsmin = CAP[51:45];
assign mpsmax = CAP[57:52];

// Register write and read logic
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        CAP <= {3'b0, CAP_MPSMAX, CAP_MPSMIN, CAP_CSS_NVM, CAP_NSSRS, CAP_DSTRD, CAP_TO, CAP_AMS, CAP_CQR, CAP_MQES};
        CC <= {16'b0, CC_SHN, CC_AMS, 1'b0, CC_MPS, 1'b0, CC_CSS, CC_EN};
        CSTS <= {26'b0, CSTS_SHST, 1'b0, CSTS_CFS, CSTS_RDY};
        AQA <= {4'b0, AQA_ACQS, 4'b0, AQA_ASQS};
        ASQ <= 64'h0000_0000_0000_0000;
        ACQ <= 64'h0000_0000_0000_0000;
    end else begin
        if (wr_en) begin
            case (addr)
                // CAP is read-only, so remove the write handling for CAP
                16'h0014: CC <= wr_data;
                16'h0024: AQA <= wr_data;
                16'h0028: ASQ[31:0] <= wr_data;
                16'h002C: ASQ[63:32] <= wr_data;
                16'h0030: ACQ[31:0] <= wr_data;
                16'h0034: ACQ[63:32] <= wr_data;
            endcase
        end

        case (addr)
            16'h0000: rd_data <= CAP[31:0];
            16'h0004: rd_data <= CAP[63:32];
            16'h0014: rd_data <= CC;
            16'h001C: rd_data <= CSTS;
            16'h0024: rd_data <= AQA;
            16'h0028: rd_data <= ASQ[31:0];
            16'h002C: rd_data <= ASQ[63:32];
            16'h0030: rd_data <= ACQ[31:0];
            16'h0034: rd_data <= ACQ[63:32];
            default: rd_data <= 32'h0000_0000;
        endcase
    end
end

endmodule
