module tb_shift_register;

    reg         PCLK;
    reg         PRESETn;
    reg         ss;
    reg         send_data;
    reg         lsbfe;
    reg         cpha;
    reg         cpol;
    wire        flag_low;
    wire        flag_high;
    wire        flags_low;
    wire        flags_high;
    reg  [7:0]  data_mosi;
    reg         miso;
    reg         receive_data;
    wire        mosi;
    wire [7:0]  data_miso;
    wire [2:0]  bit_index_debug;
    wire        sclk_debug;

    reg [7:0]   miso_pattern;
    integer     i, mode, endian;

    // DUT instantiation
    shift_register dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .data_mosi(data_mosi),
        .miso(miso),
        .receive_data(receive_data),
        .mosi(mosi),
        .data_miso(data_miso),
        .bit_index_debug(bit_index_debug),
        .sclk_debug(sclk_debug)  // if added for logging
    );

    // Clock generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    // Stimulus
    initial begin
        PRESETn = 0;
        send_data = 0;
        receive_data = 0;
        ss = 1;
        miso = 0;
        data_mosi = 8'b10101010;
        miso_pattern = 8'b11001100;

        #20;
        PRESETn = 1;

        // Loop over both MSB-first (0) and LSB-first (1)
        for (endian = 0; endian < 2; endian = endian + 1) begin
            lsbfe = endian;

            // Loop through SPI modes 0 to 3
            for (mode = 0; mode < 4; mode = mode + 1) begin
                $display("\n=== SPI MODE %0d | %s-first ===", mode, (lsbfe ? "LSB" : "MSB"));

                cpol = mode[1];
                cpha = mode[0];

                ss = 1;
                send_data = 0;
                receive_data = 0;
                #20;

                ss = 0;
                receive_data = 1;
                #10 receive_data = 0;

                send_data = 1;
                #10;

                // Send MISO pattern
                if (lsbfe) begin
                    for (i = 0; i < 8; i = i + 1) begin
                        miso = miso_pattern[i];
                        #10;
                    end
                end else begin
                    for (i = 7; i >= 0; i = i - 1) begin
                        miso = miso_pattern[i];
                        #10;
                    end
                end

                send_data = 0;
                ss = 1;
                #40;

                $display("Captured: %b | Expected MISO: %b", data_miso, miso_pattern);
            end
        end

        $display("\n=== All SPI Modes and Bit Orders Tested ===");
        #100;
        $finish;
    end

endmodule
