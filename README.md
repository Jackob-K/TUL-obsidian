# TUL-obsidian

Sdílená knihovna pro export Obsidian poznámek do PDF ve vizuálním stylu
Technické univerzity v Liberci.

Tento projekt je určený pro studenty, kteří chtějí psát poznámky v Obsidianu a
jedním příkazem z nich vytvořit PDF s titulní stranou a grafikou TUL.

## Co potřebujete

- macOS,
- Obsidian,
- komunitní plugin **Shell commands**,
- Python 3,
- Pandoc,
- XeLaTeX, například z MacTeX nebo BasicTeX.

Nemusíte být programátor. V běžném použití stačí jednou propojit knihovnu s
vaultem, vyplnit `config.md` a potom exportovat přes menu v Obsidianu.

## Doporučené umístění

Nejjednodušší je mít všechny vaulty a tuto knihovnu ve stejné složce:

```text
Documents/Obsidian/
  TUL-obsidian/              tato sdílená knihovna
  muj-vault/
    _shared -> ../TUL-obsidian
    config.md
```

## Přidání do vlastního vaultu

V následujících příkazech nahraďte `muj-vault` názvem svého vaultu.

1. Umístěte nebo naklonujte `TUL-obsidian` do složky `Documents/Obsidian`.

2. Vytvořte ve vaultu symlink `_shared`:

```bash
cd ~/Documents/Obsidian/muj-vault
ln -s ../TUL-obsidian _shared
```

3. Zkopírujte konfigurační šablonu do kořene vaultu:

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

Soubor `config.md` je obyčejná poznámka v kořeni vaultu, takže je v Obsidianu
viditelný. Hodnota `use-university-font` se zobrazí jako zaškrtávací políčko.

## Export z Obsidianu

Ve vaultu s nastaveným pluginem Shell commands:

1. otevřete paletu příkazů `Cmd+P`,
2. spusťte `Execute: Export předmětu do PDF`,
3. vyberte předmět,
4. klikněte na `Vytvořit PDF`.

Výsledek vznikne ve složce vybraného předmětu. Název má tvar
`<KOD_PREDMETU>_<AUTOR>_notes.pdf`, například
`IRO_BcJakubKoci_notes.pdf`.

## Export z terminálu

Přímý export jednoho předmětu:

```bash
python3 _shared/tools/build_notes.py --vault . 11_IRO
```

Interaktivní výběr předmětu:

```bash
python3 _shared/tools/build_notes.py --vault .
```

Výpis dostupných předmětů:

```bash
python3 _shared/tools/build_notes.py --vault . --list
```

## Jak má vypadat vault

Složky předmětů začínají dvěma číslicemi a podtržítkem:

```text
01_MAT/
02_FYZ/
11_IRO/
```

Markdown soubory určené do PDF leží přímo ve složce předmětu. Jejich názvy
určují pořadí kapitol.

## Co knihovna obsahuje

```text
build/                       shell build a převod konfigurace
config/config-template.md    výchozí šablona config.md
filters/                     Lua filtry pro Pandoc
guidelines/                  pravidla pro psaní poznámek
metadata/                    společná Pandoc metadata
slides/                      sdílené soubory pro prezentace
templates/notes.tex          Pandoc/LaTeX šablona PDF poznámek
tools/build_notes.py         launcher pro výběr předmětu
tul/                         oficiální LaTeX balík TUL
```

## Aktualizace

`TUL-obsidian` je samostatný Git/GitHub repozitář. Když se aktualizuje tato
knihovna, všechny vaulty připojené přes `_shared` začnou používat novou verzi.

Lokální údaje studenta zůstávají ve vaultu v souboru `config.md`, takže se při
aktualizaci knihovny nepřepisují.

## Autorství a licence

Původní nástroj, build, konfigurace, Pandoc filtry a šablona poznámek:

Copyright © 2026 **Bc. Jakub Kočí**

Tyto části jsou poskytovány pod licencí **Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International** (`CC BY-NC-SA 4.0`).

Složka `tul/` obsahuje oficiální LaTeX balík TUL, jehož autorem je Pavel
Satrapa. Balík TUL a přiložené fonty mají vlastní licence; jejich původní
licence tato licence nemění. Podrobnosti jsou v `THIRD_PARTY_NOTICES.md`.
