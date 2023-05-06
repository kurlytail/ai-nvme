 module nvme_cq #(
     parameter CQ_COUNT = 1,    // Number of Completion Queues
     parameter CQ_DEPTH = 64    // Depth of each Completion Queue
 ) (
     input wire clk,
     input wire reset_n,
     input wire [CQ_COUNT-1:0] cq_enable,           // Enable the Completion Queues (one bit for each queue)
     input wire [31:0] cq_head [0:CQ_COUNT-1],      // Completion Queue Head pointers (one per queue)
     input wire [31:0] cq_tail [0:CQ_COUNT-1],      // Completion Queue Tail pointers (one per queue)
     input wire [127:0] cq_entry,                   // Completion Queue Entry (128-bit wide to hold a 16-byte completion)
     input wire entry_valid,                        // Indicates that a valid entry is available
     input wire [31:0] cq_id,                       // ID of the Completion Queue to which the entry belongs
     output wire entry_consumed,                    // Indicates the CQ has consumed the entry
     output wire [CQ_COUNT-1:0] cq_full,            // Indicates if the Completion Queues are full
     output wire [CQ_COUNT-1:0] cq_empty,           // Indicates if the Completion Queues are empty
     output wire cq_write_req,                      // Indicates a request to write a CQ entry to the PCIe interface
     input wire cq_write_ack,                       // Indicates the PCIe interface has accepted the CQ entry
     output wire [127:0] cq_write_data,             // CQ entry data to be written to the PCIe interface
     output wire [63:0] cq_write_addr,              // CQ entry address to be written to the PCIe interface
     output wire [31:0] cq_write_id,                // ID of the CQ to be written to the PCIe interface
     output wire [31:0] cq_dbell_id,                // ID of the CQ that was doorbell'ed
     input wire [31:0] cq_dbell_ptr,                // Doorbell pointer for the CQ
     input wire cq_dbell_valid,                     // Indicates that a doorbell is available
     output wire cq_dbell_ack                       // Indicates that the doorbell has been accepted
 );


   reg [127:0] cq_state[CQ_COUNT - 1 : 0][CQ_DEPTH - 1 : 0];
   integer i;

   // Initial state
   always @(posedge clk or negedge reset_n) begin
     if (~reset_n) begin
       for (i = 0; i < CQ_COUNT; i = i + 1) begin
         for (integer j = 0; j < CQ_DEPTH; j = j + 1) begin
           cq_state[i][j] <= 128'h0;
         end
       end
     end
   end


   // Doorbell handling
   reg doorbell_updated;
   always @(posedge clk or negedge reset_n) begin
     if (~reset_n) begin
       doorbell_updated <= 1'b0;
     end else begin
       doorbell_updated <= cq_dbell_valid;
     end
   end

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
        // Do nothing on reset
        end else if (doorbell_updated) begin
        // Update the CQ state based on cq_dbell_id and cq_dbell_ptr with the cq_entry
        cq_state[cq_dbell_id][cq_dbell_ptr] <= cq_entry;
        end
    end

    // Doorbell acknowledgement
    assign cq_dbell_ack = doorbell_updated;

   // ...Rest of your implementation for adding/updating elements to cq_state here

 endmodule