`timescale 1ns / 1ps

module nvme_registers_tb;
    reg clk;
    reg reset_n;
    reg [15:0] addr;
    reg [31:0] wr_data;
    reg wr_en;
    wire [31:0] rd_data;
    wire [4:0] mqes;
    wire [3:0] cqr;
    wire [7:0] ams;
    wire [3:0] to;
    wire [3:0] dstrd;
    wire [15:0] nssrs;
    wire css_nvm;
    wire [6:0] mpsmin;
    wire [6:0] mpsmax;

    // Instantiate nvme_registers
    nvme_registers dut (
        .clk(clk),
        .reset_n(reset_n),
        .addr(addr),
        .wr_data(wr_data),
        .wr_en(wr_en),
        .rd_data(rd_data),
        .mqes(mqes),
        .cqr(cqr),
        .ams(ams),
        .to(to),
        .dstrd(dstrd),
        .nssrs(nssrs),
        .css_nvm(css_nvm),
        .mpsmin(mpsmin),
        .mpsmax(mpsmax)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

initial begin
    // Initialize signals
    clk = 0;
    reset_n = 0;
    addr = 16'h0000;
    wr_data = 32'h0000_0000;
    wr_en = 0;

    // Apply reset
    #10 reset_n = 1;

    // Test CAP register read
    addr = 16'h0000;
    wr_en = 0;
    #10;
    if (rd_data !== 32'h2001_0001) $display("Error: CAP[31:0] mismatch! Expected: 32'h2001_0001, Actual: 32'h%h", rd_data);
    addr = 16'h0004;
    wr_en = 0;
    #10;
    if (rd_data !== 32'h0100_0001) $display("Error: CAP[63:32] mismatch! Expected: 32'h0100_0001, Actual: 32'h%h", rd_data);

    // Test CAP register fields
    if (mqes !== 5'b00001) $display("Error: mqes mismatch! Expected: 5'b00001, Actual: 5'b%b", mqes);
    if (cqr !== 1'b0) $display("Error: cqr mismatch! Expected: 1'b0, Actual: 1'b%b", cqr);
    if (ams !== 8'b0100_0000) $display("Error: ams mismatch! Expected: 8'b0100_0000, Actual: 8'b%b", ams);
    if (to !== 4'b0001) $display("Error: to mismatch! Expected: 4'b0001, Actual: 4'b%b", to);
    if (dstrd !== 4'b0000) $display("Error: dstrd mismatch! Expected: 4'b0000, Actual: 4'b%b", dstrd);
    if (nssrs !== 1'b0) $display("Error: nssrs mismatch! Expected: 1'b0, Actual: 1'b%b", nssrs);
    if (css_nvm !== 1'b1) $display("Error: css_nvm mismatch! Expected: 1'b1, Actual: 1'b%b", css_nvm);
    if (mpsmin !== 7'b000_0001) $display("Error: mpsmin mismatch! Expected: 7'b000_0001, Actual: 7'b%b", mpsmin);
    if (mpsmax !== 7'b000_0000) $display("Error: mpsmax mismatch! Expected: 7'b000_0000, Actual: 7'b%b", mpsmax);

    $display("Test completed.");

    // Finish simulation
    $finish;
end

endmodule

