// ======================================================================
// Eurorack 84HP Top-Bracket - segmentiert fuer Bambu Lab A1 Mini
// + Klickverschluss fuer Werkzeugkoffer-Entnahme
//
// Basis: kowend/Eurorack_84HP_7U_case, printables/variant1/variant1_top_bracket.stl
// Nachgebaut als echtes parametrisches Modell (kein STL-Import), damit
// Segmentierung und Klickverschluss sauber integriert werden koennen.
//
// KORRIGIERTE VERSION (2. Durchgang) nach Nutzer-Feedback anhand von
// Fotos des echten Aufbaus:
//   - Das Rack ist ein 7U-Format: 2 Reihen 3U + 1 Reihe 1U (mittig
//     zwischen den beiden 3U-Reihen), macht 3 Reihen x 2 Schienen
//     (oben+unten) = 6 Schienen. Die 6 vermessenen Loecher aus der
//     Original-STL sind GENAU diese 6 Schienen-Positionen (nicht wie in
//     der ersten Version angenommen 6 gleichmaessig verteilte Positionen
//     UND zusaetzlich 6 getrennte Wandschrauben). Reales Muster (siehe
//     ../analysis/06_find_rail_pairs.py, 07_plot_zmax_profile.py):
//       Reihe A oben (3U)  Y=  4.94   -> Abstand 122.8mm (3U) ->
//       Reihe A unten (3U) Y=127.73   -> Abstand  11.4mm (Reihen-Luecke) ->
//       Reihe B oben (1U)  Y=139.15   -> Abstand  32.9mm (1U) ->
//       Reihe B unten (1U) Y=172.10   -> Abstand  11.4mm (Reihen-Luecke) ->
//       Reihe C oben (3U)  Y=183.54   -> Abstand 123.0mm (3U) ->
//       Reihe C unten (3U) Y=306.51
//   - Das Bracket wird VERTIKAL an die Stirnwand des Koffers geschraubt
//     (nicht liegend auf dem Boden wie in der ersten Version). Die 6
//     Schienen-Positionen sind bei installiertem Bracket also senkrecht
//     uebereinander gestapelt, die Schienen ragen waagerecht in den
//     Koffer hinein. Zusaetzlich zu den 6 Schienen-Befestigungen braucht
//     das Bracket EIGENE Wandmontage-Schrauben (3 Stueck, je eine in der
//     Mitte jeder Reihe, siehe wall_mount_positions) - die urspruengliche
//     Version hat faelschlich die Schienen-Loecher dafuer benutzt.
//   - Sockel + Rastarm sitzen nur an EINEM Ende (unten, am Wand/Boden-
//     Uebergang) und werden an die Kofferwand geschraubt, nicht an den
//     Boden. Jedes der zwei Brackets (links/rechts an den Schienen-
//     Enden) hat genau EINEN Rastarm; "beide Rastarme druecken" bezieht
//     sich auf die zwei separaten Brackets, nicht zwei Arme an einem
//     Bracket.
//   - Schienen-Befestigung (4. Durchgang): mehrere Ansaetze verworfen
//     (Kammzaehne direkt in der Spange, separate Kammklammer nach
//     Original-STL-Massen, T-Nutenstein mit Schraube). Nutzerfotos vom
//     echten Original-Bracket + der Schienen-Stirnseite (mit markierten
//     Gegenstuecken) haben die Mechanik endgueltig geklaert: reiner
//     Formschluss per Zusammenstecken, KEINE Schraube. Pro Rail-Position
//     ein T-Stueck (Steg+Querbalken, steckt in eine Tasche der Schiene)
//     und ein Gabel-Zinken-Paar (umfasst einen duennen Schienensteg),
//     direkt in die Spange integriert (rail_connector()-Modul). Masse
//     aus Fotos geschaetzt - unbedingt an einem Testsegment gegen die
//     echte Schiene pruefen, bevor alle 6 final gedruckt werden.
//
// Koordinatensystem im MODELLRAUM (nicht Druckausrichtung!):
//   X = Laengsachse der Spange, 0 .. bracket_total_length. Bei
//       installiertem Bracket ist dies die VERTIKALE Achse (X=0 = unten
//       am Sockel, X=bracket_total_length = oben).
//   Y = Wandstaerke/Dicke,      0 .. bracket_thickness (an Verbindungs-
//       stellen lokal auf joint_boss_thickness verstaerkt). Y=0 ist die
//       Seite, aus der die Schienen herausragen (in den Koffer hinein);
//       Y=bracket_thickness liegt gegen die Kofferwand.
//   Z = Profilhoehe,            0 .. bracket_height
// Fuer den 3D-Druck wird jedes Segment beim Export separat gekippt, so
// dass die Trennebene (Stossflaeche zum Nachbarsegment) flach auf dem
// Druckbett liegt (print_orientation()-Modul weiter unten).
// ======================================================================

$fn = 48;

// ---------------------------------------------------------------------
// 1) GRUNDMASSE DER SPANGE (Schritt 1, aus STL-Vermessung + Nutzer-Korrektur)
// ---------------------------------------------------------------------
bracket_total_length  = 311.25; // gemessen (Koerper 0, Y-Achse im Original-STL)
bracket_thickness     = 8;      // gemessen (Koerper 0, X-Achse im Original-STL)
bracket_height        = 30;     // gemessen ~30.36mm (Koerper 0, Z-Achse im Original-STL), gerundet

