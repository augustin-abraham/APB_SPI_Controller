module tb_apb_slave_interface;

reg PCLK, PRESETn, PWRITE, PSEL, PENABLE;
reg [7:0] PADDR, PWDATA, tipmiso_data;
wire [7:0] PRDATA;
wire PREADY, PSLVERR;
wire wr_enb, rd_enb, send_data;
wire [7:0] miso_data, txpiso_data;
wire [7:0] SPI_CR_1, SPI_CR_2, SPI_BR, SPI_DR;

apb_slave_interface dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .tipmiso_data(tipmiso_data),
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

initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
end

initial begin
    // Init
    PRESETn = 0; PWRITE = 0; PSEL = 0; PENABLE = 0;
    PADDR = 0; PWDATA = 0; tipmiso_data = 8'hAA;
    #20; PRESETn = 1;

    // Write to SPI_CR_1
    #10; PADDR = 8'h00; PWDATA = 8'b10111011; PSEL = 1; PWRITE = 1;
    #10; PENABLE = 1; #10; PENABLE = 0; PSEL = 0;

    // Write to SPI_CR_2
    #20; PADDR = 8'h04; PWDATA = 8'b11011010; PSEL = 1; PWRITE = 1;
    #10; PENABLE = 1; #10; PENABLE = 0; PSEL = 0;

    // Write to SPI_BR
    #20; PADDR = 8'h08; PWDATA = 8'b11001100; PSEL = 1; PWRITE = 1;
    #10; PENABLE = 1; #10; PENABLE = 0; PSEL = 0;

    // Write to SPI_DR
    #20; PADDR = 8'h0C; PWDATA = 8'b11110000; PSEL = 1; PWRITE = 1;
    #10; PENABLE = 1; #10; PENABLE = 0; PSEL = 0;

    // Read from SPI_CR_1
    #30; PADDR = 8'h00; PWRITE = 0; PSEL = 1;
    #10; PENABLE = 1; #10; PENABLE = 0; PSEL = 0;

    // Read from SPI_DR (get tipmiso_data)
    #30; PADDR = 8'h0C; tipmiso_data = 8'b10101010;
    PWRITE = 0; PSEL = 1;
    #10; PENABLE = 1; #10; PENABLE = 0; PSEL = 0;

    #100 $finish;
end

endmodule
