// --- PROCEDURA PER CSV ---
save_for_python := procedure(q, M, m2, m4, m6, percentage_even, csv_filename)
    F := Open(csv_filename, "a");
    punti := [Integers() | M[1,i] : i in [1..Ncols(M)]];
    freq := [Integers() | M[2,i] : i in [1..Ncols(M)]];
    
    // Si usa %m per stampare le liste compatte senza andare a capo
    fprintf F, "%o;%m;%m;%o;%o;%o;%o\n", q, punti, freq, RealField(5)!m2, RealField(5)!m4, RealField(5)!m6, RealField(5)!percentage_even;
    delete F;
end procedure;

counthyperelliptic := procedure(q,text_filename)
// Insiemi di supporto
    FF := FiniteField(q);q_real := Real(q);
    scale := Sqrt(q_real);
    mean_theoretical := q_real + 1;

    m2 := 0.0; m4 := 0.0; m6 := 0.0; // Momenti pari
    
    // Matrice output 
    M := ZeroMatrix(Integers(), 2, 2*q+3);
    for i in [1..2*q+3] do M[1,i] := i-1; end for;

    R<t> := PolynomialRing(FF); // Per discriminante comodo

    for a,b,c in FF do
        C := HyperellipticCurveFromG2Invariants([FF|a,b,c]);
        C2 := QuadraticTwist(C);
        J := Jacobian(C);
        J2 := Jacobian(C2);
        ptsJ := Order(J : UseGenus2 := true);
        ptsJ2 := Order(J2 : UseGenus2 := true);
        trC := (ptsJ2 - ptsJ) div (2*(q+1));
        ptsC := q + 1 - trC;
        ptsC2 := q + 1 + trC;
        indexC := ptsC + 1;
        indexC2 := ptsC2 + 1;
        M[2, indexC] +:= 1;
        M[2, indexC2] +:= 1;
        X := (RealField()!ptsC - mean_theoretical) / scale;
        X_C2 := (RealField()!ptsC2 - mean_theoretical) / scale;

        X_sq := X^2;
        X_C2_sq := X_C2^2;

        m2 +:= (X_sq + X_C2_sq);
        m4 +:= (X_sq^2 + X_C2_sq^2);
        m6 +:= (X_sq^3 + X_C2_sq^3);
    end for;



// --- FINE CONTEGGI E CALCOLO STATISTICHE ---
    tot_curves := &+[M[2][i] : i in [1..Ncols(M)]];
    m2_avg := m2 / tot_curves;
    m4_avg := m4 / tot_curves;
    m6_avg := m6 / tot_curves;
    
    // Apriamo il file per il report (argomento della funzione)
    F_text := Open(text_filename, "a");
    
    if tot_curves gt 0 then
        even_curves := &+[M[2,i] : i in [1..Ncols(M)] | IsEven(M[1,i])];
        percentage_even := even_curves / tot_curves * 100;
        
        // 1. Scrittura su Report (.txt)
        fprintf F_text, "\n========================================\n";
        fprintf F_text, "RISULTATI PER CAMPO q = %o\n", q;
        fprintf F_text, "========================================\n";
        fprintf F_text, "Totale curve: %o\n", tot_curves;
        fprintf F_text, "Percentuale pari: %o %%\n", Real(percentage_even);
        fprintf F_text, "Momento m2 (varianza): %o\n", Real(m2_avg);
        fprintf F_text, "Momento m4: %o\n", Real(m4_avg);
        fprintf F_text, "Momento m6: %o\n", Real(m6_avg);
        fprintf F_text, "--- Distribuzione ---\n";
        // Stampiamo solo i non-zeri nel report per leggibilità
        for i in [1..Ncols(M)] do
            if M[2,i] ne 0 then
                 fprintf F_text, "%o : %o\n", M[1,i], M[2,i];
            end if;
        end for;
        fprintf F_text, "----------------------------------------\n";

        // 2. Scrittura su CSV per Python (File fisso)
        save_for_python(q, M, m2_avg, m4_avg, m6_avg, percentage_even, "iperellittiche2_dati.csv");

    else
        fprintf F_text, "Nessuna curva trovata per q=%o\n", q;
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