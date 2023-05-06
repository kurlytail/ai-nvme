// nvme_top.v
module nvme_top (
    input wire clk,
    input wire reset_n,
    input wire pcie_rx_valid,
    input wire [15:0] pcie_rx_data,
    output wire pcie_tx_ready,
    input wire pcie_tx_ack,
    output wire [15:0] pcie_tx_data,
    input wire irq_ack,
    output wire irq_req
);

// PCIe interface
reg [15:0] pcie_tx_data_reg;
reg pcie_tx_ready_reg;
wire pcie_tx_ack_reg = pcie_tx_ack;
assign pcie_tx_data = pcie_tx_data_reg;
assign pcie_tx_ready = pcie_tx_ready_reg;

// NVMe registers
wire [15:0] reg_addr;
wire [31:0] reg_wr_data;
wire reg_wr_en;
wire [31:0] reg_rd_data;

nvme_registers nvme_regs (
    .clk(clk),
    .reset_n(reset_n),
    .addr(reg_addr),
    .wr_data(reg_wr_data),
    .wr_en(reg_wr_en),
    .rd_data(reg_rd_data)
);

// NVMe command handling
reg [15:0] cmd_reg;
reg cmd_valid;
reg cmd_done;
reg cmd_error;

// Interrupt logic
reg irq_req_reg;
wire irq_ack_reg = irq_ack;
assign irq_req = irq_req_reg;

// Main state machine
reg [2:0] state;
localparam INIT = 3'b000, IDLE = 3'b001, CMD = 3'b010, IRQ = 3'b011;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= INIT;
    end else begin
        case (state)
            INIT: begin
                state <= IDLE;
            end

            IDLE: begin
                if (pcie_rx_valid) begin
                    state <= CMD;
                end
            end

            CMD: begin
                // memory[cmd_reg['sd11:'sd0]] <= reg_wr_data; // Comment out or remove this line
                cmd_valid <= 1;
                state <= IRQ;
            end

            IRQ: begin
                if (irq_ack) begin
                    state <= IDLE;
                end
            end
        endcase
    end
end

// Output generation based on state
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        pcie_tx_data_reg <= 16'h0000;
        pcie_tx_ready_reg <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                pcie_tx_data_reg <= 16'h0000;
                pcie_tx_ready_reg <= 1'b0;
            end

            CMD: begin
                // pcie_tx_data_reg <= memory[cmd_reg['sd11:'sd0]]; // Comment out or remove this line
                pcie_tx_ready_reg <= 1'b1;
            end

            IRQ: begin
                pcie_tx_data_reg <= 16'h0000;
                pcie_tx_ready_reg <= 1'b0;
            end

            default: begin
                pcie_tx_data_reg <= 16'h0000;
                pcie_tx_ready_reg <= 1'b0;
            end
        endcase
    end
end

endmodule
