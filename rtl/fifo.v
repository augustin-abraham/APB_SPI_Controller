`timescale 1ns/1ps
module gpt_fifo #(parameter DEPTH = 16)(
    input clk, rstn,
    input wr_en,
    input [7:0] wr_data,
    input rd_en,
    output reg [7:0] rd_data,
    output full, empty
);
    reg [7:0] mem [0:DEPTH-1];
    reg [4:0] wr_ptr, rd_ptr, count;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end else begin
            // Write
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end

            // Read
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end
    end
endmodule
`timescale 1ns/1ps
module gpt_fifo_tb;
    reg clk, rstn;
    reg wr_en, rd_en;
    reg [7:0] wr_data;
    wire [7:0] rd_data;
    wire full, empty;

    // DUT
    gpt_fifo DUT (
        .clk(clk),
        .rstn(rstn),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    // Clock generation: 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize signals
        rstn = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 8'h00;

        // Apply reset
        #20;
        rstn = 1;
        #10;

      

        // Write 16 bytes into FIFO
        repeat (16) begin
            @(posedge clk);
            if (!full) begin
                wr_en = 1;
                wr_data = wr_data + 8'h01;
               
            end
        end
        @(posedge clk);
        wr_en = 0;

       
        // Small delay
        #50;

       

        // Read all 16 bytes from FIFO
        repeat (16) begin
            @(posedge clk);
            if (!empty) begin
                rd_en = 1;
              
            end
        end
        @(posedge clk);
        rd_en = 0;


        #50;
        $finish;
    end

   
endmodule
