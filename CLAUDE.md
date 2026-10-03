# Netboard

Gaestefinder fuer die BVB-Loge von IFBA. Pro Spiel ein Thema, ca. 14 Plaetze, ca. 10 % Zusagequote, also ca. 140 Kandidaten.
Inhaber des Projekts: Eljakim. Vault-Notiz: `Business/IFBA - BVB-Loge Gaestefinder.md`.

## Start
Eine Datei: `index.html`, Doppelklick reicht. Daten in localStorage (Schluessel `netboard_daten`).
Vorschau im Chat: Server `netboard` in `~/Downloads/.claude/launch.json` zeigt auf eine Kopie im Scratchpad, vor jedem Test neu kopieren.

## Aufbau
- Datenmodell: events, personen, einladungen (Status mit Verlauf und Ergebnis), verbindungen (wer hat wen kennengelernt).
- Speicher steckt in `speicher.laden/sichern`. Fuer mehrere Nutzer durch Supabase ersetzen.
- Scoring ohne KI: Thema, Beruf, Netzwerk, Region kommen aus der Recherche-Datei. Runde und Zusagen rechnet die App.
  Unbekannte Werte zaehlen nicht mit. Zusagequote erst ab 3 eigenen bzw. 8 Rollen-Einladungen.
- Matching `paar()`: gemeinsame Themen, ergaenzende Rollen, Branche, Ort, fruehere Verbindungen. Jede Verbindung mit Gruenden.
- "Welche Person fehlt": gewuenschte Rollen im Event gegen Rollen in der Runde.
- Suche: Knopf "Kandidaten finden" ruft die Claude-API direkt aus dem Browser (web_search_20260209 + Werkzeug kandidaten_liefern), Runden zu je 10, pause_turn wird fortgesetzt. Schluessel in localStorage `netboard_key`, Modell `netboard_modell` (Standard claude-opus-5-5). Links, die nicht in den Suchergebnissen vorkamen, sind `geprueft:false` und erscheinen als "unbestaetigt".
- Vor Einsatz bei IFBA: API-Aufruf in eine Supabase Edge Function verlegen, Schluessel raus aus dem Browser.
- Alternativ Import als JSON: `{"personen":[{name, position, firma, branche, ort, website, rolle, tags[], profile[{art,url}], werte{thema,beruf,netzwerk,region}, begruendung, einladungsgrund, quellen[{text,url}]}]}`.
- Die App verschickt nichts. Einladungstexte werden kopiert.

## Regeln
- Keine Aussage ohne Quelle, unbekannt bleibt leer.
- Kein automatisches LinkedIn-Auslesen. Google-Suche und oeffentliche Quellen, LinkedIn nur zum Pruefen einzelner Profile.

## Recherche heute
Laeuft ueber Claude im Chat mit dem Skill `/netboard <Thema> <Anzahl>` (`~/.claude/skills/netboard/SKILL.md`). Ergebnis als JSON in `~/Downloads/netboard/recherche/`, in der App "Datei importieren". Der App-Knopf zeigt ohne Schluessel genau diese Anleitung. Eigene API erst, wenn IFBA zahlt.

## Bekannte Punkte
- 02.10.2026: Erreichbarkeit der API aus dem Browser mit falschem Schluessel getestet (401 kommt sauber an). Ein echter Lauf mit gueltigem Schluessel steht noch aus, `fallbacks:"default"` und die Typ-Arrays im Werkzeug-Schema sind damit noch ungeprueft.

## GitHub
Repo: https://github.com/netboard-app/netboard-app.github.io (oeffentlich, Organisation netboard-app). Live: https://netboard-app.github.io/
Hochladen: `git push` (gh-CLI unter ~/bin/gh, angemeldet als Eljas-Webstar). Keine echten Personendaten ins Repo, die Recherche-Dateien liegen ausserhalb in `~/Downloads/netboard/recherche/`.

## Anmeldung
Sichtschutz im Browser: Benutzername und Passwort werden als SHA-256 von `benutzername-klein:passwort` mit `ZUGANG` in index.html verglichen, gemerkt in localStorage `netboard_zugang`. Kein echter Schutz, weil der Code oeffentlich ist. Echte Anmeldung kommt mit Supabase. Zugangsdaten stehen nicht im Repo.

## Netzwerk-Funktionen (03.10.2026)
- Netzwerk hat vier Bereiche: Kontakte (Themen, Sortierung Wichtigkeit/Letzter Kontakt/Name), Wer hilft? (`helferSuchen`, Wortsuche mit Liste `VERWANDT` und `FUELLWOERTER`), Kennenlernen (`netzKennen`, Paare mit gemeinsamem Thema oder Branche, nie gleiche Firma, Knopf Vorstellen), Tueroeffner (`netzTuer`, Feld `kamUeber`).
- Wichtigkeit: `autoWichtigkeit` aus beruf/netzwerk, wertvoll, Geschaeftskontakt, Teilnahmen, Empfehlungen; von Hand ueberschreibbar (`p.wichtigkeit` 1 bis 3).
- Kontaktpflege: `p.kontakte` [{datum, art, notiz}] plus Events als Kontakt. Startseite "Lange nicht gemeldet": sehr wichtig nach 60, wichtig nach 120 Tagen, nur wer schon Kontakt hatte.
- Steckbrief am Profil: zuletzt, woher, worueber reden, gemeinsame Kontakte.
- Wer hilft? ist Wortsuche ohne KI. Wenn Treffer fehlen, zuerst `VERWANDT` erweitern. Allgemeine Silben wie "bau" oder "genossenschaft" vermeiden, sie treffen Falsches (Baumwerk, Jagdgenossenschaften).
- Kontaktwege (03.10.2026): `p.kontaktwege` [{art: Telefon|E-Mail|Kontaktformular|Nachricht, wert, typ, quelle}]. Karte zeigt "erreichbar" oder "kein Kontaktweg" und den ersten Weg, Filter "Nur erreichbare" im Kandidaten-Tab, Block "So erreichst du …" im Profil und Steckbrief. Telefon als tel:-Link plus Kopieren. Hinweis: E-Mail erst nach erstem Kontakt (UWG).
