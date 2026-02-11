// --- PROCEDURA PER CSV ---
save_for_python := procedure(q, freq, m1, m2, m3, m4, m5, m6, variance, perc_even)
    csv_filename := "quartiche_piane_dati.csv";
    F := Open(csv_filename, "a");
    
    // Formatta i momenti
    momenti_str := Sprintf("%o,%o,%o,%o,%o,%o,%o", 
                   RealField(5)!m1,
                   RealField(5)!m2,
                   RealField(5)!m3, 
                   RealField(5)!m4,
                   RealField(5)!m5, 
                   RealField(5)!m6,
                   RealField(5)!variance);
    
    // Scrive: q; punti...; freq...; momenti...
    fprintf F, "%o;%o;%o;%o\n", 
              q, 
              [i-1 : i in [1..#freq]],  // punti (indice 1 -> 0 punti)
              freq,                     // frequenze
              momenti_str;              // momenti
    
    delete F;
end procedure;

counting := procedure(q, N, text_filename)
    FF := FiniteField(q);
    q_real := Real(q);
    scale := Sqrt(q_real);
    
    freq := [0 : i in [1..4*q+6]]; 

    m := [0.0 : i in [1..6]]; // Accumulatore Momenti

    R<t> := PolynomialRing(FF);         
    R_aff<x,y> := PolynomialRing(FF, 2); 

    Monomi_Affini := [
        x^4,       // a0
        x^3*y,     // a1
        x^3,       // a2 (Z=1)
        x^2*y^2,   // a3
        x^2*y,     // a4 (Z=1)
        x^2,       // a5 (Z^2=1)
        x*y^3,     // a6
        x*y^2,     // a7 (Z=1)
        x*y,       // a8 (Z^2=1)
        x,         // a9 (Z^3=1)
        y^4,       // a10
        y^3,       // a11 (Z=1)
        y^2,       // a12 (Z^2=1)
        y,         // a13 (Z^3=1)
        R_aff!1    // a14
    ];

    count := 0;
    print "Inizio calcolo per q =", q;

    while count lt N do
        A := [Random(FF) : i in [1..15]];
        
        // Check rapido punto [1:0:0]
        if A[1] eq 0 and A[2] eq 0 and A[3] eq 0 then
            continue;
        end if;

        // --- CHECK INFINITO ---
        F_inf := A[1]*t^4 + A[2]*t^3 + A[4]*t^2 + A[7]*t + A[11];
        F_infX := 4*A[1]*t^3 + 3*A[2]*t^2 + 2*A[4]*t + A[7];
        
        g := Gcd(F_inf, F_infX);
        if Degree(g) gt 0 then
            F_infZ := A[3]*t^3 + A[5]*t^2 + A[8]*t + A[12];
            g2 := Gcd(g, F_infZ); // Basta fare il gcd con g, è più veloce
            if Degree(g2) gt 0 then
                continue; // Singolare all'infinito
            end if;
        end if;

        // --- CHECK AFFINE ---
        f_aff := &+[ A[i] * Monomi_Affini[i] : i in [1..15] ];
        df_dx := Derivative(f_aff, 1); 
        df_dy := Derivative(f_aff, 2); 
        
        I := ideal< R_aff | f_aff, df_dx, df_dy >;
        
        if not (1 in I) then
            continue; // Singolare affine
        end if;

        // --- CONTEGGIO PUNTI ---
        count +:= 1;
        pts := 0;

        // 1. Punti all'infinito (sulla carta Y=1, Z=0)
        // Usiamo Modexp su anello univariato R<t>
        h := Modexp(t, q, F_inf);
        pts +:= Degree(Gcd(F_inf, h - t));
        
        // 2. Punto [1:0:0] (Y=0, Z=0)
        if A[1] eq 0 then
            pts +:= 1;
        end if;

        // 3. Punti Affini
        // Iteriamo su y. Per ogni valore, otteniamo un poli in x.
        for y0 in FF do
            // Valutiamo f_aff in y=y0. 
            // ATTENZIONE: Evaluate restituisce un poli in R_aff. 
            // Dobbiamo convertirlo in R<t> per usare Modexp e Gcd efficienti.
            
            f_val_multi := Evaluate(f_aff, [x, y0]); // Resta in R_aff
            
            
            coeffs := Coefficients(f_val_multi, x); 
            f_univar := Polynomial(R, coeffs); // Ora è in R<t>
            
            if Degree(f_univar) gt 0 then
                h2 := Modexp(t, q, f_univar); // t è il generatore di R
                pts +:= Degree(Gcd(f_univar, h2 - t));
            end if;
        end for;
        
        // Aggiorna istogramma
        if (pts + 1) le #freq then
            freq[pts + 1] +:= 1;
        end if;

        // --- MOMENTI ---
        // Il valore normalizzato è z = t_frob / sqrt(q)
        
        trace := q_real + 1.0 - RealField()!pts;
        z := trace / scale;
        
        for i in [1..6] do
            m[i] +:= z^i;
        end for;
    end while;

    // Medie finali
    perc_even := 100.0 * (&+[freq[i] : i in [1..#freq] | IsEven(i-1)]) / N;
    m_avg := [m[i] / N : i in [1..6]];
    variance := m_avg[2] - m_avg[1]^2;

    // --- OUTPUT TESTO ---
    F_text := Open(text_filename, "a");
    
    Puts(F_text, "\n========================================");
    fprintf F_text, "q = %o\n", q;
    Puts(F_text, "========================================");
    
    fprintf F_text, "Totale curve: %o\n", N;
    fprintf F_text, "Percentuale pari: %o%%\n", RealField(5)!perc_even;
    
    Puts(F_text, "\n--- Momenti della Traccia Normalizzata (t/sqrt(q)) ---");
    fprintf F_text, "m1: %o\n", RealField(5)!m_avg[1];
    fprintf F_text, "m2: %o\n", RealField(5)!m_avg[2];
    fprintf F_text, "m3: %o\n", RealField(5)!m_avg[3];
    fprintf F_text, "m4: %o\n", RealField(5)!m_avg[4];
    fprintf F_text, "m5: %o\n", RealField(5)!m_avg[5];
    fprintf F_text, "m6: %o\n", RealField(5)!m_avg[6];
    fprintf F_text, "Varianza: %o\n", RealField(5)!variance;
    
    Puts(F_text, "\n--- Distribuzione Punti ---");
    for i in [1..#freq] do
        if freq[i] ne 0 then
            fprintf F_text, "%o: %o\n", i-1, freq[i];
        end if;
    end for;
    
    delete F_text;

    // CSV per Python
    save_for_python(q, freq, m_avg[1], m_avg[2], m_avg[3], m_avg[4], m_avg[5], m_avg[6], variance, perc_even);
    
    printf "Finito q = %o\n", q;
end procedure;

if assigned q then
    counting(StringToInteger(q), StringToInteger(N), "report_quartiche_piane.txt");
end if;