// Reale Schienen-Positionen: 3 Reihen (3U, 1U, 3U), je 2 Schienen
// (oben+unten) = 6 Positionen insgesamt. Werte gemessen aus der
// Original-STL (siehe Kommentar oben), als Formel ausgedrueckt statt
// hartcodiert, damit sich z.B. rail_spacing_1u leicht anpassen laesst,
// falls die reale Schiene ein anderes Mass hat.
rail_row_start   = 4.94;    // Position der obersten Schiene (Reihe A oben)
rail_spacing_3u  = 122.88;  // Abstand oben<->unten-Schiene EINER 3U-Reihe
rail_spacing_1u  = 32.95;   // Abstand oben<->unten-Schiene der 1U-Reihe
inter_row_gap    = 11.43;   // Luecke zwischen unterer Schiene einer Reihe
                             // und oberer Schiene der naechsten Reihe

rail_positions = [
    rail_row_start,                                                                  // Reihe A oben (3U)
    rail_row_start + rail_spacing_3u,                                                // Reihe A unten (3U)
    rail_row_start + rail_spacing_3u + inter_row_gap,                                // Reihe B oben (1U)
    rail_row_start + rail_spacing_3u + inter_row_gap + rail_spacing_1u,              // Reihe B unten (1U)
    rail_row_start + rail_spacing_3u + inter_row_gap + rail_spacing_1u + inter_row_gap,               // Reihe C oben (3U)
    rail_row_start + rail_spacing_3u + inter_row_gap + rail_spacing_1u + inter_row_gap + rail_spacing_3u, // Reihe C unten (3U)
];
rail_count = len(rail_positions);

// ---------------------------------------------------------------------
// SCHIENEN-BEFESTIGUNG: T-Stueck + Gabel-Zinken (5. Durchgang - ECHTE
// STL-Geometrie statt geschaetztes Zusatzteil)
// ---------------------------------------------------------------------
// full_bar_cut() importiert jetzt Koerper 0 aus variant1_top_bracket.stl
// direkt (s.u.), statt die Spange per cube() nachzubauen. Das bedeutet:
// das T-Stueck+Gabel-Zinken-Paar an jeder der 6 rail_positions ist BEREITS
// in dieser importierten Geometrie enthalten (im Original-STL nativ
// vorhanden) - es muss nicht mehr separat modelliert/geschaetzt werden.
// Per Fein-Scan (analysis/, X-Aufloesung 0.05-0.1mm, siehe dortige
// Skripte) direkt aus der STL vermessen und gegen alle 6 rail_positions
// bestaetigt (Abweichung < 1mm zu jeder Position):
//   Boss-Breite je Position:      ~8.4-8.5mm
//   T-Stueck (oberes Merkmal):    Z~21.5-26 (Hoehe ~4.5mm), Breite ~6.1mm,
//                                 ragt bis Y=0 (voll, 5mm ueber Basiswand)
//   Gabel-Zinken (unteres Merkmal): Z=0-11.2mm (Hoehe ~11.2mm), zwei
//                                 ungleich breite Zinken (~2.0mm und
//                                 ~3.9mm) mit ~2.6mm Spalt dazwischen,
//                                 beide bis Y=0 ragend
// Vom Nutzer am Original-Bracket-Foto bestaetigt ("Du hast es endlich!").
// Die vorherigen rail_tpiece_*/rail_fork_*-Parameter und das rail_connector()-
// Modul (geschaetzte Nachbildung) sind damit obsolet und entfernt.

// Eigene Wandmontage-Schrauben (3 Stueck, je eine mittig in jeder Reihe -
// getrennt von den 6 Schienen-Positionen, s.o.). Sitzen in der freien
// Flaeche zwischen der oberen und unteren Schiene jeder Reihe (dort ist
// bei einer einzelnen Spange kein Modul im Weg, siehe Uebersichtsbild).
wall_mount_dia       = 4.5;
wall_mount_positions = [
    (rail_positions[0] + rail_positions[1]) / 2,  // Mitte Reihe A (3U)
    (rail_positions[2] + rail_positions[3]) / 2,  // Mitte Reihe B (1U)
    (rail_positions[4] + rail_positions[5]) / 2,  // Mitte Reihe C (3U)
];

// ---------------------------------------------------------------------
// 2) A1-MINI-BAURAUM & SEGMENTIERUNG
// ---------------------------------------------------------------------
a1_mini_build_volume = 180;               // realer Bauraum A1 Mini (mm)
safety_margin        = 10;                // Sicherheitsabstand (Bett-Rand/Skirt/Brim)
max_print_size        = a1_mini_build_volume - safety_margin; // = 170mm

num_segments = 3; // mindestens 3 gefordert; bei 311.25mm Gesamtlaenge waeren
                   // rechnerisch auch 2 Segmente moeglich (155.6mm < 170mm),
                   // aber die Aufgabenstellung verlangt explizit >= 3.

// Split-Positionen: gleichmaessig verteilt (311.25/3). Das ist KEIN Zufall
// bezueglich der echten Reihen-Positionen, sondern wurde geprueft: Split 1
// (103.75) liegt in der grossen Luecke zwischen Reihe A unten (127.82) und
// Reihe B oben (139.25 - warte, das ist die falsche Reihenfolge im
// Kommentar, siehe Zahlen unten) - praezise gilt: Split 1 liegt 23.9mm vor
// Reihe A unten (127.82) und 37.4mm nach dem Wandmontage-Loch der Reihe A
// (66.38); Split 2 (207.5) liegt 23.9mm nach Reihe C oben (183.63) und
// 37.6mm vor dem Wandmontage-Loch der Reihe C (245.07). Beide Male >> die
// 10mm Boss-Halbbreite, also keine Kollision mit Schienen-Tasche oder
// Wandschraube. Bei anderen rail_spacing_*-Werten unbedingt neu pruefen!
split_positions = [ for (i = [1 : num_segments - 1]) i * bracket_total_length / num_segments ];
// = [103.75, 207.5]

