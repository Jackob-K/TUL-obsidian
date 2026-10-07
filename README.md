# TUL-obsidian

![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-lightgrey.svg)
![Platform: macOS](https://img.shields.io/badge/tested%20on-macOS-000000.svg)
![Tools: Obsidian + Pandoc + XeLaTeX](https://img.shields.io/badge/tools-Obsidian%20%2B%20Pandoc%20%2B%20XeLaTeX-6f42c1.svg)

Sdílená knihovna pro export poznámek z [Obsidianu](https://obsidian.md/)
do PDF ve vizuálním stylu Technické univerzity v Liberci.

Projekt je určený hlavně pro studenty, kteří chtějí psát poznámky v Markdownu,
držet si je ve vlastním Obsidian vaultu a podle potřeby z nich vytvořit
upravené PDF s titulní stranou, logem TUL a jednotným typografickým vzhledem.

## ✨ Co to umí

- exportuje celý předmět nebo jeden konkrétní Markdown soubor do PDF,
- používá vizuální styl TUL přes XeLaTeX a přiložené univerzitní podklady,
- načítá údaje studenta a práce z jednoduchého `config.md`,
- podporuje Markdown poznámky psané přímo v Obsidianu,
- používá Pandoc Lua filtry pro úpravu odkazů, tabulek a dalších detailů,
- umožňuje sdílet jednu knihovnu mezi více vaulty přes `_shared`.

## 🧰 Požadavky

Projekt je primárně vyvíjený a testovaný na macOS.

Pro běžné použití budete potřebovat:

- [Obsidian](https://obsidian.md/),
- komunitní plugin **Shell commands** pro Obsidian,
- doplňkový plugin **TUL PDF Export** ze složky `obsidian-plugin/`,
- Python 3,
- Pandoc,
- XeLaTeX, například z MacTeX nebo BasicTeX.

Nemusíte být programátor. Typický postup je jednou připojit knihovnu k vaultu,
vyplnit `config.md` a potom export spouštět z Obsidianu.

## ⚡ Rychlý start

Nejjednodušší je mít všechny vaulty a tuto knihovnu ve stejné složce:

```text
Documents/Obsidian/
  TUL-obsidian/              sdílená knihovna
  muj-vault/
    _shared -> ../TUL-obsidian
    config.md
```

V příkazech níže nahraďte `muj-vault` názvem svého vaultu.

1. Umístěte nebo naklonujte `TUL-obsidian` do složky `Documents/Obsidian`.

2. Ve vaultu vytvořte symlink `_shared`:

```bash
cd ~/Documents/Obsidian/muj-vault
ln -s ../TUL-obsidian _shared
```

3. Zkopírujte konfigurační šablonu:

```bash
cp _shared/config/config-template.md config.md
```

4. Otevřete `config.md` v Obsidianu a vyplňte své údaje:

- jméno,
- titul,
- fakultu,
- studijní program,
- obor,
- jazyk,
- město.

Soubor `config.md` je obyčejná poznámka v kořeni vaultu. Hodnota
`use-university-font` se v Obsidianu zobrazí jako zaškrtávací políčko.

5. Připojte výběrový plugin pro dynamickou nabídku předmětů:

```bash
mkdir -p .obsidian/plugins
ln -s ../../_shared/obsidian-plugin .obsidian/plugins/tul-pdf-export
```

Potom v `.obsidian/community-plugins.json` přidejte do seznamu povolených
pluginů položku `tul-pdf-export` a Obsidian restartujte nebo znovu načtěte.

## 📦 Export

### Export z Obsidianu

Ve vaultu s nastaveným pluginem Shell commands:

1. otevřete paletu příkazů `Cmd+P`,
2. spusťte `Execute: Export předmětu do PDF`,
3. ve vyhledávacím seznamu zvolte předmět a potvrďte `Enter`,
4. v jednom seznamu zvolte export kořenových poznámek nebo konkrétní podsložku
   a potvrďte `Enter`.

Výběr se načítá při každém spuštění přímo ze složek v kořeni vaultu. Zobrazí
složky ve tvaru `12_PAS`, pokud v nich leží alespoň jeden Markdown soubor přímo
v kořeni. Dialog umožňuje vyhledávání a seznam se při větším počtu položek
posouvá.

Výběr měření zahrnuje jen přímé podsložky s alespoň jedním Markdown souborem
přímo v nich. Exportuje se pouze obsah této podsložky, nikoli sousední měření
ani její další vnořené složky. První položka seznamu exportuje jen Markdown
soubory přímo v kořeni předmětu. Pokud předmět nemá podsložky s Markdowny,
zobrazí se pouze tato kořenová volba. U měření určuje `protocol-title` název
PDF; pokud chybí, použije se bezpečný název odvozený od předmětu, složky
měření a autora.

Výsledek vznikne ve složce zvoleného rozsahu exportu. Pro kořenový export má
název tvar `<KOD_PREDMETU>_<AUTOR>_notes.pdf`, například
`DEMO_BcAlexNovak_notes.pdf`.

### Export z terminálu

Přímý export jednoho předmětu:

```bash
python3 _shared/tools/build_notes.py --vault . 11_IRO
```

Export pouze Markdown souborů přímo v podsložce:

```bash
python3 _shared/tools/build_notes.py --vault . 15_EMM --folder 1501_mereniViskozityTenzometrem
```

Interaktivní výběr předmětu:

```bash
python3 _shared/tools/build_notes.py --vault .
```

Výpis dostupných předmětů:

```bash
python3 _shared/tools/build_notes.py --vault . --list
```

Export jednoho souboru, například skupinového protokolu:

```bash
python3 _shared/tools/build_notes.py --vault . --file 13_MER/Protokol_01.md
```

Stejný export lze spustit přímo nízkoúrovňovým buildem:

```bash
./_shared/build/build-notes.sh --file 13_MER/Protokol_01.md
```

Bez vlastnosti `protocol-title` se výstup uloží jako `Protokol_01_TUL.pdf`.
Pokud ji vyplníte, její hodnota se použije jako název protokolu na titulní
straně i jako název PDF, například `Měření převodovky.pdf`.

### Metadata skupinového protokolu

Vlastnosti z YAML hlavičky exportované poznámky mají přednost před hodnotami z
kořenového `config.md`. Seznam `authors` a text `teacher` lze upravovat přímo
v panelu Properties v Obsidianu. Tituly se zapisují jako součást celého jména:

```yaml
---
document-label: "Laboratorní protokol"
protocol-title: "Měření přechodové charakteristiky"
authors:
  - "Bc. Anna Nováková"
  - "Bc. Petr Svoboda"
teacher: "doc. Ing. Jan Dvořák, Ph.D."
---
```

- `document-label` určuje typ dokumentu na titulní straně.
- `protocol-title` určuje název na titulní straně i název výstupního PDF.
- `authors` je seznam autorů včetně titulů; každý autor se vypíše na samostatný řádek.
- `teacher` je jméno vyučujícího včetně titulů.

Pokud `authors` chybí, titulní strana použije původní `author-name` a
`author-title` z `config.md`. Ostatní neuvedené vlastnosti se stejným způsobem
doplní z konfigurace a společných výchozích hodnot.

## 🗂️ Struktura vaultu

Složky předmětů začínají dvěma číslicemi a podtržítkem:

```text
01_MAT/
02_FYZ/
11_IRO/
```

Markdown soubory určené do PDF leží přímo ve složce předmětu. Jejich názvy
určují pořadí kapitol.

Předmět může obsahovat také podsložky pro samostatná měření. Export kořene
předmětu zahrne jen soubory přímo v kořeni; výběr podsložky zahrne jen její
přímé Markdown soubory. Například ukázkový vault obsahuje:

```text
01_DEMO/
  0101_Ukazkova_poznamka.md
  01_Mereni_viskozity/
    0101_Priprava_a_postup.md
    0102_Vysledky.md
  02_Mereni_teploty/
    0201_Priprava_a_postup.md
    0202_Vysledky.md
```

V první Markdown poznámce každé měřicí podsložky jsou vlastnosti `protocol-title`,
`authors` a `teacher`. `protocol-title` určuje titul protokolu i název PDF;
výsledný soubor se ukládá přímo do složky daného měření. Další soubory se
řadí podle názvu a doplňují obsah stejného protokolu. Celý postup lze projít
v `examples/demo-vault/01_DEMO`.

## 🧪 Ukázka výstupu

V repozitáři je připravené anonymní ukázkové PDF:

[examples/output/DEMO_BcAlexNovak_notes.pdf](examples/output/DEMO_BcAlexNovak_notes.pdf)

Zdroj ukázky je v `examples/demo-vault`. Používá fiktivního autora a fiktivní
studijní údaje.

## 🖥️ Podporované systémy

| Systém | Stav | Poznámka |
| --- | --- | --- |
| macOS | testováno | Hlavní podporovaná varianta. README počítá s unixovými cestami a `ln -s`. |
| Windows | orientačně | Princip by měl být podobný, ale funkčnost není garantovaná. Místo symlinku lze zkusit `mklink /D`. |
| Linux | netestováno | Může fungovat podobně jako macOS, pokud jsou dostupné potřebné nástroje. |

## 📁 Co repozitář obsahuje

```text
build/                       shell build a převod konfigurace
config/config-template.md    výchozí šablona config.md
examples/                    ukázkový vault a ukázkové PDF
filters/                     Lua filtry pro Pandoc
guidelines/                  pravidla pro psaní poznámek
metadata/                    společná Pandoc metadata
obsidian-plugin/             dynamický výběr předmětu v Obsidianu
slides/                      sdílené soubory pro prezentace
templates/notes.tex          Pandoc/LaTeX šablona PDF poznámek
tools/build_notes.py         launcher pro výběr předmětu
tul/                         oficiální LaTeX balík TUL
```

## 🔄 Aktualizace

`TUL-obsidian` je samostatný Git/GitHub repozitář. Když se aktualizuje tato
knihovna, všechny vaulty připojené přes `_shared` začnou používat novou verzi.

Lokální údaje studenta zůstávají ve vaultu v souboru `config.md`, takže se při
aktualizaci knihovny nepřepisují.

## 🤝 Přispívání

Malé opravy, doplnění návodu nebo návrhy na zlepšení jsou vítané. Praktické
pokyny jsou v [CONTRIBUTING.md](CONTRIBUTING.md).

Pokud něco nefunguje, založte issue a přidejte:

- operační systém,
- verzi Pythonu, Pandocu a LaTeXu,
- stručný popis problému,
- relevantní část chybové hlášky.

## ⚖️ Licence

Původní nástroj, build, konfigurace, Pandoc filtry, šablona poznámek a
dokumentace jsou poskytovány pod licencí **Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International** (`CC BY-NC-SA 4.0`).

Copyright © 2026 **Bc. Jakub Kočí**

Složka `tul/` obsahuje oficiální LaTeX balík TUL, jehož autorem je Pavel
Satrapa. Balík TUL a přiložené fonty mají vlastní licence; jejich původní
licence tato licence nemění. Podrobnosti jsou v
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
