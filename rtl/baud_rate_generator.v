module baud_rate_generator (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [1:0]  spi_mode,
    input  wire        spiswai,
    input  wire [2:0]  sppr,
    input  wire [2:0]  spr,
    input  wire        cpol,
    input  wire        cpha,
    input  wire        ss,
    output reg         sclk,
    output reg         flag_low,
    output reg         flag_high,
    output reg         flags_low,
    output reg         flags_high,
    output wire [7:0]  BaudRateDivisor
);

    reg [7:0] count;

    assign BaudRateDivisor = (sppr << spr);  // Equivalent to multiplication by power of 2

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            count <= 0;
            sclk <= cpol;
        end else if (!spiswai && !ss) begin
            if (count == BaudRateDivisor - 1) begin
                count <= 0;
                sclk <= ~sclk;
            end else begin
                count <= count + 1;
            end
        end
    end

    always @(*) begin
        flag_low  = (count == (BaudRateDivisor >> 1));
        flag_high = (count == (BaudRateDivisor - 1));
        flags_low  = ~flag_low;
        flags_high = ~flag_high;
    end

endmodule