// -- Rechnerische Pruefung (verifiziert per OpenSCAD-CLI-Render, siehe
//    ../openscad/export/*.stl und die trimesh-Bounding-Box-Kontrolle) --
// Segmentlaenge (Basis) = 311.25 / 3 = 103.75mm. Alle Segment-Bounding-
// Boxen liegen deutlich unter dem 170mm-Limit (siehe Werte im vorherigen
// Durchgang, Fuss-Ueberstand +-15mm und Duebel-Zapfen-Ueberstand +9mm
// eingerechnet) - Segmentierung unveraendert aus dem 1. Durchgang uebernommen,
// nur die Rail-/Schraubenpositionen innerhalb wurden korrigiert.
echo("Segmentlaenge:", bracket_total_length / num_segments, "mm  (Limit:", max_print_size, "mm)");

// ---------------------------------------------------------------------
// 3) VERBINDUNGSELEMENTE AN DEN SEGMENTGRENZEN
//    (2x Rundduebel Ø5mm + 1x M4-Schraube mit Mutterntasche, pro Stoss)
// ---------------------------------------------------------------------
// Duebel-Durchmesser (Nutzer-Feedback: mehr Randabstand zu Z=0/Z=
// bracket_height, ohne den 3mm-Abstand zur M4-Schraube zu verkleinern).
// Die Z-Hoehe ist bereits vollstaendig verplant (2x Randmarge + 2x Duebel
// + M4-Loch + 2x 3mm-Abstand = exakt bracket_height) - mehr Randmarge
// gewinnen geht nur, wenn woanders Platz frei wird. Duebeldurchmesser
// (kein Normteil wie die M4-Schraube) ist dafuer die sinnvollste Stelle:
// 6mm -> 5mm gibt genau 1mm mehr Randmarge pro Seite, bei reiner
// Scherbelastung (Positionierung, keine Zugkraft) weiterhin ausreichend.
dowel_dia             = 5;      // Duebel-Durchmesser (maennlich)
dowel_len             = 8;      // Duebel-Laenge (Ueberstand ins Nachbarsegment)
dowel_tolerance       = 0.2;    // Spiel auf den Durchmesser (Loch = dowel_dia + tolerance)
dowel_hole_extra_depth = 0.5;   // zusaetzliche Lochtiefe, damit der Duebel nicht auf Grund laeuft

// Die Original-Wandstaerke (8mm) reicht NICHT aus, um einen Ø5mm-Duebel
// plus eine M4-Mutter jeweils mit >=3mm Restwand unterzubringen
// (5.2mm Duebelloch + 2x3mm Wand = 11.2mm; M4-Mutter-Tasche AF 7.4mm +
// 2x3mm Wand = 13.4mm). Deshalb wird die Spange lokal an jeder Stossstelle
// auf joint_boss_thickness verstaerkt (siehe joint_boss()-Modul).
joint_boss_thickness   = 14;
joint_boss_x_halfwidth = 10;    // Boss reicht +-10mm um die Split-Position

m4_clearance_dia = 4.4;   // Durchgangsloch fuer M4-Schraube
m4_head_dia      = 7.4;   // Kopf-Senkung (Zylinderkopf, mit Spiel)
m4_head_depth    = 4.2;
m4_nut_af        = 7.7;   // Schluesselweite M4-Sechskantmutter (7.0mm) + Druck-Toleranz
m4_nut_depth     = 3.4;   // Mutterhoehe (3.2mm) + Spiel

// ---------------------------------------------------------------------
// 4) KLICKVERSCHLUSS: FUSS + RASTARM (an den beiden aeusseren Enden)
// ---------------------------------------------------------------------
foot_size       = 30;   // Fussflaeche 30x30mm
foot_thickness  = 4;    // Fussdicke

// Der Fuss sass urspruenglich bei X=0 (ganz am Spangenende) und
// ueberlappte dort mit der Schienen-Verbinder-Tasche von rail_positions[0]
// (gemessen X=[0.2,8.5], siehe analysis/) - dort waere dann kein Platz
// mehr fuer die Schiene gewesen. Nutzer-Feedback: nicht noetig, den Fuss
// exakt am Ende zu platzieren, es ist genug Flaeche vorhanden, um ihn
// versetzt (ueberlappungsfrei) zu montieren. Fuss jetzt um foot_x_center
// zentriert, mit Sicherheitsabstand hinter der ersten Verbinder-Tasche.
rail_connector_end_x0 = 8.5;   // gemessene rechte Kante der ersten Verbinder-Tasche
foot_clearance         = 3;    // Mindestabstand Fuss <-> Verbinder-Tasche
foot_x_center          = rail_connector_end_x0 + foot_clearance + foot_size / 2;  // = 26.5

// HINWEIS zur Auslegung: die Aufgabenstellung erwaehnt sowohl am Fuss als
// auch am separaten Sockelstueck 2x M3-Senkbohrungen. Da der Fuss Teil des
// ENTNEHMBAREN Rahmens ist (rein durch den Rastarm gehalten, siehe
// "Rahmen nach oben herausheben"), waere eine Verschraubung des Fusses
// selbst widerspruechlich zum Tool-freien Entnahmekonzept. Die 2x M3-
// Senkschrauben sind daher hier konsequent nur am SOCKELSTUECK (siehe
// Abschnitt 5) modelliert, das fest im Koffer verschraubt wird.

// ZWEITER Ueberarbeitungsdurchgang (Nutzer-Feedback: die Rastnase war
// nicht erkennbar/nicht loesbar). Statt einer Nase AM ARM, die in einer
// geschlossenen Tasche verschwindet, ist der Arm jetzt ein einfacher
// flacher Federstreifen OHNE eigene Nase - die Rastkontur sitzt komplett
// im SOCKEL (ein Zahn auf dem Kanalboden, siehe sockel()-Modul), und der
// Kanal ist OBEN OFFEN (kein Deckel). Vorteil: der komplette Arm bleibt
// jederzeit sichtbar UND von oben mit dem Finger erreichbar, sowohl zum
// Einschieben als auch zum Loesen (anheben + herausziehen) - kein
// zusaetzliches Bauteil/Zunge noetig, der offene Kanal IST der Zugang.
arm_length      = 25;   // Rastarm-Laenge (steckt komplett im offenen Kanal)
arm_width       = 8;    // Rastarm-Breite
arm_thickness   = 2;    // Rastarm-Dicke (Biegeachse)
arm_root_fillet = 1;    // Radius an der Wurzel gegen Ermuedungsbruch

