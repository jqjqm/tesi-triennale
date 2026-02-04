# Studio della Distribuzione dei Punti Razionali di Curve su Campi Finiti

Repository contenente il codice computazionale e i dati sperimentali sviluppati per la mia **Tesi di Laurea Triennale in Matematica** presso l'Università di Pisa.

Il progetto analizza il comportamento statistico del numero di punti $\mathbb{F}_q$-razionali per diverse famiglie di curve algebriche.

## 📂 Struttura del Repository

### `Magma/` - Algoritmi di Conteggio
Script implementati nel linguaggio di algebra computazionale **MAGMA** per il calcolo della distribuzione dei punti.

* **Curve Ellittiche (Genere 1):**
    * **Ottimizzazione:** In caratteristica dispari, gli algoritmi sfruttano la classificazione per $j$-invariante e la teoria dei **twist quadratici** (e di ordine superiore per $j=0, 1728$) per ridurre drasticamente lo spazio delle curve da esaminare.
    * **Conteggio:** Il calcolo puntuale utilizza la funzione `TraceOfFrobenius`, basata sull'algoritmo di **Schoof** e sulle sue ottimizzazioni (Schoof-Elkies-Atkin, **SEA**).
    * **Caratteristica 2:** Gestione dedicata tramite enumerazione diretta per le forme non riducibili.

* **Curve di Genere 2:**
    * Analisi della distribuzione dei punti per famiglie di curve iperellittiche di genere 2 del tipo $y^2=f(x)$ in caratteristica diversa da 2.
    * Implementazione di strategie per la gestione del costo computazionale su campi finiti di piccola cardinalità, come la riduzione dello spazio dei coefficienti e l'uso della traccia dei twist.
    * Per campi con cardinalità più alta, analisi della distribuzione tramite metodo **Monte Carlo**.

### `Python/` - Analisi e Visualizzazione
Script **Python** per l'elaborazione statistica dei dati grezzi.
* **Generazione Istogrammi:** Creazione automatica dei grafici di distribuzione.
* **Visualizzazione:** Rendering grafico con evidenziazione dell'intervallo di Hasse-Weil.

### `Data/` - Dataset Sperimentali
Risultati delle computazioni salvati in formato `.csv` e report riassuntivi in `.txt`.
I file contengono le frequenze di curve per ogni numero di punti razionali ammissibile per vari valori della cardinalità $q$ ed alcuni indicatori statistici come media e ordine di parità.

---

## 🚀 Utilizzo

### Requisiti
* **Magma Computational Algebra System** (v2.20+)
* **Python 3.x** con librerie: `matplotlib`

---

## 🎓 Autore
* **Laureando:** Mario Zito
* **Relatore:** Prof. Davide Lombardo
