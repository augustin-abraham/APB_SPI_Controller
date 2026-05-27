module apb_slave_interface (
    input PCLK,
    input PRESETn,
    input PWRITE,
    input PSEL,
    input PENABLE,
    input [7:0] PADDR,
    input [7:0] PWDATA,
    input [7:0] tipmiso_data,
    output reg [7:0] PRDATA,
    output reg PREADY,
    output reg PSLVERR,
    output reg wr_enb,
    output reg rd_enb,
    output reg [7:0] miso_data,
    output reg [7:0] txpiso_data,
    output reg send_data,
    output reg [7:0] SPI_CR_1,
    output reg [7:0] SPI_CR_2,
    output reg [7:0] SPI_BR,
    output reg [7:0] SPI_DR
);

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        SPI_CR_1 <= 0;
        SPI_CR_2 <= 0;
        SPI_BR   <= 0;
        SPI_DR   <= 0;
        PRDATA   <= 0;
        PREADY   <= 0;
        PSLVERR  <= 0;
        wr_enb   <= 0;
        rd_enb   <= 0;
        miso_data <= 0;
        txpiso_data <= 0;
        send_data <= 0;
    end else begin
        PREADY <= 0;
        wr_enb <= 0;
        rd_enb <= 0;

        if (PSEL && PENABLE) begin
            PREADY <= 1;

            if (PWRITE) begin
                case (PADDR)
                    8'h00: SPI_CR_1 <= PWDATA;
                    8'h04: SPI_CR_2 <= PWDATA;
                    8'h08: SPI_BR   <= PWDATA;
                    8'h0C: begin
                        SPI_DR   <= PWDATA;
                        txpiso_data <= PWDATA;
                        wr_enb <= 1;
                        send_data <= 1;
                    end
                    default: PSLVERR <= 1;
                endcase
            end else begin
                case (PADDR)
                    8'h00: PRDATA <= SPI_CR_1;
                    8'h04: PRDATA <= SPI_CR_2;
                    8'h08: PRDATA <= SPI_BR;
                    8'h0C: begin
                        PRDATA <= tipmiso_data;
                        miso_data <= tipmiso_data;
                        rd_enb <= 1;
                    end
                    default: PSLVERR <= 1;
                endcase
            end
        end
    end
end

endmodule