// Einsteck-Richtung: der Arm wird HORIZONTAL in den offenen Kanal im
// Sockel geschoben (+Y). Der Zahn auf dem Kanalboden (sockel_tooth_*)
// zwingt den duennen Arm beim Einschieben kurz nach oben durchzufedern,
// danach faellt er dahinter zurueck auf den Kanalboden - die steile
// Rueckflanke des Zahns blockiert dann das Zurueckziehen.
// Zum LOESEN: von oben (der Kanal ist offen!) den Arm am Zahn leicht
// anheben, dabei den Rahmen von der Wand weg aus dem Kanal ziehen.
sockel_channel_z0      = 2;    // Kanalboden-Hoehe ueber der Sockel-Unterseite
sockel_channel_clear   = 0.6;  // Spiel auf die Armbreite im Kanal
sockel_tooth_pos       = 8;    // Zahnposition, Abstand von der Einschuboeffnung
sockel_tooth_height    = 1.2;  // wie weit der Zahn ueber den Kanalboden ragt
sockel_tooth_width     = 3;    // Zahnbreite in Einschubrichtung (Y)
sockel_tooth_ramp      = 2.5;  // Laenge der Einfuehrschraege vor dem Zahn

// ---------------------------------------------------------------------
// 5) SOCKELSTUECK (separates Bauteil, an die Kofferwand verschraubt,
//    unten am Wand/Boden-Uebergang - NICHT auf den Boden gelegt)
// ---------------------------------------------------------------------
sockel_w  = 40;
sockel_d  = 40;
sockel_h  = 15;
sockel_screw_dia      = 3.5;  // M3-Senkbohrung
sockel_screw_head_dia = 6.5;
sockel_screw_inset    = 8;    // Lochabstand vom Rand

// ---------------------------------------------------------------------
// 6) RENDER-STEUERUNG
//    render_segment:
//      -1        = Uebersicht, alle Segmente + Sockel in Einbaulage (nur
//                  zur Kontrolle, NICHT druckfertig ausgerichtet)
//       0,1,2,... = einzelnes Segment, druckfertig gekippt
//       10        = Sockel links
//       11        = Sockel rechts
//
//    T-Stueck + Gabel-Zinken sind jetzt DIREKT in jedes Segment integriert
//    (rail_connector(), kein separates Teil mehr) - kein eigener Export
//    dafuer noetig, sie erscheinen automatisch auf dem Segment, das die
//    jeweilige Rail-Position enthaelt.
//
//    Export-Befehle (Terminal, im openscad/-Ordner):
//      openscad -D "render_segment=0"  -o segment_1.stl bracket.scad
//      openscad -D "render_segment=1"  -o segment_2.stl bracket.scad
//      openscad -D "render_segment=2"  -o segment_3.stl bracket.scad
//      openscad -D "render_segment=10" -o sockel_links.stl bracket.scad
//      openscad -D "render_segment=11" -o sockel_rechts.stl bracket.scad
// ---------------------------------------------------------------------
render_segment = -1;

// ======================================================================
// MODULE
// ======================================================================

// Eigene Wandmontage-Schraube (getrennt von den Schienen-Positionen,
// s. wall_mount_positions oben) - befestigt die Spange selbst an der
// Kofferwand. Achse entlang Y, nahe der Oberkante (bracket_height-5).
module wall_screw_hole(x_pos) {
    translate([x_pos, -1, bracket_height - 5])
        rotate([-90, 0, 0])
            cylinder(d = wall_mount_dia, h = joint_boss_thickness + 4, $fn = 24);
}

// Rail-Verbinder (T-Stueck + Gabel-Zinken) sind KEIN eigenes Modul mehr -
// sie sind Teil der importierten STL-Geometrie in full_bar_cut() (s.u.)
// und muessen dort nicht mehr separat hinzugefuegt werden.

// Die importierte STL-Geometrie hat mittig (zwischen den Verbinder-Taschen
// der 1U-Reihe, rail_positions[2]=139.15 und rail_positions[3]=172.10)
// eine Aussparung (nur am UNTEREN Rand entferntes Material, Z=[0,12.63],
// gemessen X=[142.65,168.65]) - dient in dieser Anwendung keinem Zweck
// (Nutzer-Feedback), wird hier wieder aufgefuellt.
//
// KORREKTUR: erster Versuch hat bis Y=0 (volle Verbinder-Tiefe) aufgefuellt
// - zu viel Material, da die Spange dort im Original nur bis Y=5 reicht
// (Y=[5,8], wie im ganzen restlichen Bereich zwischen den Verbinder-
// Taschen). Jetzt wird nur die vorhandene Umgebungsflaeche (Y=[5,8]) nach
// unten fortgesetzt, statt zusaetzlich nach vorne (Y<5) aufzufuellen.
// Rand-Margen (0.1-0.2mm) nur fuer sauberes union(), keine echte
// Materialzugabe ueber die Umgebungsflaeche hinaus.
module notch_fill() {
    translate([142.5, 5, -0.2])
        cube([168.8 - 142.5, bracket_thickness - 5, 13]);
}

