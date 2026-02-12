// --- 1. PROCEDURA PER CSV (DATI PYTHON) ---
save_for_python := procedure(q, M, perc_even, csv_filename)
    F := Open(csv_filename, "a");
    punti := [Integers() | M[1,i] : i in [1..Ncols(M)]];
    freq := [Integers() | M[2,i] : i in [1..Ncols(M)]];
    
    fprintf F, "%o;%o;%o;%o\n", q, punti, freq, RealField(5)!perc_even;
    delete F;
end procedure;

counthyperelliptic := procedure(q,text_filename)
// Insiemi di supporto
    FF := FiniteField(q);
    
    // Matrice output 
    M := ZeroMatrix(Integers(), 2, 2*q+3);
    for i in [1..2*q+3] do M[1,i] := i-1; end for;

    R<t> := PolynomialRing(FF); // Per discriminante comodo

    // CASO 1 a_6 = 0, a_5 != 0
    if q mod 5 ne 0 then //Forma depressa
    
        for a3,a2,a1,a0 in FF do
            poly_t := t^5 + a3*t^3 + a2*t^2 + a1*t + a0;
            if Discriminant(poly_t) ne 0 then
                pts := 1; //a6=0->1 punto all'infinito
                for x_val in FF do
                    val := Evaluate(poly_t, x_val);
                    if val eq 0 then
                        pts +:= 1;
                    elif IsSquare(val) then
                        pts +:= 2;
                    end if;
                end for;
                M[2, pts+1] +:= 1;
                M[2, 2*q+3-pts] +:= 1; // Twist quadratico
            end if;
        end for;
        
    else
    
        for a4,a3,a2,a1,a0 in FF do //Forma completa
            poly_t := t^5 + a4*t^4 + a3*t^3 + a2*t^2 + a1*t + a0;
            if Discriminant(poly_t) ne 0 then
                pts := 1; //a6=0->1 punto all'infinito
                for x_val in FF do
                    val := Evaluate(poly_t, x_val);
                    if val eq 0 then
                        pts +:= 1;
                    elif IsSquare(val) then
                        pts +:= 2;
                    end if;
                end for;
                M[2, pts+1] +:= 1;
                M[2, 2*q+3-pts] +:= 1;
            end if;
        end for;
    end if;

    // CASO 2 a_6 != 0
    if q mod 2 ne 0 and q mod 3 ne 0 then
    
        for a4,a3,a2,a1,a0 in FF do //Forma depressa
            poly_t := t^6 + a4*t^4 + a3*t^3 + a2*t^2 + a1*t + a0;
            if Discriminant(poly_t) ne 0 then
                pts := 2; //a6=1, a6 quadrato-> 2 punti all'infinito
                for x_val in FF do
                    val := Evaluate(poly_t, x_val);
                    if val eq 0 then
                        pts +:= 1;
                    elif IsSquare(val) then
                        pts +:= 2;
                    end if;
                end for;
                M[2, pts+1] +:= 1;
                M[2, 2*q+3-pts] +:= 1;
            end if;
        end for;
        
    else
    
        for a5,a4,a3,a2,a1,a0 in FF do //Forma completa
            poly_t := t^6 + a5*t^5 + a4*t^4 + a3*t^3 + a2*t^2 + a1*t + a0;
            if Discriminant(poly_t) ne 0 then
                pts := 2; //a6=1, a6 quadrato-> 2 punti all'infinito
                for x_val in FF do
                    val := Evaluate(poly_t, x_val);
                    if val eq 0 then
                        pts +:= 1;
                    elif IsSquare(val) then
                        pts +:= 2;
                    end if;
                end for;
                M[2, pts+1] +:= 1;
                M[2, 2*q+3-pts] +:= 1; 
            end if;
        end for;
    end if;

// --- FINE CONTEGGI E CALCOLO STATISTICHE ---
    tot_curves := &+[M[2][i] : i in [1..Ncols(M)]];
    
    // Apriamo il file per il report (argomento della funzione)
    F_text := Open(text_filename, "a");
    
    if tot_curves gt 0 then
        even_curves := &+[M[2][i] : i in [1..Ncols(M)] | IsEven(M[1][i])];
        percentage_even := even_curves / tot_curves * 100;
        
        // 1. Scrittura su Report (.txt)
        Puts(F_text, "\n========================================");
        fprintf F_text, "RISULTATI PER CAMPO q = %o\n", q;
        Puts(F_text, "========================================");
        fprintf F_text, "Totale curve: %o\n", tot_curves;
        fprintf F_text, "Percentuale pari: %o %%\n", RealField(5)!percentage_even;
        Puts(F_text, "--- Distribuzione ---");
        // Stampiamo solo i non-zeri nel report per leggibilità
        for i in [1..Ncols(M)] do
            if M[2,i] ne 0 then
                 fprintf F_text, "%o : %o\n", M[1,i], M[2,i];
            end if;
        end for;
        Puts(F_text, "----------------------------------------\n");

        // 2. Scrittura su CSV per Python (File fisso)
        save_for_python(q, M, percentage_even, "dati_per_plot_iperellittiche.csv");

    else
        Puts(F_text, "Nessuna curva trovata per q=" cat IntegerToString(q));
    end if;
    
    delete F_text; // Chiude il report 
    print "Finito q =", q;

end procedure;

// --- ESECUZIONE ---
if assigned q then
    // Il CSV viene generato automaticamente con nome fisso dentro la procedura.
    counthyperelliptic(StringToInteger(q), "report_iperellittiche.txt");
end if;

quit;

