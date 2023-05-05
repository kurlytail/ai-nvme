module nvme_top (
    input wire clk,               // Clock
    input wire reset_n,           // Active-low reset
    input wire pcie_rx_valid,     // PCIe data received valid
    input wire [15:0] pcie_rx_data, // PCIe data received
    output wire pcie_tx_ready,    // PCIe transmitter ready
    input wire pcie_tx_ack,       // PCIe transmitted data acknowledged
    output wire [15:0] pcie_tx_data, // PCIe data to transmit
    input wire irq_ack,           // Interrupt acknowledge
    output wire irq_req           // Interrupt request
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
assign irq_req = irq_req_reg;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cmd_reg <= 16'h0000;
        cmd_valid <= 1'b0;
        cmd_done <= 1'b0;
        cmd_error <= 1'b0;
        irq_req_reg <= 1'b0;
    end else begin
        // PCIe receive data handling
        if (pcie_rx_valid) begin
            cmd_reg <= pcie_rx_data;
            cmd_valid <= 1'b1;
        end

        // PCIe transmit data handling
        if (pcie_tx_ack) begin
            pcie_tx_ready_reg <= 1'b0;
        end

        // Command handling
        if (cmd_valid && !cmd_done && !cmd_error) begin
            case (cmd_reg[15:12]) // 4-bit command
                4'h0: begin // Read command
                    pcie_tx_data_reg <= memory[cmd_reg[11:0]]; // 12-bit address
                    pcie_tx_ready_reg <= 1'b1;
                    cmd_done <= 1'b1;
                end

                4'h1: begin // Write command
                    memory[cmd_reg[11:0]] <= pcie_rx_data; // 12-bit address
                    cmd_done <= 1'b1;
                end

                4'hF: begin // Invalid command
                    cmd_error <= 1'b1;
                    irq_req_reg <= 1'b1;
                end

                default: begin // No command
                    cmd_done <= 1'b0;
                    cmd_error <= 1'b0;
                end
            endcase
        end

        // Command reset
        if (cmd_done || cmd_error) begin
            cmd_valid <= 1'b0;
            cmd_done <= 1'b0;
            cmd_error <= 1'b0;
        end

        // Interrupt handling
        if (irq_ack) begin
            irq_req_reg <= 1'b0;
        end
    end
end

endmodule