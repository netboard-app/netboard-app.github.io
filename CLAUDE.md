# Logenrunde

Gaestefinder fuer die BVB-Loge von IFBA. Pro Spiel ein Thema, ca. 14 Plaetze, ca. 10 % Zusagequote, also ca. 140 Kandidaten.
Inhaber des Projekts: Eljakim. Vault-Notiz: `Business/IFBA - BVB-Loge Gaestefinder.md`.

## Start
Eine Datei: `index.html`, Doppelklick reicht. Daten in localStorage (Schluessel `logenrunde_daten`).
Vorschau im Chat: Server `logenrunde` in `~/Downloads/.claude/launch.json` zeigt auf eine Kopie im Scratchpad, vor jedem Test neu kopieren.

## Aufbau
- Datenmodell: events, personen, einladungen (Status mit Verlauf und Ergebnis), verbindungen (wer hat wen kennengelernt).
- Speicher steckt in `speicher.laden/sichern`. Fuer mehrere Nutzer durch Supabase ersetzen.
- Scoring ohne KI: Thema, Beruf, Netzwerk, Region kommen aus der Recherche-Datei. Runde und Zusagen rechnet die App.
  Unbekannte Werte zaehlen nicht mit. Zusagequote erst ab 3 eigenen bzw. 8 Rollen-Einladungen.
- Matching `paar()`: gemeinsame Themen, ergaenzende Rollen, Branche, Ort, fruehere Verbindungen. Jede Verbindung mit Gruenden.
- "Welche Person fehlt": gewuenschte Rollen im Event gegen Rollen in der Runde.
- Recherche macht Claude ausserhalb der App und liefert JSON: `{"personen":[{name, position, firma, branche, ort, website, rolle, tags[], profile[{art,url}], werte{thema,beruf,netzwerk,region}, begruendung, einladungsgrund, quellen[{text,url}]}]}`.
- Die App verschickt nichts. Einladungstexte werden kopiert.

## Regeln
- Keine Aussage ohne Quelle, unbekannt bleibt leer.
- Kein automatisches LinkedIn-Auslesen. Google-Suche und oeffentliche Quellen, LinkedIn nur zum Pruefen einzelner Profile.
