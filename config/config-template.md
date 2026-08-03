---
author-name: "Jméno Příjmení"
author-title: ""

faculty: "FM"

programme-code: ""
programme-name-cs: "Název programu"
programme-name-en: "Programme name"

branch-code: ""
branch-name-cs: "Název oboru"
branch-name-en: "Field of study"

language: "cs"
city: "Liberec"
use-university-font: false
---

# Nastavení exportu do PDF

Tento soubor je šablona konfigurace pro nový Obsidian vault.

## Jak ji použít

1. Zkopírujte tento soubor do kořene svého vaultu.
2. Přejmenujte kopii na `config.md`.
3. Otevřete `config.md` v Obsidianu.
4. Upravte hodnoty v horní části mezi `---`.

## Význam položek

- `author-name` – jméno a příjmení autora bez akademického titulu.
- `author-title` – akademický titul, například `Bc.` nebo `Ing.`; může zůstat prázdný.
- `faculty` – zkratka fakulty: `FS`, `FT`, `FP`, `EF`, `FA`, `FM`, `FZS` nebo `CXI`.
- `programme-code` – kód studijního programu.
- `programme-name-cs` – český název studijního programu.
- `programme-name-en` – anglický název studijního programu.
- `branch-code` – kód oboru.
- `branch-name-cs` – český název oboru.
- `branch-name-en` – anglický název oboru.
- `language` – jazyk PDF: `cs` nebo `en`.
- `city` – město uvedené na titulní straně.
- `use-university-font` – zaškrtávací políčko v Obsidian Properties.
  Hodnota `false` ponechá původní výchozí LaTeX fonty.
