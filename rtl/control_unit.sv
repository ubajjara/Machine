import vending_pkg::*;

module control_unit(
    input  logic       clk,
    input  logic       rst,

    input  logic [1:0] coin_in,
    input  logic       confirm,
    input  logic       cancel,
    input  logic       can_sell,

    output logic       credit_load,
    output logic       credit_clear,
    output logic       mem_read,
    output logic       mem_write,
    output logic       dispense,
    output logic       error,
    output logic [2:0] state_out
);

    state_t state, next_state;

    // Usado para esperar 1 ciclo da leitura síncrona da memória no estado CHECK
    logic check_ready;

    always_ff @(posedge clk) begin
        if (rst) begin
            state       <= IDLE;
            check_ready <= 1'b0;
        end else if (cancel) begin
            state       <= IDLE;
            check_ready <= 1'b0;
        end else begin
            state <= next_state;

            if (state == CHECK)
                check_ready <= 1'b1;
            else
                check_ready <= 1'b0;
        end
    end

    always_comb begin
        next_state = state;

        case (state)

            IDLE: begin
                if (coin_in != 2'b00)
                    next_state = COLLECT;
                else
                    next_state = IDLE;
            end

            COLLECT: begin
                if (confirm)
                    next_state = CHECK;
                else
                    next_state = COLLECT;
            end

            CHECK: begin
                if (!check_ready) begin
                    next_state = CHECK;
                end else begin
                    if (can_sell)
                        next_state = DISPENSE;
                    else
                        next_state = ERROR;
                end
            end

            DISPENSE: begin
                next_state = CHANGE;
            end

            CHANGE: begin
                next_state = IDLE;
            end

            ERROR: begin
                if (cancel)
                    next_state = IDLE;
                else
                    next_state = ERROR;
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    always_comb begin
        credit_load  = 1'b0;
        credit_clear = 1'b0;
        mem_read     = 1'b0;
        mem_write    = 1'b0;
        dispense     = 1'b0;
        error        = 1'b0;

        case (state)

            IDLE: begin
                if (coin_in != 2'b00)
                    credit_load = 1'b1;
            end

            COLLECT: begin
                if (coin_in != 2'b00)
                    credit_load = 1'b1;
            end

            CHECK: begin
                mem_read = 1'b1;
            end

            DISPENSE: begin
                dispense  = 1'b1;
                mem_write = 1'b1;
            end

            CHANGE: begin
                credit_load  = 1'b1;
                credit_clear = 1'b1;
            end

            ERROR: begin
                error = 1'b1;
            end

            default: begin
                credit_load  = 1'b0;
                credit_clear = 1'b0;
                mem_read     = 1'b0;
                mem_write    = 1'b0;
                dispense     = 1'b0;
                error        = 1'b0;
            end

        endcase

        if (cancel) begin
            credit_clear = 1'b1;
        end
    end

    assign state_out = state;

endmodule