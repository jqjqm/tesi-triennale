// --- PROCEDURA PER CSV ---
save_for_python := procedure(q, freq, m2, m4, m6, perc_even)
    csv_filename := "dati_per_plot_iperellittiche_mc.csv";
    F := Open(csv_filename, "a");
    

    momenti_str := Sprintf("%o,%o,%o", 
                   RealField(5)!m2, 
                   RealField(5)!m4, 
                   RealField(5)!m6);
    
    fprintf F, "%o;%o;%o;%o\n", 
              q, 
              [i-1 : i in [1..#freq]],  // punti
              freq,                     // frequenze
              momenti_str;              // momenti
    
    delete F;
end procedure;

counthyperelliptic := procedure(q,N,text_filename)
    FF := FiniteField(q);
    q_real := Real(q);
    scale := Sqrt(q_real);
    mean_theoretical := q_real + 1;
    
    // Array di frequenze: indice 0..2q+2 (2q+3 elementi)
    freq := [0 : i in [1..2*q+3]];

    m2 := 0.0; m4 := 0.0; m6 := 0.0; // Momenti pari

    R<x> := PolynomialRing(FF);

    count := 0;
    while count lt N do 
        // Campionamento proporzionale: ogni polinomio monico ha stessa probabilità
        if Random(q^5 + q^6) lt q^5 then
            f := x^5 + &+[Random(FF)*x^i : i in [0..4]];
            pts := 1;
        else
            f := x^6 + &+[Random(FF)*x^i : i in [0..5]];
            pts := 2;
        end if;
        
        if Discriminant(f) ne 0 then
            count +:= 1;
            
            // Conta punti affini
            for x_val in FF do
                val := Evaluate(f, x_val);
                if val eq 0 then
                    pts +:= 1;
                elif IsSquare(val) then
                    pts +:= 2;
                end if;
            end for;
            
            pts_twist := 2*q + 2 - pts;
            
            freq[pts+1] +:= 1;
            freq[pts_twist+1] +:= 1;
            
            // Calcola X' normalizzato
            X := (RealField()!pts - mean_theoretical) / scale;
            X_twist := (RealField()!pts_twist - mean_theoretical) / scale;

            X_sq := X^2;
            X_twist_sq := X_twist^2;

            m2 +:= X_sq + X_twist_sq;
            m4 +:= X_sq^2 + X_twist_sq^2;
            m6 +:= X_sq^3 + X_twist_sq^3;
        end if;
    end while;

    // Calcola statistiche
    m2_avg := m2 / (2*N);
    m4_avg := m4 / (2*N);
    m6_avg := m6 / (2*N);
    
    even_curves := &+[freq[i] : i in [1..2*q+3] | IsEven(i-1)];
    perc_even := 100.0 * even_curves / (2*N);

    // --- OUTPUT ---
    F_text := Open(text_filename, "a");
    
    Puts(F_text, "\n========================================");
    fprintf F_text, "q = %o\n", q;
    Puts(F_text, "========================================");
    
    fprintf F_text, "Totale curve: %o\n", 2*N;
    fprintf F_text, "Percentuale pari: %o%%\n", RealField(5)!perc_even;
    
    Puts(F_text, "\n--- Momenti normalizzati ---");
    fprintf F_text, "m2 (varianza): %o\n", RealField(5)!m2_avg;
    fprintf F_text, "m4: %o\n", RealField(5)!m4_avg;
    fprintf F_text, "m6: %o\n", RealField(5)!m6_avg;
    
    Puts(F_text, "\n--- Distribuzione ---");
    for i in [1..2*q+3] do
        if freq[i] ne 0 then
            fprintf F_text, "%o: %o\n", i, freq[i];
        end if;
    end for;
    
    delete F_text;

    // CSV per Python
    save_for_python(q, freq, m2_avg, m4_avg, m6_avg, perc_even);
    
    printf "Finito q = %o\n", q;
end procedure;

// --- ESECUZIONE ---
if assigned q then
    counthyperelliptic(StringToInteger(q), StringToInteger(N), "report_iperellittiche_mc.txt");
end if;

quit;
