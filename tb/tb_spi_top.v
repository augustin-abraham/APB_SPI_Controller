`timescale 1ns / 1ps
module tb_spi_top;

    reg         PCLK, PRESETn, PWRITE, PSEL, PENABLE;
    reg  [7:0]  PADDR, PWDATA;
    wire [7:0]  PRDATA;
    wire        PREADY, PSLVERR;
    reg  [7:0]  tipmiso_data;
    wire        ss, sclk, mosi;

    wire [7:0]  miso_data, txpiso_data;
    wire [7:0]  SPI_CR_1, SPI_CR_2, SPI_BR, SPI_DR;
    wire        send_data, wr_enb, rd_enb;

    // Debug
    wire [3:0]  bit_index_debug;
    wire [11:0] tcv_debug;
    wire [11:0] count_debug;
    wire [11:0] target_debug;
    wire        sclk_debug;

    // Instantiate DUT
    spi_top dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .tipmiso_data(tipmiso_data),
        .mosi(mosi),
        .miso_data(miso_data),
        .txpiso_data(txpiso_data),
        .ss(ss),
        .sclk(sclk),
        .SPI_CR_1(SPI_CR_1),
        .SPI_CR_2(SPI_CR_2),
        .SPI_BR(SPI_BR),
        .SPI_DR(SPI_DR),
        .send_data(send_data),
        .wr_enb(wr_enb),
        .rd_enb(rd_enb),
        .bit_index_debug(bit_index_debug),
        .tcv_debug(tcv_debug),
        .count_debug(count_debug),
        .target_debug(target_debug),
        .sclk_debug(sclk_debug)
    );

    // Clock Generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK; // 100 MHz
    end

    // Stimulus
    initial begin
        PRESETn = 0;
        PWRITE  = 0;
        PSEL    = 0;
        PENABLE = 0;
        tipmiso_data = 8'b11010101; // Sample pattern

        #20 PRESETn = 1;
        #50;

        // SPI_CR1: LSBFE=1, CPHA=1, CPOL=1
        write_apb(8'h00, 8'b00000111);  // SPI_CR1
        #40;

        // SPI_CR2: Mode = 00, SWAI = 0
        write_apb(8'h04, 8'b00000000);  // SPI_CR2
        #40;

        // SPI_BR: sppr=7, spr=7 → slowest clock for visibility
        write_apb(8'h08, 8'b11100111);  // SPI_BR
        #40;

        // SPI_DR: Load data to transmit
        write_apb(8'h0C, 8'hA5);        // SPI_DR
        #100;

        // Wait for SS (Slave Select) to activate (low)
        wait (ss == 0);
        #20;

        // Simulate MISO activity in sync with SCLK
        repeat (16) begin
            @(posedge sclk);
            tipmiso_data <= {tipmiso_data[6:0], tipmiso_data[7]}; // Left rotate
        end

        #200;
        read_apb(8'h0C); // Read back received SPI data
        #200;

        // Extend sim to allow zoomed view
        #1400;

        $finish;
    end

    // Write Task
    task write_apb(input [7:0] addr, input [7:0] data);
    begin
        @(posedge PCLK);
        PADDR   = addr;
        PWDATA  = data;
        PWRITE  = 1;
        PSEL    = 1;
        PENABLE = 0;

        @(posedge PCLK);
        PENABLE = 1;

        @(posedge PCLK);
        PSEL    = 0;
        PWRITE  = 0;
        PENABLE = 0;
    end
    endtask

    // Read Task
    task read_apb(input [7:0] addr);
    begin
        @(posedge PCLK);
        PADDR   = addr;
        PWRITE  = 0;
        PSEL    = 1;
        PENABLE = 0;

        @(posedge PCLK);
        PENABLE = 1;

        @(posedge PCLK);
        $display("Read [0x%0h] = 0x%0h", addr, PRDATA);
        PSEL    = 0;
        PENABLE = 0;
    end
    endtask

endmodule
