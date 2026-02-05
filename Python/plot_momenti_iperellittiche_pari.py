import matplotlib.pyplot as plt
import os

def plotta_momenti_log(nome_file_csv):
    if not os.path.exists(nome_file_csv):
        print(f"Errore: Il file {nome_file_csv} non esiste.")
        return

    # Liste per i dati
    qs = []
    m2s = []
    m4s = []
    m6s = []

    print(f"Lettura dati da {nome_file_csv} in corso...")
    
    with open(nome_file_csv, 'r') as f:
        for line in f:
            line = line.strip()
            if not line: continue
            
            parti = line.split(';')
            if len(parti) < 6: continue 

            try:
                q_val = int(parti[0])
                m2_val = float(parti[3].replace(',', '.'))
                m4_val = float(parti[4].replace(',', '.'))
                m6_val = float(parti[5].replace(',', '.'))

                qs.append(q_val)
                m2s.append(m2_val)
                m4s.append(m4_val)
                m6s.append(m6_val)
            except ValueError as e:
                continue

    # ORDINAMENTO
    dati_ordinati = sorted(zip(qs, m2s, m4s, m6s))
    
    if not dati_ordinati:
        print("Nessun dato valido trovato.")
        return

    qs = [x[0] for x in dati_ordinati]
    m2s = [x[1] for x in dati_ordinati]
    m4s = [x[2] for x in dati_ordinati]
    m6s = [x[3] for x in dati_ordinati]

    # --- PLOT ---
    plt.figure(figsize=(12, 7))

    # Plot delle linee
    plt.plot(qs, m6s, label='$M_6$', color='green', marker='^', markersize=6, linestyle='-', alpha=0.8)
    plt.plot(qs, m4s, label='$M_4$', color='orange', marker='s', markersize=6, linestyle='-', alpha=0.8)
    plt.plot(qs, m2s, label='$M_2$', color='blue', marker='o', markersize=6, linestyle='-', alpha=0.8)

    # --- MODIFICA LOGARITMICA ---
    plt.xscale('log')
    
    # Cosmesi del Grafico
    plt.title(r'Andamento dei Momenti per $y^2 = f(x^2)$ (Scala Log)', fontsize=14)
    plt.xlabel(r'Cardinalità del campo $q$ (scala log)', fontsize=12)
    plt.ylabel('Valore del Momento', fontsize=12)
    
    plt.legend(loc='best', fontsize=11, framealpha=0.9)
    
    # Grid: 'both' è importante in scala log per vedere le linee secondarie
    plt.grid(True, which='both', linestyle=':', alpha=0.6)
    
    plt.tight_layout()
    
    output_img = "grafico_momenti_pari_log.png"
    plt.savefig(output_img, dpi=300)
    print(f"Grafico salvato in: {output_img}")
    plt.show()

if __name__ == "__main__":
    plotta_momenti_log("iperellittiche_pari_dati.csv")