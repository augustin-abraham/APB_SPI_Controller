module spi_top (
    input         PCLK,
    input         PRESETn,
    input         PWRITE,
    input         PSEL,
    input         PENABLE,
    input  [7:0]  PADDR,
    input  [7:0]  PWDATA,
    output [7:0]  PRDATA,
    output        PREADY,
    output        PSLVERR,
    input  [7:0]  tipmiso_data,          // MISO input data from stub

    output        mosi,
    output [7:0]  miso_data,
    output [7:0]  txpiso_data,
    output        ss,
    output        sclk,

    output [7:0]  SPI_CR_1,
    output [7:0]  SPI_CR_2,
    output [7:0]  SPI_BR,
    output [7:0]  SPI_DR,
    output        send_data,
    output        wr_enb,
    output        rd_enb,

    // Debug outputs
    output [3:0]  bit_index_debug,
    output [11:0] tcv_debug,
    output [11:0] count_debug,
    output [11:0] target_debug,
    output        sclk_debug
);

    // Internal wires
    wire [1:0] spi_mode      = SPI_CR_2[2:1];
    wire       spiswai       = SPI_CR_2[0];
    wire       cpol          = SPI_CR_1[2];
    wire       cpha          = SPI_CR_1[1];
    wire       lsbfe         = SPI_CR_1[0];

    wire [2:0] sppr          = SPI_BR[2:0];
    wire [2:0] spr           = SPI_BR[5:3];

    wire [7:0] BaudRateDivisor;
    wire       flags_low, flags_high;
    wire       flag_low_brg, flag_high_brg;
    wire       receive_data;
    wire [7:0] data_miso;

    // Connect miso data back to interface
    assign miso_data = data_miso;

    // APB Slave Interface
    apb_slave_interface apb_slave_inst (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .tipmiso_data(data_miso),

        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .wr_enb(wr_enb),
        .rd_enb(rd_enb),
        .miso_data(miso_data),
        .txpiso_data(txpiso_data),
        .send_data(send_data),
        .SPI_CR_1(SPI_CR_1),
        .SPI_CR_2(SPI_CR_2),
        .SPI_BR(SPI_BR),
        .SPI_DR(SPI_DR)
    );

    // SPI Slave Control Select
    spi_slave_control_select slave_control_inst (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .SPI_CR1(SPI_CR_1),
        .SPI_CR2(SPI_CR_2),
        .SPI_BR(SPI_BR),
        .SPI_DR(SPI_DR),
        .send_data(send_data),
        .ss(ss),
        .receive_data(receive_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .spiswai(spiswai),
        .spi_mode(spi_mode),
        .sppr(sppr),
        .spr(spr),
        .bit_index(bit_index_debug),
        .count(count_debug),
        .target(target_debug),
        .tcv(tcv_debug)
    );

    // Baud Rate Generator
    baud_rate_generator brg_inst (
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
        .flag_low(flag_low_brg),
        .flag_high(flag_high_brg),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .BaudRateDivisor(BaudRateDivisor)
    );

    // Shift Register
    shift_register shift_inst (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .sclk(sclk),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .data_mosi(txpiso_data),
        .miso(tipmiso_data),
        .receive_data(receive_data),
        .mosi(mosi),
        .data_miso(data_miso),
        .bit_index_debug(), // Optional
        .sclk_debug(sclk_debug)
    );

endmodule
