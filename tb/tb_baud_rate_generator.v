module tb_baud_rate_generator;

    reg PCLK;
    reg PRESETn;
    reg [1:0] spi_mode;
    reg spiswai;
    reg [2:0] sppr;
    reg [2:0] spr;
    reg cpol;
    reg cpha;
    reg ss;

    wire sclk;
    wire flag_low, flag_high, flags_low, flags_high;
    wire [7:0] BaudRateDivisor;

    // Instantiate DUT
    baud_rate_generator dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .spi_mode(spi_mode),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .cpol(cpol),
        .cpha(cpha),
        .ss(ss),
        .sclk(sclk),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .BaudRateDivisor(BaudRateDivisor)
    );

    // Clock generation: 100 MHz
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    // SPI mode stimulus loop
    integer i;
    initial begin
        // Common setup
        spiswai = 0;
        sppr = 3'b010;  // Example value: 2
        spr  = 3'b001;  // Example value: 1
        ss = 0;

        // Loop through all 4 SPI modes
        for (i = 0; i < 4; i = i + 1) begin
            // Apply reset
            PRESETn = 0;
            #20;

            // Release reset
            PRESETn = 1;
            spi_mode = i[1:0];

            // Set CPOL and CPHA based on spi_mode
            case (spi_mode)
                2'b00: begin cpol = 0; cpha = 0; end // Mode 0
                2'b01: begin cpol = 0; cpha = 1; end // Mode 1
                2'b10: begin cpol = 1; cpha = 0; end // Mode 2
                2'b11: begin cpol = 1; cpha = 1; end // Mode 3
            endcase

            $display("Testing SPI Mode %b (CPOL=%b, CPHA=%b)", spi_mode, cpol, cpha);

            // Observe for some time
            #500;
        end

        $stop;
    end

endmodule