// Lokale Verstaerkung an einer Verbindungsstelle: erweitert die
// Wandstaerke von bracket_thickness auf joint_boss_thickness in einem
// Bereich +-joint_boss_x_halfwidth um sp, damit Duebel + M4-Mutter mit
// ausreichend Restwand (>=3mm) Platz haben.
//
// KORREKTUR 1 (Nutzer-Feedback nach Testdruck): urspruenglich reichte der
// Boss von Y=0 bis Y=joint_boss_thickness - das fuellt den Freiraum
// Y=[0,5], den die Spange sonst ueber die GANZE Laenge hat (dort brauchen
// Rails/Module beim Zusammenstecken Platz).
//
// KORREKTUR 2 (nach Testdruck): DER EIGENTLICHE BUG. Die Duebel-Y-Position
// war aus joint_boss_y0 abgeleitet (joint_y_center = joint_boss_y0 +
// joint_boss_thickness/2). Beim Verschieben der Bruecke nach hinten sind die
// Duebel deshalb MITGEWANDERT und aus dem Material heraus nach hinten
// gerutscht - gemessen: an beiden Trennstellen ist die Spange nur eine
// 3mm-Platte (Y=[5,8]), die Duebel sassen bei Y=10 (Ø6 => Y=[7,13]), also
// nur 1 von 6mm innerhalb der Platte, der Rest frei dahinter. Genau das
// hat der Nutzer als "nur leicht verbunden / nicht mittig" beschrieben.
//
// KORREKTUR 3 (jetzige Fassung, Nutzer-Vorschlag): das Material des
// Originals (14mm) bleibt in voller Menge erhalten und wird KOMPLETT nach
// hinten verlagert - Vorderkante buendig mit der 3mm-Wand, also null
// Eingriff in den Modul-Freiraum Y=[0,5]. Entscheidend: die Duebel-Position
// ist jetzt ein EIGENER Parameter (joint_dowel_y, s.u.) und NICHT mehr aus
// joint_boss_y0 abgeleitet - sie kann also nicht wieder mitwandern.
// Zusaetzlich laufen die Bruecken-Enden angeschraegt auf die Wandstaerke
// aus (joint_boss_taper), statt mit einer harten Stufe 14mm -> 3mm
// abzubrechen (das fuehlte sich wie ein "angeklebter Klotz" an).
joint_boss_y0    = 4.9;  // Vorderkante ~buendig mit der 3mm-Wand (Y=5).
                          // 0.1mm Ueberlappung, damit CGAL nicht auf zwei
                          // exakt deckungsgleiche Flaechen laeuft (das gab
                          // sonst "not 2-manifold", siehe Historie).
joint_boss_taper = 8;    // Laenge der Auslaufschraege je Bruecken-Ende
joint_wall_thick = 3;    // gemessene Wandstaerke an der Trennstelle (Y=[5,8])

module joint_boss(sp) {
    x0 = sp - joint_boss_x_halfwidth;
    x1 = sp + joint_boss_x_halfwidth;

    // Hauptblock in voller Bruecken-Dicke
    translate([x0, joint_boss_y0, 0])
        cube([2 * joint_boss_x_halfwidth, joint_boss_thickness, bracket_height]);

    // Auslaufschraegen an beiden Enden: von joint_boss_thickness sanft
    // zurueck auf die Wandstaerke, damit kein harter Absatz entsteht.
    // Die dicke Startflaeche der Schraege liegt bewusst 0.5mm INNERHALB des
    // Hauptblocks - beruehrten sich beide exakt deckungsgleich, wertet CGAL
    // die Schraege als eigenes Volumen ("Volumes: 4" statt 2).
    for (end = [[x0, -1], [x1, 1]])
        hull() {
            translate([end[0] - end[1] * 0.5, joint_boss_y0, 0])
                cube([0.01, joint_boss_thickness, bracket_height]);
            translate([end[0] + end[1] * joint_boss_taper, joint_boss_y0, 0])
                cube([0.01, joint_wall_thick, bracket_height]);
        }
}

// Z-Positionen der beiden Duebel (symmetrisch um die Mitte, mit
// Mindestwandstaerke 3mm zu Rand und M4-Loch) und der M4-Schraube.
dowel_z_margin = (bracket_height - dowel_dia - dowel_dia - m4_clearance_dia - 6) / 2;
dowel_z_lower  = dowel_z_margin + dowel_dia / 2;
dowel_z_upper  = bracket_height - dowel_z_margin - dowel_dia / 2;
m4_z           = bracket_height / 2;

// Y-Position von Duebeln und M4-Schraube - BEWUSST als eigener, absoluter
// Wert gesetzt und NICHT aus joint_boss_y0 abgeleitet. Genau diese
// Ableitung war der Bug: beim Verschieben der Bruecke sind die Duebel
// mitgewandert und aus dem Material gerutscht (s. Kommentar bei
// joint_boss). Wert = Mitte der Bruecke (4.9 + 14/2 ~ 12), sodass ein
// Ø6-Duebel (Y=[9,15]) rundum ~4mm Material hat.
joint_dowel_y  = 12;
joint_y_center = joint_dowel_y;

// Kontrolle beim Rendern: Duebel muss vollstaendig in der Bruecke liegen.
assert(joint_dowel_y - dowel_dia / 2 >= joint_boss_y0 + 2,
       "Duebel zu weit vorne - weniger als 2mm Material vor dem Duebel");
assert(joint_dowel_y + dowel_dia / 2 <= joint_boss_y0 + joint_boss_thickness - 2,
       "Duebel zu weit hinten - weniger als 2mm Material hinter dem Duebel");

