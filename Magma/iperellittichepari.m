// --- 1. PROCEDURA PER CSV (DATI PYTHON) ---
save_for_python := procedure(q, M, m2, m4, m6, csv_filename)
    F := Open(csv_filename, "a");
    punti := [Integers() | M[1,i] : i in [1..Ncols(M)]];
    freq := [Integers() | M[2,i] : i in [1..Ncols(M)]];
    
    fprintf F, "%o;%o;%o;%o;%o;%o\n", q, punti, freq, RealField(5)!m2, RealField(5)!m4, RealField(5)!m6;
    delete F;
end procedure;

counthypellpari := procedure(q, text_filename)
    // Richiede q dispari
    if q mod 2 eq 0 then print "Non esistono curve lisce di questo tipo"; return; end if;

    // Insiemi di supporto
    FF := FiniteField(q);
    q_real := Real(q);
    scale := Sqrt(q_real);
    mean_theoretical := q_real + 1;

    m2 := 0.0; m4 := 0.0; m6 := 0.0; // Momenti pari
    
    g := PrimitiveElement(FF);
    d := Gcd(q-1,6);
    L := [g^i : i in [0..d-1]]; // Rappresentanti per i termini noti

    // Bound empirici osservati per la famiglia completa
    lower := Ceiling(q+1-4*Sqrt(q));
    upper := Floor(q+1+4*Sqrt(q));
    if lower mod 2 eq 1 then lower +:= 1; end if; // Primo pari
    if upper mod 2 eq 1 then upper -:= 1; end if;
    N := ((upper - lower) div 2) + 1;


    // Matrice output
    M := ZeroMatrix(Integers(), 2, N);
    for i in [1..N] do M[1,i] := lower + 2*(i-1); end for;

    R<t> := PolynomialRing(FF); // Per discriminante comodo
    
    for a4, a2 in FF do
        for a0 in L do
            f := t^3 + a4*t^2+a2*t + a0; //Questo polinomio è separabile se e solo se lo è t^6 + a4*t^4 + a2*t^2 + a0 ma è più efficiente il calcolo del discriminante.
            if q mod 3 eq 0 and a4 eq 0 and a2 eq 0 then //caso in cui f'(x) è identicamente nulla
                continue;
            else
                if Discriminant(f) ne 0 then
                    E := EllipticCurve([FF| 0, a4, 0 , a2, a0]);
                    t_E := TraceOfFrobenius(E);
                    E2 := EllipticCurve([FF |0, a2, 0, a4*a0, a0^2 ]);
                    t_E2 := TraceOfFrobenius(E2);
                    t_C := t_E + t_E2;
                    pts_C := q + 1 - t_C;
                    pts_C2 := q+1+ t_C;
                    index_C := (pts_C - lower) div 2 + 1;
                    index_C2 := (pts_C2 - lower) div 2 + 1;
                    M[2, index_C] +:= (q-1) div d;
                    M[2, index_C2] +:= (q-1) div d;
                    // Calcola X' normalizzato
                    X := (RealField()!pts_C - mean_theoretical) / scale;
                    X_C2 := (RealField()!pts_C2 - mean_theoretical) / scale;

                    X_sq := X^2;
                    X_C2_sq := X_C2^2;

                    m2 +:= (q-1) div d * (X_sq + X_C2_sq);
                    m4 +:= (q-1) div d * (X_sq^2 + X_C2_sq^2);
                    m6 +:= (q-1) div d * (X_sq^3 + X_C2_sq^3);
                end if;
            end if;
        end for;
    end for;

// --- FINE CONTEGGI E CALCOLO STATISTICHE ---
    tot_curves := &+[M[2][i] : i in [1..Ncols(M)]];
    m2_avg := m2 / tot_curves;
    m4_avg := m4 / tot_curves;
    m6_avg := m6 / tot_curves;
    
    // Apriamo il file per il report (argomento della funzione)
    F_text := Open(text_filename, "a");
    
    if tot_curves gt 0 then
        
        // 1. Scrittura su Report (.txt)
        Puts(F_text, "\n========================================");
        fprintf F_text, "RISULTATI PER CAMPO q = %o\n", q;
        Puts(F_text, "========================================");
        fprintf F_text, "Totale curve: %o\n", tot_curves;
        fprintf F_text, "Momento 2 (varianza): %o\n", m2_avg;
        fprintf F_text, "Momento 4: %o\n", m4_avg;
        fprintf F_text, "Momento 6: %o\n", m6_avg;
        Puts(F_text, "--- Distribuzione ---");
        // Stampiamo solo i non-zeri nel report per leggibilità
        for i in [1..Ncols(M)] do
            if M[2,i] ne 0 then
                 fprintf F_text, "%o : %o\n", M[1,i], M[2,i];
            end if;
        end for;
        Puts(F_text, "----------------------------------------\n");

        // 2. Scrittura su CSV per Python (File fisso)
        save_for_python(q, M, m2_avg, m4_avg, m6_avg, "iperellittiche_pari_dati.csv");

    else
        Puts(F_text, "Nessuna curva trovata per q=" cat IntegerToString(q));
    end if;
    
    delete F_text; // Chiude il report
    print "Finito q =", q;

end procedure;

// --- ESECUZIONE ---
if assigned q then
    // Il CSV viene generato automaticamente con nome fisso dentro la procedura.
    counthypellpari(StringToInteger(q), "report_iperellittiche_pari.txt");
end if;

quit;


