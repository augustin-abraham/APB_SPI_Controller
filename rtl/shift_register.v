module shift_register (
    input         PCLK,
    input         PRESETn,
    input         ss,
    input         send_data,
    input         lsbfe,
    input         cpha,
    input         cpol,
    output reg    flag_low,
    output reg    flag_high,
    output reg    flags_low,
    output reg    flags_high,
    input  [7:0]  data_mosi,
    input         miso,
    input         receive_data,
    output        mosi,
    output [7:0]  data_miso,
    output [2:0]  bit_index_debug,  // for waveform debug
    output        sclk_debug        // <-- added for logging sclk
);

    reg [7:0] shift_reg;
    reg [7:0] recv_reg;
    reg [2:0] bit_index;
    reg       sclk;
    reg       shifting;

    reg [1:0] flag_low_cnt;
    reg [1:0] flag_high_cnt;

    assign mosi            = lsbfe ? shift_reg[0] : shift_reg[7];
    assign data_miso       = recv_reg;
    assign bit_index_debug = bit_index;
    assign sclk_debug      = sclk;  // <-- connected sclk to output

    // SCLK generation
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            sclk <= cpol;
        else if (shifting)
            sclk <= ~sclk;
        else
            sclk <= cpol;
    end

    // Shifting logic (unchanged)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            shift_reg      <= 0;
            recv_reg       <= 0;
            bit_index      <= 0;
            shifting       <= 0;
            flag_low       <= 0;
            flag_high      <= 0;
            flags_low      <= 0;
            flags_high     <= 0;
            flag_low_cnt   <= 0;
            flag_high_cnt  <= 0;
        end else begin
            if (flag_low_cnt > 0) begin
                flag_low_cnt <= flag_low_cnt - 1;
                flags_low <= 1;
            end else begin
                flags_low <= 0;
            end

            if (flag_high_cnt > 0) begin
                flag_high_cnt <= flag_high_cnt - 1;
                flags_high <= 1;
            end else begin
                flags_high <= 0;
            end

            if (receive_data) begin
                shift_reg     <= data_mosi;
                recv_reg      <= 0;
                bit_index     <= 0;
                shifting      <= 0;
                flag_low      <= 0;
                flag_high     <= 0;
                flag_low_cnt  <= 0;
                flag_high_cnt <= 0;
            end else if (send_data && !shifting && !ss) begin
                shifting <= 1;
                bit_index <= 0;
                sclk <= cpol ^ cpha;
            end else if (shifting && !ss) begin
                if (sclk == (cpol ^ cpha)) begin
                    if (lsbfe)
                        recv_reg <= {miso, recv_reg[7:1]};
                    else
                        recv_reg <= {recv_reg[6:0], miso};

                    if (lsbfe)
                        shift_reg <= {1'b0, shift_reg[7:1]};
                    else
                        shift_reg <= {shift_reg[6:0], 1'b0};

                    bit_index <= bit_index + 1;

                    if (bit_index == 0) begin
                        flag_low <= 1;
                        flag_low_cnt <= 2;
                    end else begin
                        flag_low <= 0;
                    end

                    if (bit_index == 7) begin
                        flag_high <= 1;
                        flag_high_cnt <= 2;
                        shifting <= 0;
                    end else begin
                        flag_high <= 0;
                    end
                end
            end else begin
                flag_low <= 0;
                flag_high <= 0;
            end
        end
    end

endmodule