// Weibliche Duebelloecher (rechte Seite des Stosses, X >= sp) - werden
// von der Spange ABGEZOGEN (difference). Beginnt EXAKT bei sp (nicht
// davor!), damit auf der linken Seite (Nachbarsegment mit dem
// maennlichen Zapfen) keine Kerbe entsteht, die den Zapfen von der
// Basis trennen wuerde (fuehrte sonst zu einem nicht verschmolzenen,
// separaten CGAL-Volumen an der Stossstelle).
module dowel_female_holes(sp) {
    for (z = [dowel_z_lower, dowel_z_upper])
        translate([sp, joint_y_center, z])
            rotate([0, 90, 0])
                cylinder(d = dowel_dia + dowel_tolerance, h = dowel_len + dowel_hole_extra_depth, $fn = 24);
}

// Maennliche Duebel-Zapfen (werden per union HINZUGEFUEGT, am rechten
// Ende des LINKEN Nachbarsegments, ragen ueber sp hinaus in das rechte
// Nachbarsegment hinein).
module dowel_male_pins(sp) {
    for (z = [dowel_z_lower, dowel_z_upper])
        translate([sp - 1, joint_y_center, z])
            rotate([0, 90, 0])
                cylinder(d = dowel_dia, h = dowel_len + 1, $fn = 24);
}

// M4-Durchgangsloch ueber die gesamte Boss-Breite (beide Segmente).
module m4_clearance_hole(sp) {
    translate([sp - joint_boss_x_halfwidth - 0.5, joint_y_center, m4_z])
        rotate([0, 90, 0])
            cylinder(d = m4_clearance_dia, h = 2 * joint_boss_x_halfwidth + 1, $fn = 24);
}

// Kopf-Senkung fuer die M4-Schraube, linke Seite des Stosses (Kopf sitzt
// im linken Segment, Schraube wird von links eingefuehrt).
module m4_head_counterbore(sp) {
    translate([sp - joint_boss_x_halfwidth - 0.5, joint_y_center, m4_z])
        rotate([0, 90, 0])
            cylinder(d = m4_head_dia, h = m4_head_depth + 0.5, $fn = 32);
}

// Sechskant-Mutterntasche, rechte Seite des Stosses (Mutter wird vor dem
// Zusammenstecken eingelegt, Schraube von links durchgesteckt und
// eingedreht).
module m4_nut_pocket(sp) {
    translate([sp + joint_boss_x_halfwidth - m4_nut_depth, joint_y_center, m4_z])
        rotate([0, 90, 0])
            cylinder(d = m4_nut_af / cos(30), h = m4_nut_depth + 0.5, $fn = 6);
}

// ---------------------------------------------------------------------
// AUFLAGE-FLANSCH: eine Lippe an der Aussen-Oberkante (Wandseite,
// Y = bracket_thickness.., oben bei Z = bracket_height). Damit liegt der
// Rahmen auf der Profil-Schiene im Koffer auf. Der Rahmen HAENGT: die
// Flansch-Unterseite ist die Auflageflaeche, das Bracket haengt darunter,
// Module haengen weiter nach unten in den Koffer.
// Passung (vom Nutzer im Koffer gemessen): Bracket-Aussenseite ~15 mm von
// der kurzen Kofferwand entfernt. Die Profil-Schiene reicht aus der 15-mm-
// Luecke bis knapp an das Bracket; der Flansch ueberbrueckt den Rest und
// liegt auf. Ragt flange_reach nach aussen (Richtung Wand), bleibt damit
// klar unter dem Dichtrand (Rahmen sitzt ~70 mm ueber dem Boden).
// Laeuft ueber die ganze Laenge; getragen wird er von den 2 Profilen je
// Wand nahe den Bracket-Enden.
flange_reach = 8;   // wie weit die Lippe nach aussen (Richtung Wand) ragt
flange_thick = 4;   // Dicke der Lippe (Z); Auflageflaeche
// flange_at_bottom: WICHTIGER SCHALTER fuer die Einbaurichtung.
//  false = Lippe an Z=bracket_height (alt): Rahmen ragt beim Test nach OBEN raus.
//  true  = Lippe an Z=0 (Fork-Seite, aber Wandseite Y>=8 -> KEIN Konflikt mit
//          den Fork-Zinken bei Y=0): Rahmen wird andersherum eingelegt und
//          HAENGT nach unten in den Koffer, Module zeigen zum Boden.
flange_at_bottom = true;
flange_z0 = flange_at_bottom ? 0 : bracket_height - flange_thick;

module flange() {
    translate([0, bracket_thickness, flange_z0])
        cube([bracket_total_length, flange_reach, flange_thick]);
}

// Gesamte Spange (alle Segmente in einem Stueck, mit allen Ausschnitten).
// Wird per intersection() in einzelne druckbare Segmente zerlegt.
module full_bar_cut() {
    difference() {
        union() {
            // ECHTE Spangen-Geometrie aus variant1_top_bracket.stl (Koerper 0),
            // exportiert nach Achsentausch/Verschiebung in dieses lokale
            // Koordinatensystem (siehe analysis/, Skript zur Extraktion).
            // Ersetzt die vorherige cube()-Rekonstruktion - keine geschaetzten
            // Ersatzmasse mehr fuer die Grundform, nur noch echte STL-Daten.
            import("../printables/variant1/variant1_body0_local.stl");
            for (sp = split_positions) joint_boss(sp);
            notch_fill();
            flange();   // Auflage auf dem Profil (s.o.)
        }
        // (frueheres wall_screw_hole entfernt - obsolet: der Rahmen wird
        //  nicht mehr an die Wand geschraubt, sondern liegt auf dem Profil.)
        for (sp = split_positions) {
            dowel_female_holes(sp);
            m4_clearance_hole(sp);
            m4_head_counterbore(sp);
            m4_nut_pocket(sp);
        }
    }
    // T-Stueck + Gabel-Zinken an jeder der 6 Rail-Positionen sind bereits
    // Teil der importierten STL-Geometrie oben - keine Ergaenzung noetig.
}

