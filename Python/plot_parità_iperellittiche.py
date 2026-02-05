import matplotlib.pyplot as plt
import ast
import os
import numpy as np
from matplotlib.lines import Line2D

# --- CONFIGURAZIONE DATASET ---
DATASETS = {
    "Esaustivo": {
        "nome": "dati_per_plot_iperellittiche.csv",
        "marker": "o",         
        "fill": "none",        # Cerchio Vuoto
        "color": "red",        # ROSSO
        "size": 60,            
        "zorder": 5
    },
    "MC 100k": {
        "nome": "dati_per_plot_iperellittiche_mc_100k.csv",
        "marker": "o",         
        "fill": "full",        # Cerchio Pieno
        "color": "blue",       # BLU
        "size": 25,
        "zorder": 2,
        "alpha": 0.4,
        "line": True           # Linea di sfondo
    },
    "MC 1Mln": {
        "nome": "dati_per_plot_iperellittiche_mc_1mln.csv",
        "marker": "MATLAB_STAR",   
        "fill": "full",        
        "color": "green",      # VERDE
        "size": 100,           
        "zorder": 10
    }
}

Q_MINIMO = 2

def calcola_percentuale(nome_file):
    if not os.path.exists(nome_file):
        return None

    dati = []
    with open(nome_file, 'r') as f:
        for riga in f:
            riga = riga.strip()
            if not riga: continue
            parti = riga.split(';')
            if len(parti) < 3: continue

            try:
                q = int(parti[0])
                if q < Q_MINIMO: continue

                # Parsing distribuzione
                punti = np.array(ast.literal_eval(parti[1]), dtype=int)
                freq = np.array(ast.literal_eval(parti[2]), dtype=float)
                tot = np.sum(freq)
                
                if tot == 0: continue

                # --- CALCOLO PERCENTUALE PARI ---
                # Sommiamo le frequenze dove punti è pari
                freq_pari = np.sum(freq[punti % 2 == 0])
                percentuale = (freq_pari / tot) * 100.0
                
                dati.append((q, percentuale))
            except:
                continue

    dati.sort(key=lambda x: x[0])
    return list(zip(*dati)) if dati else None

def plotta_percentuale_pari():
    plt.figure(figsize=(12, 7))

    # Linea del 58%
    plt.axhline(58, color='black', linestyle='--', alpha=0.8, linewidth=1.5)


    has_data = False
    for ds_name, ds_conf in DATASETS.items():
        res = calcola_percentuale(ds_conf["nome"])
        if not res: continue
        has_data = True
        
        q, perc = res
        colore = ds_conf["color"]
        
        # Plotting con stile specifico
        if ds_conf["marker"] == "MATLAB_STAR":
            # Trucco Asterisco Matlab (+ sovrapposto a x)
            plt.scatter(q, perc, c=colore, marker='+', s=ds_conf["size"], 
                       alpha=ds_conf.get("alpha", 1.0), zorder=ds_conf["zorder"])
            plt.scatter(q, perc, c=colore, marker='x', s=ds_conf["size"], 
                       alpha=ds_conf.get("alpha", 1.0), zorder=ds_conf["zorder"])
        else:
            face_c = colore if ds_conf["fill"] == "full" else "none"
            plt.scatter(q, perc, 
                       edgecolors=colore, 
                       facecolors=face_c,
                       marker=ds_conf["marker"], 
                       s=ds_conf["size"], 
                       alpha=ds_conf.get("alpha", 1.0), 
                       zorder=ds_conf["zorder"])

        if ds_conf.get("line", False):
            plt.plot(q, perc, color=colore, alpha=0.3, linewidth=1, zorder=1)

    if not has_data:
        print("Nessun dato trovato.")
        return

    # Scala Logaritmica
    plt.xscale('log')
    
    # Legenda
    legend_elements = [
        Line2D([0], [0], marker='o', color='red', markerfacecolor='none', markersize=8, lw=0, label='Esaustivo'),
        Line2D([0], [0], marker='o', color='blue', markerfacecolor='blue', markersize=6, lw=0, label='MC 100k'),
        Line2D([0], [0], marker=r'$\ast$', color='green', markersize=14, lw=0, label='MC 1M'),
        Line2D([0], [0], color='black', linestyle='--', label='Target (50%)')
    ]

    plt.xlabel('$q$ (Scala Logaritmica)', fontsize=12)
    plt.ylabel('Percentuale di Curve con N Pari (%)', fontsize=12)
    plt.title('Percentuale di Curve con Numero di Punti Pari', fontsize=14)
    plt.legend(handles=legend_elements, loc='lower right')
    plt.grid(True, which="both", ls=":", alpha=0.5)
    
    plt.tight_layout()
    plt.savefig("grafico_percentuale_pari.png", dpi=300)
    print("Grafico salvato: grafico_percentuale_pari.png")
    plt.show()

if __name__ == "__main__":
    plotta_percentuale_pari()