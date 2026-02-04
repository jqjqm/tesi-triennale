// Distribuzione punti F_q-razionali di curve ellittiche.

save_for_python := procedure(q, M, mean, perc_even, csv_filename)
    F := Open(csv_filename, "a");
    punti := [Integers() | M[1,i] : i in [1..Ncols(M)]];
    freq := [Integers() | M[2,i] : i in [1..Ncols(M)]];
    
    fprintf F, "%o;%o;%o;%o;%o\n", q, punti, freq, RealField(5)!mean, RealField(5)!perc_even;
    delete F;
end procedure;

counting := procedure(q, text_filename)
    // Setup iniziale dato dal bound di Hasse.
    lower := Ceiling(q+1-2*Sqrt(q));
    upper := Floor(q+1+2*Sqrt(q));
    N := upper - lower + 1;

    // Inizializza matrice per conteggi
    M := ZeroMatrix(Integers(), 2, N);
    for i in [1..N] do
        M[1,i] := lower+i-1;
    end for;    

    // Insiemi di supporto
    FF := FiniteField(q);
    g := PrimitiveElement(FF);
    // Precalcolo potenze
    g2 := g^2;

    if q mod 2 ne 0 then
        for j in FF do
            if j ne 0 and j ne 1728 then
                E := EllipticCurve([FF|0,1/4,0,-36/(j-1728), -1/(j-1728)]);
                t := TraceOfFrobenius(E);
                total := q + 1 - t;
                idx := total - lower + 1;
                M[2, idx] +:= (q-1) div 2;
                total_twist := q + 1 + t;
                idx_twist := total_twist - lower + 1;
                M[2, idx_twist] +:= (q-1) div 2;
            elif j eq 1728  then
                E1 := EllipticCurve([FF|0,0,0,1,0]);
                t := TraceOfFrobenius(E1);
                total := q + 1 - t;
                idx := total - lower + 1;
                M[2, idx] +:= (q-1) div 2;
                total_twist := q + 1 + t;
                idx_twist := total_twist - lower + 1;
                M[2, idx_twist] +:= (q-1) div 2;
                if q mod 4 eq 1 then
                    M[2, idx] := M[2, idx] div 2;
                    M[2, idx_twist] := M[2, idx_twist] div 2;
                    E2 := EllipticCurve([FF|0,0,0,g,0]);
                    t2 := TraceOfFrobenius(E2);
                    total2 := q + 1 - t2;
                    idx2 := total2 - lower + 1;
                    M[2, idx2] +:= (q-1) div 4;
                    total_twist2 := q + 1 + t2;
                    idx_twist2 := total_twist2 - lower + 1;
                    M[2, idx_twist2] +:= (q-1) div 4;
                end if;
            elif j eq 0 and q mod 3 ne 0 then
                E1 := EllipticCurve([FF|0,0,0,0,1]);
                t := TraceOfFrobenius(E1);
                total := q + 1 - t;
                idx := total - lower + 1;
                M[2, idx] +:= (q-1) div 2;
                total_twist := q + 1 + t;
                idx_twist := total_twist - lower + 1;
                M[2, idx_twist] +:= (q-1) div 2;
                if q mod 3 eq 1 then
                    M[2, idx] := M[2, idx] div 3;
                    M[2, idx_twist] := M[2, idx_twist] div 3;
                    E2 := EllipticCurve([FF|0,0,0,0,g]);
                    t2 := TraceOfFrobenius(E2);
                    total2 := q + 1 - t2;
                    idx2 := total2 - lower + 1;
                    M[2, idx2] +:= (q-1) div 6;
                    total_twist2 := q + 1 + t2;
                    idx_twist2 := total_twist2 - lower + 1;
                    M[2, idx_twist2] +:= (q-1) div 6;
                    E3 := EllipticCurve([FF|0,0,0,0,g2]);
                    t3 := TraceOfFrobenius(E3);
                    total3 := q + 1 - t3;
                    idx3 := total3 - lower + 1;
                    M[2, idx3] +:= (q-1) div 6;
                    total_twist3 := q + 1 + t3;
                    idx_twist3 := total_twist3 - lower + 1;
                    M[2, idx_twist3] +:= (q-1) div 6;
                end if;
            end if;
        end for;
    else 
        // Forma generale lunga Weierstrass:    
        for a_1,a_2,a_3,a_4,a_6 in FF do
            is_smooth:= true;
            if a_1 eq 0 then
                if a_3 eq 0 then
                    is_smooth := false;
                end if;
            else 
                x_s := a_3/a_1;
                y_s := (x_s^2+a_4)/a_1;
                if (y_s^2 + a_1*x_s*y_s + a_3*y_s) eq (x_s^3 + a_2*x_s^2 + a_4*x_s + a_6) then
                    is_smooth := false;
                end if;
            end if;
            if is_smooth then
                
                pts := 0;
                
                for x_val in FF do
                    for y_val in FF do
                        // f(x,y)
                        lhs := y_val^2 + a_1*x_val*y_val + a_3*y_val;
                        rhs := x_val^3 + a_2*x_val^2 + a_4*x_val + a_6;
                        if lhs eq rhs then
                             pts +:= 1;
                        end if;
                    end for;
                end for;

                total := pts+1;
                idx := total - lower + 1;
                M[2,idx] +:=1;
            end if;
        end for;
    end if;

// --- FINE CONTEGGI E CALCOLO STATISTICHE ---
    tot_curves := &+[M[2][i] : i in [1..Ncols(M)]];
    
    // Apriamo il file per il report (argomento della funzione)
    F_text := Open(text_filename, "a");
    
    if tot_curves gt 0 then
        mean := (&+[ M[1][i]*M[2][i] : i in [1..Ncols(M)]])/tot_curves;
        even_curves := &+[M[2][i] : i in [1..Ncols(M)] | IsEven(M[1][i])];
        percentage_even := even_curves / tot_curves * 100;
        
        // 1. Scrittura su Report (.txt)
        Puts(F_text, "\n========================================");
        fprintf F_text, "RISULTATI PER CAMPO q = %o\n", q;
        Puts(F_text, "========================================");
        fprintf F_text, "Totale curve: %o\n", tot_curves;
        fprintf F_text, "Media punti: %o\n", RealField(5)!mean;
        fprintf F_text, "Percentuale pari: %o %%\n", RealField(5)!percentage_even;
        Puts(F_text, "--- Distribuzione ---");
        // Stampiamo solo i non-zeri nel report per leggibilità
        for i in [1..Ncols(M)] do
            if M[2,i] ne 0 then
                 fprintf F_text, "%o : %o\n", M[1,i], M[2,i];
            end if;
        end for;
        Puts(F_text, "----------------------------------------\n");

        save_for_python(q, M, mean, percentage_even, "dati_per_plot_ellittiche2.csv");
        
    else
        Puts(F_text, "Nessuna curva trovata per q=" cat IntegerToString(q));
    end if;
    
    delete F_text; // Chiude il report
    print "Finito q =", q;

end procedure;

// --- ESECUZIONE ---
if assigned q then
    // Il CSV viene generato automaticamente con nome fisso dentro la procedura.
    counting(StringToInteger(q), "report_ellittiche2.txt");
end if;
quit;
