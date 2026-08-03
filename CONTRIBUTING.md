# Přispívání

Díky za zájem o vylepšení `TUL-obsidian`. Projekt je malá studentská knihovna,
takže proces má zůstat jednoduchý a praktický.

## Jak Pomoci

- opravte překlep nebo nejasnost v dokumentaci,
- doplňte chybějící krok v návodu,
- nahlaste problém s exportem,
- navrhněte drobné zlepšení šablon, filtrů nebo konfigurace.

## Před Odesláním Změny

Pokud měníte export, zkuste ho ověřit alespoň na macOS:

```bash
python3 _shared/tools/build_notes.py --vault . --list
python3 _shared/tools/build_notes.py --vault . 11_IRO
```

Upravujete-li dokumentaci, stačí zkontrolovat, že jsou příkazy a cesty pořád
srozumitelné pro běžného uživatele Obsidianu.

## Styl

- pište česky,
- držte návod věcný a stručný,
- nepřidávejte velké nové závislosti bez jasného důvodu,
- neignorujte globálně PDF, fonty ani grafické assety, protože jsou součástí
  repozitáře.
