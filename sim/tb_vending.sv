module tb_vending;
    import vending_pkg::*;

    logic [1:0] coin_in, sel_item;
    logic confirm, cancel, clk, rst;
    logic dispense, error;
    logic [7:0] change_out, display;
    logic [2:0] state_out;

    localparam logic [1:0] N    = 2'b00;
    localparam logic [1:0] C25  = 2'b01;
    localparam logic [1:0] C50  = 2'b10;
    localparam logic [1:0] C100 = 2'b11;
    localparam int MAX_WAIT = 30;

    int pass_count, fail_count;
    bit lint_dummy;

    vending_top dut (
        .coin_in(coin_in), .sel_item(sel_item), .confirm(confirm), .cancel(cancel),
        .clk(clk), .rst(rst), .dispense(dispense), .change_out(change_out),
        .error(error), .display(display), .state_out(state_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, tb_vending);
    end


    function automatic int coin_val(input logic [1:0] coin);
        case (coin)
            C25:     coin_val = 25;
            C50:     coin_val = 50;
            C100:    coin_val = 100;
            default: coin_val = 0;
        endcase
    endfunction

    function automatic string money(input int cents);
        money = $sformatf("R$%0d,%02d", cents/100, cents%100);
    endfunction

    function automatic string item_name(input logic [1:0] item);
        case (item)
            2'd0: item_name = "Cafe";
            2'd1: item_name = "Agua";
            2'd2: item_name = "Suco";
            2'd3: item_name = "Snack";
            default: item_name = "Inv";
        endcase
    endfunction

    function automatic int price_of(input logic [1:0] item);
        case (item)
            2'd0: price_of = 25;
            2'd1: price_of = 50;
            2'd2: price_of = 75;
            2'd3: price_of = 100;
            default: price_of = 0;
        endcase
    endfunction

    function automatic string st_name(input logic [2:0] st);
        case (st)
            IDLE:     st_name = "IDLE";
            COLLECT:  st_name = "COLLECT";
            CHECK:    st_name = "CHECK";
            DISPENSE: st_name = "DISPENSE";
            CHANGE:   st_name = "CHANGE";
            ERROR:    st_name = "ERROR";
            default:  st_name = "UNK";
        endcase
    endfunction

    task automatic title(input string txt);
        begin
            $display("\n==================================================");
            $display("%s", txt);
            $display("==================================================");
        end
    endtask

    task automatic show(input string txt);
        $display("%-14s estado=%-8s credit=%s troco=%s disp=%0b err=%0b",
                 txt, st_name(state_out), money(dut.credit), money(change_out),
                 dispense, error);
    endtask

    task automatic nclk(); @(negedge clk) lint_dummy = lint_dummy; endtask
    task automatic pclk(); @(posedge clk) lint_dummy = lint_dummy; endtask
    task automatic dly();  #1 lint_dummy = lint_dummy; endtask

    task automatic check(input logic [31:0] exp, input logic [31:0] got, input string msg);
        if (got === exp) begin
            pass_count++;
            $display("[PASS] %s", msg);
        end else begin
            fail_count++;
            $display("[FAIL] %s | esperado=%0d obtido=%0d", msg, exp, got);
        end
    endtask

    task automatic reset_dut();
        begin
            coin_in=N; sel_item=0; confirm=0; cancel=0; rst=1;
            repeat (2) nclk();
            rst=0;
            nclk(); dly();
            show("Reset");
        end
    endtask

    task automatic put_coin(input logic [1:0] coin);
        begin
            nclk();
            coin_in = coin;
            $display("Moeda: coin_in=%b (%s)", coin, money(coin_val(coin)));
            nclk();
            coin_in = N;
            dly();
            show("Apos moeda");
        end
    endtask

    task automatic do_confirm(input logic [1:0] item);
        begin
            nclk();
            sel_item = item;
            confirm = 1;
            $display("Confirmar: %s | preco=%s", item_name(item), money(price_of(item)));
            nclk();
            confirm = 0;
            dly();
            show("Apos confirm");
        end
    endtask

    task automatic do_cancel();
        begin
            nclk();
            cancel = 1;
            $display("Cancelamento solicitado.");
            nclk();
            cancel = 0;
            dly();
            show("Apos cancel");
        end
    endtask

    task automatic wait_state(input logic [2:0] st, input string msg);
        int i;
        begin
            dly();
            for (i = 0; (state_out !== st) && (i < MAX_WAIT); i++) begin
                pclk(); dly();
            end

            if (state_out === st) begin
                pass_count++;
                $display("[PASS] %s | estado=%s", msg, st_name(state_out));
            end else begin
                fail_count++;
                $display("[FAIL] %s | esperado=%s obtido=%s", msg, st_name(st), st_name(state_out));
            end

            show("Status");
        end
    endtask

    task automatic buy_one_coin(input logic [1:0] item, input logic [1:0] coin);
        begin
            $display("\nCompra: %s | preco=%s | moeda=%s",
                     item_name(item), money(price_of(item)), money(coin_val(coin)));
            sel_item = item;
            put_coin(coin);
            do_confirm(item);
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;
        lint_dummy = 0;
        coin_in=N; sel_item=0; confirm=0; cancel=0; rst=0;

        title("CENARIO 1 - Compra com troco");
        $display("Cafe R$0,25 + moeda R$1,00 => troco R$0,75");
        reset_dut();
        buy_one_coin(2'd0, C100);
        wait_state(DISPENSE, "C1: chegou em DISPENSE");
        check(32'd1, {31'd0, dispense}, "C1: dispense=1");
        wait_state(CHANGE, "C1: chegou em CHANGE");
        check(32'd75, {24'd0, change_out}, "C1: change_out=75");
        wait_state(IDLE, "C1: voltou para IDLE");
        check(32'd0, {24'd0, dut.credit}, "C1: credito=0");

        title("CENARIO 2 - Credito insuficiente");
        $display("Snack R$1,00 + moeda R$0,25 => ERROR");
        reset_dut();
        buy_one_coin(2'd3, C25);
        wait_state(ERROR, "C2: chegou em ERROR");
        check(32'd1, {31'd0, error}, "C2: error=1");

        title("CENARIO 3 - Cancelamento");
        $display("Inserir R$1,00 + R$1,00 e cancelar => devolucao R$2,00");
        reset_dut();
        put_coin(C100);
        put_coin(C100);
        check(32'd200, {24'd0, dut.credit}, "C3: credito antes do cancel=200");
        do_cancel();
        check(32'd0, {24'd0, dut.credit}, "C3: credito=0");
        check({29'd0, IDLE}, {29'd0, state_out}, "C3: estado=IDLE");
        check(32'd200, {24'd0, change_out}, "C3: change_out=200");

        title("CENARIO 4 - Estoque zerado");
        $display("Comprar cafe 5 vezes. Na 6a tentativa deve dar ERROR.");
        reset_dut();

        for (int i = 0; i < 5; i++) begin
            $display("\nCafe %0d/5 | estoque antes=%0d", i+1, dut.memoria_inst.mem[0][7:0]);
            buy_one_coin(2'd0, C25);
            wait_state(DISPENSE, $sformatf("C4.%0d: DISPENSE", i+1));
            wait_state(IDLE,     $sformatf("C4.%0d: IDLE", i+1));
            check((32'd4 - i), {24'd0, dut.memoria_inst.mem[0][7:0]},
                  $sformatf("C4.%0d: estoque atualizado", i+1));
        end

        check(32'd0, {24'd0, dut.memoria_inst.mem[0][7:0]}, "C4: estoque=0");

        $display("\nTentando 6a compra de cafe...");
        buy_one_coin(2'd0, C25);
        wait_state(ERROR, "C4.6: chegou em ERROR");
        check(32'd1, {31'd0, error}, "C4.6: error=1");
        check(32'd0, {24'd0, dut.memoria_inst.mem[0][7:0]}, "C4.6: estoque permaneceu 0");

        title("RESUMO");
        $display("PASS=%0d | FAIL=%0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("RESULTADO FINAL: TODOS OS TESTES PASSARAM");
        else
            $display("RESULTADO FINAL: EXISTEM FALHAS NO RTL");

        $finish;
    end
endmodule

