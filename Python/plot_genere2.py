import matplotlib.pyplot as plt
import ast
import os
import math

def genera_grafici_tesi(nome_file_csv):
    output_dir = "grafici_iperellittiche_mc_1mln"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Cartella '{output_dir}' creata.")

    if not os.path.exists(nome_file_csv):
        print(f"Errore: il file {nome_file_csv} non esiste!")
        return

    with open(nome_file_csv, 'r') as f:
        for riga in f:
            riga = riga.strip()
            if not riga: continue
           
            parti = riga.split(';')

            if len(parti) < 4: continue

            q_str = parti[0]
            nome_output = os.path.join(output_dir, f"istogramma_q_{q_str}.png")

            if os.path.exists(nome_output):
                print(f"Grafico per q={q_str} già esistente. Salto...")
                continue

            punti = ast.literal_eval(parti[1])
            frequenze = ast.literal_eval(parti[2])
            q_int = int(q_str)
            centro = q_int + 1
            h_limit = 4 * math.sqrt(q_int)
            bound_inf = math.ceil(centro - h_limit)
            bound_sup = math.floor(centro + h_limit)

            plt.figure(figsize=(14, 7))
            plt.bar(punti, frequenze, color='pink', edgecolor='black', alpha=0.8, width=0.8)
            plt.axvspan(centro - h_limit, centro + h_limit, color='gray', alpha=0.1)

            margine = int(0.10 * (bound_sup - bound_inf))
            plt.xlim(bound_inf - margine, bound_sup + margine)

            # --- GESTIONE INTELLIGENTE DELL'ASSE X ---
            # Vogliamo circa 8-12 tick in totale.
            target_ticks = 10
            range_width = bound_sup - bound_inf
            step = max(1, int(range_width / target_ticks))
            
            ticks_to_show = set()
            # Aggiungiamo SEMPRE i bound e il centro
            ticks_to_show.add(bound_inf)
            ticks_to_show.add(bound_sup)
            ticks_to_show.add(centro)
            
            # Aggiungiamo tick intermedi
            curr = centro
            while curr > bound_inf + step:
                curr -= step
                ticks_to_show.add(int(curr))
            
            curr = centro
            while curr < bound_sup - step:
                curr += step
                ticks_to_show.add(int(curr))

            final_ticks = sorted(list(ticks_to_show))

           

            plt.xticks(final_ticks, fontsize=9)
            ax = plt.gca()
            plt.draw()
            for tick in ax.get_xticklabels():
                try:
                    val_tick = int(tick.get_text())
                    if val_tick == bound_inf or val_tick == bound_sup:
                        tick.set_color('red')
                        tick.set_fontweight('bold')
                    elif val_tick == centro:
                        tick.set_color('blue')
                        tick.set_fontweight('bold')
                except:
                    continue

            plt.title(f'Distribuzione punti Curve Iperellittiche su $\mathbb{{F}}_{{{q_str}}}$ con metodo Monte Carlo, N=1000000\n')
            plt.xlabel('Numero di soluzioni ', fontsize=11)
            plt.ylabel('Numero di curve', fontsize=11)
            plt.grid(axis='y', linestyle=':', alpha=0.6)

            plt.grid(axis='y', linestyle=':', alpha=0.6)
            

            plt.tight_layout()
            plt.savefig(nome_output, dpi=300)
            plt.close()

    print("Generazione completata.")

if __name__ == "__main__":
    genera_grafici_tesi("dati_per_plot_iperellittiche_mc_1mln.csv")