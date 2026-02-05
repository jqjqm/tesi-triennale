import matplotlib.pyplot as plt
import ast
import os
import math
import numpy as np
from matplotlib.lines import Line2D

# --- CONFIGURAZIONE DATASET ---
DATASETS = {
    "Esaustivo": {
        "nome": "dati_iperellittiche_esaustivo.csv",
        "tipo": "calcola",
        "marker": "o",         
        "fill": "none",        # Cerchio Vuoto (interno trasparente)
        "size": 50,            
        "zorder": 5,
        "label_suffix": "(Esatto)"
    },
    "MC 100k": {
        "nome": "dati_per_plot_iperellittiche_mc_100k.csv",
        "tipo": "leggi",
        "marker": "o",         
        "fill": "full",        # Cerchio Pieno
        "size": 20,
        "zorder": 2,
        "alpha": 0.4,
        "line": True,          # Linea di sfondo
        "label_suffix": "(100k)"
    },
    "MC 1Mln": {
        "nome": "dati_per_plot_iperellittiche_mc_1mln.csv",
        "tipo": "leggi",
        # USIAMO UN MARKER SPECIALE "MATLAB_STAR"
        "marker": "MATLAB_STAR",   
        "fill": "full",        
        "size": 80,           # Dimensione per renderlo visibile
        "zorder": 10,
        "label_suffix": "(1M)"
    }
}

# --- CONFIGURAZIONE MOMENTI (COLORI) ---
MOMENTI_CFG = [
    (0, "$M_2$ (Varianza)", "red", 1),
    (1, "$M_4$", "blue", 3),
    (2, "$M_6$", "green", 14)
]

Q_MINIMO = 5

def get_data(config):
    nome_file = config["nome"]
    modo = config["tipo"]
    
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

                if modo == "leggi":
                    if len(parti) < 4: continue
                    moms = parti[3].split(',')
                    if len(moms) < 3: continue
                    m2, m4, m6 = float(moms[0]), float(moms[1]), float(moms[2])
                    
                elif modo == "calcola":
                    punti = np.array(ast.literal_eval(parti[1]), dtype=float)
                    freq = np.array(ast.literal_eval(parti[2]), dtype=float)
                    tot = np.sum(freq)
                    if tot == 0: continue
                    tracce = (q + 1) - punti
                    x = tracce / math.sqrt(q)
                    m2 = np.sum((x**2) * freq) / tot
                    m4 = np.sum((x**4) * freq) / tot
                    m6 = np.sum((x**6) * freq) / tot
                
                dati.append((q, m2, m4, m6))
            except:
                continue

    dati.sort(key=lambda x: x[0])
    return list(zip(*dati)) if dati else None

def plotta_finale_matlab_style():
    plt.figure(figsize=(12, 8))
    
    # 1. Linee teoriche (Sfondo)
    for idx, label, colore, val_teorico in MOMENTI_CFG:
        plt.axhline(val_teorico, color=colore, linestyle='--', alpha=0.4, linewidth=1.2)
        plt.text(1.02, val_teorico, f"{val_teorico}", color=colore, 
                 transform=plt.gca().get_yaxis_transform(), va='center', fontweight='bold')

    # 2. Plot Dati
    for ds_name, ds_conf in DATASETS.items():
        res = get_data(ds_conf)
        if not res: continue
        
        q, m2, m4, m6 = res
        valori_momenti = [m2, m4, m6]

        for idx, mom_label, colore, val_teorico in MOMENTI_CFG:
            y_vals = valori_momenti[idx]
            
            # --- TRUCCO PER L'ASTERISCO MATLAB ---
            if ds_conf["marker"] == "MATLAB_STAR":
                # Disegniamo prima un '+' e poi una 'x' nello stesso punto
                # Questo crea l'asterisco a 8 punte fatto di linee
                plt.scatter(q, y_vals, c=colore, marker='+', s=ds_conf["size"], 
                           alpha=ds_conf.get("alpha", 1.0), zorder=ds_conf["zorder"])
                plt.scatter(q, y_vals, c=colore, marker='x', s=ds_conf["size"], 
                           alpha=ds_conf.get("alpha", 1.0), zorder=ds_conf["zorder"])
            else:
                # Disegno standard (Cerchi pieni/vuoti)
                face_c = colore if ds_conf["fill"] == "full" else "none"
                plt.scatter(q, y_vals,
                           edgecolors=colore,
                           facecolors=face_c,
                           marker=ds_conf["marker"],
                           s=ds_conf["size"],
                           alpha=ds_conf.get("alpha", 1.0),
                           zorder=ds_conf["zorder"])

            # Linea di congiunzione (solo se richiesta)
            if ds_conf.get("line", False):
                plt.plot(q, y_vals, color=colore, alpha=0.3, linewidth=1, zorder=1)

    # --- SCALA LOGARITMICA ---
    plt.xscale('log') 
    
    # --- LEGENDA MANUALE ---
    legend_elements = [
        # Colori
        Line2D([0], [0], color='red', lw=2, label='$M_2$ (Varianza)'),
        Line2D([0], [0], color='blue', lw=2, label='$M_4$'),
        Line2D([0], [0], color='green', lw=2, label='$M_6$'),
        Line2D([0], [0], color='white', label=''), 
        # Marker
        Line2D([0], [0], marker='o', color='black', markerfacecolor='none', markersize=8, lw=0, label='Esatto'),
        Line2D([0], [0], marker='o', color='black', markerfacecolor='gray', markersize=6, lw=0, label='N=100k'),
        # Per la legenda usiamo il simbolo LaTeX che ci somiglia di più
        Line2D([0], [0], marker=r'$\ast$', color='black', markersize=14, lw=0, label='N=1M '),
    ]

    plt.xlabel('$q$ (Scala Logaritmica)', fontsize=12)
    plt.ylabel('Valore dei Momenti', fontsize=12)
    plt.title('Convergenza dei Momenti $M_2, M_4, M_6$', fontsize=14)
    plt.legend(handles=legend_elements, loc='center right', bbox_to_anchor=(1.25, 0.5))
    plt.grid(True, which="both", ls=":", alpha=0.5)

    plt.tight_layout()
    plt.savefig("grafico_momenti_finale.png", dpi=300)
    print("Grafico salvato: grafico_momenti_finale.png")
    plt.show()

if __name__ == "__main__":
    plotta_finale_matlab_style()