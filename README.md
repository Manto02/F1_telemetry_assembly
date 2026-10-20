# Progetto Assembly x86 - Elaborazione Telemetria F1

Questo repository contiene l'elaborato sviluppato per il corso di **Architettura degli Elaboratori** (A.A. 2021/2022) presso l'Università di Verona. Il progetto consiste nell'implementazione di un modulo in linguaggio Assembly IA-32 (x86 a 32 bit, sintassi AT&T) interfacciato con un programma C per l'elaborazione dei dati di telemetria di una gara di Formula 1.

## Autori
* **Matteo Mantovani** (VR474454)
* **Matteo Gasparato** (VR478799)

---

## Descrizione del Progetto
Il programma legge da un file di testo i dati di telemetria relativi a diversi piloti e, identificato il pilota indicato nella prima riga del file di input, filtra i dati per produrre un report di output strutturato.

### Input
La prima riga del file contiene il nome del pilota da monitorare (es. `Charles Leclerc`). Le righe successive contengono i campioni nel formato:
`<tempo>,<id_pilota>,<velocità>,<rpm>,<temperatura>`

### Output
Per ogni istante di tempo associato al pilota selezionato, il programma determina e stampa il livello di sollecitazione (`LOW`, `MEDIUM`, `HIGH`) in base alle seguenti soglie:

* **Giri Motore (RPM):**
  * `LOW`: rpm <= 5000
  * `MEDIUM`: 5000 < rpm <= 10000
  * `HIGH`: rpm > 10000
* **Temperatura (°C):**
  * `LOW`: temp <= 90
  * `MEDIUM`: 90 < temp <= 110
  * `HIGH`: temp > 110
* **Velocità (km/h):**
  * `LOW`: speed <= 100
  * `MEDIUM`: 100 < speed <= 250
  * `HIGH`: speed > 250

Formato riga di output: `<tempo>, <livello rpm>, <livello temperatura>, <livello velocità>`

L'ultima riga del report riassume i valori di picco e la media:
`<rpm max>, <temp max>, <velocità max>, <velocità media>`

*Nota:* Nel caso in cui il pilota specificato non sia presente nella lista ufficiale dei 20 piloti registrati, il programma restituisce in output la stringa `Invalid`.

---

## Moduli e Funzioni
L'architettura del software è modulare e si compone delle seguenti funzioni Assembly:

* `telemetry.s`: Funzione principale chiamata dal `main.c`, coordina la lettura, il filtraggio per ID pilota e il flusso di esecuzione.
* `searchId.s`: Mappa il nome del pilota letto in input con il rispettivo ID univoco (0-19).
* `strcmp.s`: Effettua il confronto tra due stringhe carattere per carattere.
* `date_elaboration.s`: Elabora i dati numerici della riga, calcola i valori massimi, aggiorna la somma e il contatore per la velocità media.
* `str2num.s`: Converte una stringa di cifre ASCII nel relativo valore intero a 32 bit.
* `itoa.s`: Converte un valore intero a 32 bit nella relativa rappresentazione in stringa ASCII.
* `print.s`: Gestisce la formattazione e la scrittura dei dati e dei livelli nel buffer di output.
* `newLine.s`: Avanza il puntatore di lettura alla riga successiva del file di input.

---

## Struttura del Repository
```text
asm/
├── src/
│   ├── telemetry.s
│   ├── searchId.s
│   ├── strcmp.s
│   ├── date_elaboration.s
│   ├── str2num.s
│   ├── itoa.s
│   ├── print.s
│   ├── newLine.s
│   └── main.c
├── obj/          # Cartella di supporto per i file oggetto (.o)
├── bin/          # Cartella per l'eseguibile binario
├── Makefile      # Script di compilazione per l'ambiente x86 32-bit
└── Relazione.pdf # Relazione tecnica dell'elaborato
```
### Compilazione ed Esecuzione

```bash
# Compilazione del progetto
make

# Esecuzione
./bin/telemetry input.txt output.txt

# Pulizia dei file generati
make clean