// Rastarm als 3D-Koerper (Breite arm_width in X-Richtung extrudiert).
// Ansatzpunkt ist lokal bei Y=0 (Fusskante), Ende bei Y=arm_length.
// Einfacher flacher Streifen OHNE eigene Rastnase (siehe Kommentar oben -
// die Rastkontur sitzt jetzt im Sockel). Die Wurzel-Verrundung (gegen
// Ermuedungsbruch) wird per hull() zwischen
// einem breiteren Zylinder direkt an der Fusskante (Y=0, Radius =
// halbe Armdicke + arm_root_fillet) und einem schmaleren Zylinder kurz
// dahinter (Y=1.5*arm_root_fillet, Radius = halbe Armdicke, passt exakt
// in das rechteckige Armprofil) erzeugt - das ist robust (kein
// degeneriertes offset()) und verschmilzt sauber mit dem Hauptkoerper.
module snap_arm() {
    translate([-arm_width / 2, 0, 0])
        cube([arm_width, arm_length, arm_thickness]);

    hull() {
        translate([-arm_width / 2, 0, arm_thickness / 2])
            rotate([0, 90, 0])
                cylinder(r = arm_thickness / 2 + arm_root_fillet, h = arm_width, $fn = 24);
        translate([-arm_width / 2, 1.5 * arm_root_fillet, arm_thickness / 2])
            rotate([0, 90, 0])
                cylinder(r = arm_thickness / 2, h = arm_width, $fn = 24);
    }
}

// Fuss + Rastarm, lokal um den Koordinatenursprung modelliert:
//   Fuss:  X=[-foot_size/2,+foot_size/2], Y=[-foot_size/2,+foot_size/2], Z=[0,foot_thickness]
//   Arm:   setzt an der aeusseren Fusskante (Y=+foot_size/2) an und zeigt
//          weiter nach aussen (+Y), flach bei Z=[0,arm_thickness] -
//          liegt damit beim Segment-Druck (siehe print_orientation) nahe
//          am Bett und braucht keinen Support ("liegend gedruckt").
// NUR am unteren Ende EINES Brackets (X=0, am Wand/Boden-Uebergang beim
// Koffer) - jedes der zwei Brackets (links/rechts an den Schienenenden)
// hat genau EINEN Rastarm, nicht zwei (siehe Kommentar Kopf der Datei).
module foot_and_arm() {
    translate([-foot_size / 2, -foot_size / 2, 0])
        cube([foot_size, foot_size, foot_thickness]);
    translate([0, foot_size / 2, 0])
        snap_arm();
}

// ---- T-GRIFF (alternatives Bracket, Segment 2 = Mitte): zum Herausheben mit
// 2 Fingern. Zeigt in MODUL-Richtung, d.h. aus der Front (Z=0) nach -Z raus
// (= case_z hoch, zur Kofferoeffnung). Steg+Balken ~15 mm -> ragt ~2,5 mm ueber
// den Rand (bewusst, nur fuers Handling/Holzcase). Aktiv mit -D with_handle=true.
with_handle    = false;
handle_seg     = 1;      // Segment-Index mit Griff (1 = Segment 2, Mitte)
handle_stem_h  = 11;     // Steg-Hoehe (Z) aus der Front raus
handle_stem_w  = 8;      // Steg-Breite (X)
handle_bar_w   = 24;     // T-Balken-Breite (X) zum Untergreifen
handle_bar_t   = 4;      // T-Balken-Dicke (Z); Steg+Balken ~15 mm total
handle_th      = 3;      // Dicke (Y), buendig mit Koerper (Y=5..8)
handle_y0      = 5;
module t_handle() {
    cx = bracket_total_length / 2;                             // Bracket-Mitte
    translate([cx - handle_stem_w/2, handle_y0, -handle_stem_h])
        cube([handle_stem_w, handle_th, handle_stem_h + 2]);  // Steg (+2 mm in den Koerper)
    translate([cx - handle_bar_w/2, handle_y0, -handle_stem_h - handle_bar_t])
        cube([handle_bar_w, handle_th, handle_bar_t]);         // T-Balken (aussen)
}

// Ein druckfertiges Segment (Index 0 .. num_segments-1): Ausschnitt aus
// der Gesamtspange, plus maennliche Duebel am rechten Nachbar-Stoss
// (falls vorhanden), plus Fuss+Rastarm NUR am untersten Ende (Segment 0).
module segment_geometry(i) {
    x0 = (i == 0) ? 0 : split_positions[i - 1];
    x1 = (i == num_segments - 1) ? bracket_total_length : split_positions[i];

    // ACHTUNG (Ursache des "Duebel haengen in der Luft"-Fehlers): diese
    // Schnittbox war frueher nur bracket_thickness+2 = 10mm tief (Y=-1..9).
    // Sie soll das Segment NUR in X begrenzen, hat aber die Bruecke, die bis
    // Y=joint_boss_y0+joint_boss_thickness (18.9) reicht, bei Y=9 abgesaebelt
    // - und damit auch das Material um die Duebel herum. Die Tiefe richtet
    // sich jetzt nach der tatsaechlich vorhandenen Geometrie.
    clip_y_hi = max(bracket_thickness, joint_boss_y0 + joint_boss_thickness) + 1;

    intersection() {
        full_bar_cut();
        translate([x0, -1, -1])
            cube([x1 - x0 + 0.002, clip_y_hi + 1, bracket_height + 2]);
    }
    if (i < num_segments - 1)
        dowel_male_pins(split_positions[i]);
    if (with_handle && i == handle_seg) t_handle();  // T-Griff nur auf Segment 2
    // Fuss + Rastarm (alter Klickverschluss) ENTFERNT - der Rahmen liegt
    // jetzt auf dem Profil auf (flange()) und wird nach oben herausgehoben.
}

