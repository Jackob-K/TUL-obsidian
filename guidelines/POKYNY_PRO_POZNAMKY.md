# Jakubovy preference pro studijní poznámky

Tento dokument je trvalý pracovní profil pro tvorbu a úpravy poznámek napříč předměty. Cílem není zachytit všechno, ale vytvořit materiál, ze kterého se lze rychle učit večer před zkouškou a později opakovat ke státnicím.

## Jak poznámky používá

- Potřebuje rychle obnovit znalost, ne číst učebnici.
- Očekává vysokou informační hustotu a nízkou míru opakování.
- Nejlépe si vybavuje téma z konkrétního vzorce, matice, vztahu nebo krátké definice.
- Chce základ pochopit přímo v hlavní poznámce; podrobné odvození může být v odkázané poznámce.
- Preferuje technicky přesný výběr před mechanickým přepisem zdrojů.

## Hlavní redakční pravidlo

Každý odstavec, nadpis a řádek musí pomáhat buď:

1. vybavit si pojem,
2. pochopit vztah,
3. rozlišit podobné případy,
4. provést typický postup,
5. najít navazující detail.

Co nesplňuje žádný z těchto účelů, zpravidla odstranit.

## Obsah

- Pojem uvést jako **název – krátké vysvětlení významu nebo použití**.
- U matematického tématu uvést alespoň charakteristický vztah nebo vzorovou matici.
- Vzorec doplnit jednou větou: co vyjadřuje, kdy platí nebo jak číst jeho členy.
- Zachovat podmínky platnosti, konvence, singularity a časté záměny.
- Praktický postup zapisovat jako krátký číslovaný seznam.
- Příklad umístit bezprostředně za teorii, kterou ověřuje.
- Aplikace uvádět jen tehdy, když vysvětlují princip nebo bývají předmětem zkoušky.
- Při rozporu mezi ručními poznámkami a odbornou správností opravit obsah, ne chybu slepě přepsat.

## Co vynechávat

- Úvodní věty typu „tato poznámka shrnuje...“.
- Poznámky o organizaci předmětu, prezentacích nebo způsobu vzniku textu.
- Samostatná shrnutí, která pouze opakují předchozí kapitolu.
- Závěry bez nové informace.
- Nadpisy `Poznámka`, `Shrnutí`, `Příklad` nebo `Závěr`, pokud lze obsah připojit přímo k tématu.
- Obecné fráze, samozřejmosti a dlouhé slovní popisy toho, co přesněji ukáže rovnice.
- Výrobní či softwarové aplikace, názvy značek a nástrojů, pokud nejsou nutné pro pochopení nebo zkoušku.

## Struktura a úspora místa

- Udržovat mělkou osnovu; nevytvářet podkapitolu pro jeden bod nebo jednu větu.
- Místo dalších podnadpisů použít body `1.`, `2.`, `3.`.
- Krátké související podmínky a rovnice dávat na jeden řádek, pokud zůstávají čitelné.
- Související matice sázet vedle sebe, pokud se vejdou na šířku stránky.
- Neopakovat název odkázané poznámky ve větě i v odkazu.
- Optimalizovat nejen počet slov, ale také délku dokumentu a orientaci v osnově.
- Popisky obrázků a tabulek umisťovat vždy pod příslušný prvek.

## Odkazy

Odkaz nesmí nahrazovat základní informaci. Nejprve stručně říct, co má čtenář vědět, potom odkázat na detail.

Dobře:

> Obecný převod mezi ortonormálními bázemi má tvar $p^A=R^A_Bp^B$; odvození viz [Transformace mezi ortogonálními bázemi](...).

Špatně:

> Viz [Transformace mezi ortogonálními bázemi](...).

Text odkazu má přirozeně fungovat jako součást věty a využít výstižný název cílové poznámky.

## Matematika

- Preferovat zapsanou rovnici před obrázkem vzorce.
- U matic zachovat význam řádků, sloupců a indexů.
- Uvádět nejkratší vztah, ze kterého se vybaví celý princip.
- Nezahlcovat hlavní poznámku úplným odvozením; odkázat na samostatný detail.
- Kontrolovat znaménka, pořadí násobení, souřadné soustavy a předpoklady.

## Styl jazyka

- Česky, přímo, technicky a bez vaty.
- Krátké věty a konkrétní slovesa.
- Terminologii používat konzistentně.
- Anglický termín ponechat, pokud je běžný v praxi nebo pomáhá při práci se softwarem; český význam uvést stručně.
- Nepsat motivační ani konverzační výplň.

## Doporučený pracovní postup

1. Přečíst celou existující poznámku a související odkazy.
2. Určit minimum, které musí být přímo v hlavní poznámce.
3. Doplnit vybavovací vzorce, matice a jednověté definice.
4. Odstranit organizační text, opakování a prázdné nadpisy.
5. Zjednodušit osnovu a zkontrolovat návaznost příkladů.
6. Ověřit matematickou správnost a konzistenci značení.
7. Přečíst výsledek jako student večer před zkouškou.

## Neměnnost sdílené infrastruktury

- Složka `_shared` je společná infrastruktura všech předmětů a při tvorbě nebo úpravě poznámek je **neměnná**.
- Neupravovat soubory v `_shared/templates`, `_shared/build`, `_shared/filters`, `_shared/metadata`, `_shared/tul` ani v ostatních podsložkách `_shared`.
- Nepřidávat do sdíleného buildu výjimky pro jednotlivé předměty, názvy předmětů ani opravy sazby.
- Obsah a formát poznámek přizpůsobit existujícímu buildu. Problémy se sazbou řešit úpravou Markdown souborů a zdrojů uvnitř složky daného předmětu.
- Pokud požadovaný výstup se stávající šablonou nelze vytvořit, upozornit na omezení; sdílenou infrastrukturu bez výslovného pokynu neměnit.
- Výjimkou je pouze situace, kdy uživatel výslovně požádá o konkrétní změnu samotné sdílené infrastruktury. Změna guidelines na výslovný pokyn se považuje za takovou výjimku.

## Finální PDF

- Generovat výhradně sdíleným univerzitním buildem z `_shared`.
- Použít TUL/FM šablonu, barvy, fonty, logo a titulní list.
- Standardní příkaz je `./_shared/build/build-notes.sh <PŘEDMĚT>`.
- Do vstupu nezahrnovat pomocné rozcestníky, pokud by vytvořily duplicitní kapitolu.
- Samostatná PDF uložená ve složce předmětu nepřipojovat, pokud to není výslovně požadováno.
- Před předáním vizuálně zkontrolovat všechny strany, zejména rovnice, tabulky, zalomení nadpisů a obsah.

## Rozhodovací test

Před ponecháním textu se zeptat:

> Pomůže mi tento řádek rychleji si látku vybavit nebo správně vyřešit otázku?

Pokud ne, zkrátit ho, přesunout do detailní poznámky, nebo odstranit.
