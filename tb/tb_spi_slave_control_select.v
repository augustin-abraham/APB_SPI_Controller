module tb_spi_slave_control_select;
    reg         PCLK;
    reg         PRESETn;
    reg         mstr;
    reg         spiswai;
    reg  [1:0]  spi_mode;
    reg         send_data;
    reg  [11:0] BaudRateDivisor;

    reg         sclk_stub;
    reg         mosi_stub;
    reg         miso_stub;

    wire        ss, tip, receive_data;
    wire [3:0]  bit_index;
    wire [11:0] count_debug, target_debug, tcv;

    spi_slave_control_select dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .mstr(mstr),
        .spiswai(spiswai),
        .spi_mode(spi_mode),
        .send_data(send_data),
        .BaudRateDivisor(BaudRateDivisor),
        .sclk_stub(sclk_stub),
        .mosi_stub(mosi_stub),
        .miso_stub(miso_stub),
        .ss(ss),
        .tip(tip),
        .receive_data(receive_data),
        .bit_index(bit_index),
        .count_debug(count_debug),
        .target_debug(target_debug),
        .tcv(tcv)
    );

    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    initial begin
        sclk_stub = 0;
        forever #20 sclk_stub = ~sclk_stub;
    end

    initial begin
        // 10101010 pattern on MOSI
        mosi_stub = 1;
        forever begin
            #40 mosi_stub = ~mosi_stub;
        end
    end

    initial begin
        // 11001100 pattern on MISO
        miso_stub = 1;
        forever begin
            #80 miso_stub = ~miso_stub;
        end
    end

    initial begin
        $dumpfile("spi_slave_control_select.vcd");
        $dumpvars(0, tb_spi_slave_control_select);
        $dumpvars(0, sclk_stub, mosi_stub, miso_stub);

        PRESETn = 0;
        mstr = 0;
        spiswai = 0;
        spi_mode = 2'b00;
        send_data = 0;
        BaudRateDivisor = 12'd100; // Wider clock cycle for visibility

        #20;
        PRESETn = 1;
        #20;

        // Begin transfer (Mode 0)
        mstr = 1;
        spi_mode = 2'b00;
        send_data = 1; #10 send_data = 0;

        #2000; // allow full 8-bit transaction to complete

        $finish;
    end
endmodule
