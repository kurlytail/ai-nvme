// nvme_top_tb.v
module nvme_top_tb;
    reg clk;
    reg reset_n;
    reg pcie_rx_valid;
    reg [15:0] pcie_rx_data;
    wire pcie_tx_ready;
    reg pcie_tx_ack;
    wire [15:0] pcie_tx_data;
    reg irq_ack;
    wire irq_req;

    // Instantiate the nvme_top module
    nvme_top dut (
        .clk(clk),
        .reset_n(reset_n),
        .pcie_rx_valid(pcie_rx_valid),
        .pcie_rx_data(pcie_rx_data),
        .pcie_tx_ready(pcie_tx_ready),
        .pcie_tx_ack(pcie_tx_ack),
        .pcie_tx_data(pcie_tx_data),
        .irq_ack(irq_ack),
        .irq_req(irq_req)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Testbench stimulus
    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        pcie_rx_valid = 0;
        pcie_rx_data = 0;
        pcie_tx_ack = 0;
        irq_ack = 0;

        // Apply reset
        #10 reset_n = 1;

        // Add your test cases here

        // Finish simulation
        #1000 $finish;
    end
endmodule
