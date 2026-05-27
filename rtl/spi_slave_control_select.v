module spi_slave_control_select (
    input        PCLK,
    input        PRESETn,
    input        mstr,
    input        spiswai,
    input  [1:0] spi_mode,
    input        send_data,
    input [11:0] BaudRateDivisor,
    input        sclk_stub,
    input        mosi_stub,
    input        miso_stub,

    output reg   ss,
    output reg   tip,
    output reg   receive_data,
    output reg [3:0] bit_index,
    output reg [11:0] count_debug,
    output reg [11:0] target_debug,
    output reg [11:0] tcv
);

    reg [11:0] count;
    reg [11:0] target;
    reg [1:0]  rcv_data_stretch;
    reg        active;

    wire run_mode     = (spi_mode == 2'b00);
    wire wait_mode    = (spi_mode == 2'b01);
    wire transfer_en  = mstr && (run_mode || (wait_mode && spiswai));

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            count            <= 12'hFFF;
            target           <= 12'd0;
            ss               <= 1'b1;
            tip              <= 1'b0;
            receive_data     <= 1'b0;
            bit_index        <= 4'd0;
            rcv_data_stretch <= 2'd0;
            tcv              <= 12'd0;
            active           <= 1'b0;
        end else begin
            count_debug  <= count;
            target_debug <= target;

            if (transfer_en) begin
                if (send_data && !active) begin
                    // Start 8-bit transfer
                    target       <= BaudRateDivisor - 1;
                    count        <= 12'd0;
                    tcv          <= 12'd7;       // 8 cycles = tcv 7→0
                    bit_index    <= 4'd0;
                    ss           <= 1'b0;
                    tip          <= 1'b1;
                    receive_data <= 1'b1;
                    rcv_data_stretch <= 2'd2;
                    active       <= 1'b1;
                end else if (active) begin
                    // Stretch receive_data for multiple PCLK cycles
                    if (rcv_data_stretch > 0)
                        rcv_data_stretch <= rcv_data_stretch - 1;

                    receive_data <= (rcv_data_stretch != 0);

                    if (count < target) begin
                        count <= count + 1;
                    end else begin
                        count <= 12'd0;

                        if (tcv > 0) begin
                            tcv <= tcv - 1;
                            bit_index <= bit_index + 1;
                            rcv_data_stretch <= 2'd2; // pulse again for next bit
                        end else begin
                            // Last bit completed
                            ss <= 1'b1;
                            tip <= 1'b0;
                            active <= 1'b0;
                            receive_data <= 1'b0;
                        end
                    end
                end else begin
                    ss <= 1;
                    tip <= 0;
                    receive_data <= 0;
                end
            end else begin
                // Not enabled
                ss <= 1;
                tip <= 0;
                receive_data <= 0;
                bit_index <= 0;
                tcv <= 0;
                count <= 12'hFFF;
                rcv_data_stretch <= 0;
                active <= 0;
            end
        end
    end
endmodule
