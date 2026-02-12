# Studio della Distribuzione dei Punti Razionali di Curve su Campi Finiti

Repository contenente il codice computazionale e i dati sperimentali sviluppati per la mia **Tesi di Laurea Triennale in Matematica** presso l'Università di Pisa.

Il progetto analizza la distribuzione del numero di punti $\mathbb{F}_q$-razionali per diverse famiglie di curve algebriche.

## 📂 Struttura del Repository

### `Magma/` - Algoritmi di Conteggio
Script implementati nel linguaggio di algebra computazionale **MAGMA** per il calcolo della distribuzione dei punti.

* **Curve Ellittiche (Genere 1):**
    * **Ottimizzazione:** In caratteristica dispari, gli algoritmi sfruttano la classificazione per $j$-invariante e le classi di isomorfismo su $\mathbb F_q$ per ridurre drasticamente lo spazio delle curve da esaminare.
    * **Conteggio:** Il calcolo puntuale utilizza la funzione `TraceOfFrobenius`, basata sull'algoritmo di **Schoof** e sulle sue ottimizzazioni (Schoof-Elkies-Atkin, **SEA**).
    * **Caratteristica 2:** Gestione dedicata tramite enumerazione diretta.

* **Curve di Genere 2 di equazione $y^2=f(x)$:**
    * **Ottimizzazione:** Per campi piccoli si sfruttano cambi di variabile ed osservazioni sul twist quadratico per ridurre lo spazio dei coefficienti. Per campi con cardinalità più alta, si analizza la distribuzione tramite metodo **Monte Carlo**.
    * **Conteggio:** Per ogni $x$ in $\mathbb F_q$ si valuta il polinomio $f(x)$ e si conta il numero di soluzioni di $y^2=f(x)$.

* **Curve di Genere 2 di equazione $y^2=f(x^2)$:**
   * **Ottimizzazione:** Con strategie simili a quelle utilizzate per le famiglie precedenti si riduce lo spazio dei coefficienti.
   *  **Conteggio:** Si calcolano le curve ellittiche quoziente e si ottengono le informazioni richieste dalle relative tracce. 
 
* **Quartiche Piane:**
    * **Metodologia:** Campionamento mediante metodo **Monte Carlo**.
    * **Conteggio Punti:** Il processo sfrutta l'esponenziazione modulare del polinomio di Frobenius ($x^q \pmod{f}$) per determinare il numero di radici del polinomio della curva nelle diverse carte affini e sulla retta all'infinito.

### `Data/` - Dataset Sperimentali
Risultati delle computazioni salvati in formato `.csv` e report riassuntivi in `.txt`.
I file contengono le frequenze di curve per ogni numero di punti razionali ammissibile per vari valori della cardinalità $q$ ed alcuni indicatori statistici come media, ordine di parità e momenti di ordine vario.

---

## 🚀 Utilizzo

### Requisiti
* **Magma Computational Algebra System** (v2.20+)

---

## 🎓 Autore
* **Laureando:** Mario Zito
* **Relatore:** Prof. Davide Lombardo