// Kippt ein Segment fuer den Druck, so dass die Trennebene (Stossflaeche)
// flach auf dem Bett liegt: die Laengsachse (X) wird zur Druck-Z-Achse.
// Nimmt bewusst die TATSAECHLICHE min/max-X-Ausdehnung der Geometrie
// entgegen (nicht nur die nominelle Segmentgrenze x0/x1), da die
// Duebel-Zapfen und der Fuss ueber die nominellen Grenzen hinausragen
// koennen (siehe RENDER-Abschnitt, wo true_min_x/true_max_x berechnet
// werden). Seit der Fuss nur noch am Segment-0-Ende sitzt (das ohnehin
// schon x0 seiner eigenen Grenze ist) braucht es kein flip/mirror mehr -
// jedes Segment mappt einfach true_min_x -> Druck-Z=0.
module print_orientation(true_min_x, true_max_x) {
    translate([bracket_height, 0, 0])
        rotate([0, -90, 0])
            translate([-true_min_x, 0, 0])
                children();
}

// Separates Sockelstueck: wird mit 2x M3-Senkschrauben an die Kofferwand
// geschraubt, bietet einen HORIZONTALEN, OBEN OFFENEN Kanal fuer den
// Rastarm (offen zur Wandseite hin, wo der Arm herkommt, UND offen nach
// oben - kein Deckel).
//
// Mechanik (2. Ueberarbeitung nach Nutzer-Feedback - Version 1 hatte eine
// 1.5mm-Rastnase in einer geschlossenen Tasche, weder erkennbar noch
// loesbar). Jetzt ist die Rastkontur komplett im Sockel: ein kleiner Zahn
// auf dem Kanalboden (Rampe zum Einfuehren, steile Rueckflanke zum
// Sperren). Der Arm selbst ist ein einfacher flacher Federstreifen ohne
// eigene Nase (siehe snap_arm()).
//   Einschieben (+Y): der duenne Arm federt beim Ueberfahren des Zahns
//   kurz nach oben durch (der Kanal ist offen, das kann er frei), faellt
//   danach dahinter zurueck auf den Kanalboden.
//   Loesen: von OBEN (Kanal ist offen!) den Arm am Zahn mit dem Finger
//   leicht anheben, dabei den Rahmen von der Wand weg aus dem Kanal
//   ziehen. Kein Zusatzteil noetig - der offene Kanal selbst ist der
//   Zugang zum Loesen.
module sockel() {
    channel_w = arm_width + sockel_channel_clear;

    difference() {
        cube([sockel_w, sockel_d, sockel_h]);

        // 2x M3-Senkbohrung zur Befestigung an der Kofferwand (unten am
        // Wand/Boden-Uebergang, nicht auf dem Boden liegend)
        for (pos = [[sockel_screw_inset, sockel_screw_inset], [sockel_w - sockel_screw_inset, sockel_d - sockel_screw_inset]])
            translate([pos[0], pos[1], -1]) {
                cylinder(d = sockel_screw_dia, h = sockel_h + 2, $fn = 24);
                translate([0, 0, sockel_h - 2.5])
                    cylinder(d1 = sockel_screw_dia, d2 = sockel_screw_head_dia, h = 2.5 + 1, $fn = 24);
            }

        // Horizontaler Kanal, offen zur Wandseite (Y=0) UND offen nach
        // oben (reicht bis zur Sockel-Oberkante durch).
        translate([sockel_w / 2 - channel_w / 2, -1, sockel_channel_z0])
            cube([channel_w, arm_length + 2, sockel_h]);
    }

    // Rastzahn auf dem Kanalboden: Rampe (Einfuehrschraege) + steile
    // Rueckflanke (Sperrkante). Wird NACH dem Kanal-Ausschnitt oben
    // wieder als Material hinzugefuegt (ausserhalb des difference()).
    translate([sockel_w / 2 - channel_w / 2, sockel_tooth_pos, sockel_channel_z0])
        linear_extrude(height = channel_w)
            rotate([90, 0, 90])
                polygon(points = [
                    [0, 0],
                    [sockel_tooth_ramp, sockel_tooth_height],
                    [sockel_tooth_ramp + sockel_tooth_width, sockel_tooth_height],
                    [sockel_tooth_ramp + sockel_tooth_width, 0],
                ]);
}

// ======================================================================
// RENDER
// ======================================================================
if (render_segment == -1) {
    // Uebersicht zur Kontrolle - Segmente in ihrer natuerlichen
    // Modellraum-Lage (NICHT fuer den Druck! nur Sichtpruefung).
    // X ist hier noch horizontal gezeichnet; bei installiertem Bracket
    // steht diese Achse VERTIKAL an der Kofferwand (X=0 unten am Sockel).
    // full_bar_cut() enthaelt bereits die T-Stueck+Gabel-Verbinder an
    // allen 6 Rail-Positionen (rail_connector(), s.o.) - kein separates
    // Beispielteil mehr noetig.
    color("steelblue") full_bar_cut();
    for (sp = split_positions) color("orange") dowel_male_pins(sp);
} else if (render_segment >= 0 && render_segment < num_segments) {
    i = render_segment;
    x0 = (i == 0) ? 0 : split_positions[i - 1];
    x1 = (i == num_segments - 1) ? bracket_total_length : split_positions[i];
    has_pin_right  = (i < num_segments - 1);
    // Tatsaechliche X-Ausdehnung inkl. Duebel-Zapfen-Ueberstand (ragt
    // dowel_len+1mm ueber die Split-Position ins Nachbarsegment) - siehe
    // dowel_male_pins(). (Fuss entfaellt jetzt, s.o.)
    true_min_x = x0;
    true_max_x = has_pin_right ? (split_positions[i] - 1) + (dowel_len + 1) : x1;
    print_orientation(true_min_x, true_max_x)
        segment_geometry(i);
} else if (render_segment == 10 || render_segment == 11) {
    sockel();
}
