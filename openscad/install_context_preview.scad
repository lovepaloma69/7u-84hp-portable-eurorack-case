// ======================================================================
// Installationskontext-Vorschau: nutzt die ECHTEN, validierten Module aus
// bracket.scad (Bracket + Sockel + T-Nutenstein) und ergaenzt eine
// schematische Kofferwand/-boden sowie Platzhalter fuer Schienen und
// Module, damit erkennbar ist, wie das Bracket real montiert werden
// soll. Nur zur Visualisierung, kein eigenstaendiges Druckteil.
//
// Die Bracket-Geometrie selbst ist im MODELLRAUM von bracket.scad mit X
// als Laengsachse definiert (siehe dortiger Kommentar). Hier wird die
// gesamte Baugruppe um 90 Grad gekippt (rotate([0,-90,0])), damit X zur
// WELT-Z-Achse (vertikal, an der Wand) wird - so wie das Bracket real
// montiert wird.
//
// KORREKTUR ggue. der vorherigen Fassung: die Schienen-/Modul-Platzhalter
// zeigten faelschlich in +Y (in Richtung Spangen-Material/Wand) statt
// -Y (vom Bracket weg, in den Koffer hinein) - jetzt korrigiert. Ausserdem
// zeigt diese Fassung den echten rail_tnut() an jeder der 6 Positionen,
// nicht nur einen simplen Platzhalter-Steg.
// ======================================================================
// "include" statt "use", damit auch die Variablen (rail_positions,
// bracket_total_length, ...) aus bracket.scad verfuegbar sind, nicht nur
// die Module. Der RENDER-Block am Ende von bracket.scad wird beim Aufruf
// per "-D render_segment=99" unterdrueckt (Kommandozeile hat Vorrang vor
// dem Default in bracket.scad).
include <bracket.scad>

$fn = 32;

case_depth = 140;        // wie weit der Koffer in den Raum hinein reicht (Y)
case_extra_height = 40;  // wieviel die Wand ueber das Bracket hinausragt
case_wall_span = 70;     // Breite des gezeigten Wandausschnitts (Weltachse X)
wall_thickness = 6;
floor_thickness = 6;

// -- Schematische Koffer-Innenwand (Weltkoordinaten, vertikal, an Y=0).
//    Die Hochachse ist hier Welt-Z (passend zur um 90 Grad gekippten
//    Bracket-Baugruppe unten, deren Laengsachse jetzt vertikal steht).
//    X-Versatz -15, damit die Bracket-Dicke (Welt-X ca. -30..0 nach dem
//    Kippen) mittig im gezeigten Wandausschnitt liegt. --
color("#B4B2A9", 0.55)
    translate([-case_wall_span / 2 - 15, -wall_thickness, -floor_thickness])
        cube([case_wall_span, wall_thickness, bracket_total_length + case_extra_height]);

// -- Schematischer Koffer-Boden (Weltkoordinaten, horizontal, an Z=0) --
color("#B4B2A9", 0.55)
    translate([-case_wall_span / 2 - 15, -wall_thickness, -floor_thickness])
        cube([case_wall_span, case_depth, floor_thickness]);

// -- Bracket + Fuss/Rastarm + T-Nutensteine + Schienen/Modul-Platzhalter:
//    um 90 Grad gekippt, damit die Laengsachse (6 Schienen-Positionen)
//    vertikal an der Wand steht, wie im echten Einbau. --
rotate([0, -90, 0]) {
    color("#5DCAA5") full_bar_cut();

    color("#7F77DD")
        translate([0, bracket_thickness / 2, 0])
            foot_and_arm();

    rail_len = case_depth - 20;
    module_len = 60;

    // An jeder der 6 Rail-Positionen: der ECHTE T-Nutenstein (liegt an
    // der Spangen-Aussenseite Y=0 an, ragt nach aussen/-Y in den
    // Schienenkanal), plus ein Platzhalter fuer die restliche Schiene,
    // die daran anschliesst und weiter in den Koffer reicht.
    for (p = rail_positions) {
        translate([p, 0, bracket_height / 2])
            rotate([0, 0, 180])
                color("#F0997B") rail_tnut();
        color("#888780")
            translate([p - rail_channel_width / 2, -(tnut_length + rail_len), bracket_height / 2 - rail_channel_depth / 2])
                cube([rail_channel_width, rail_len, rail_channel_depth]);
    }

    // je Reihe EIN Modul-Platzhalter, spannt zwischen oberer und unterer
    // Schiene der jeweiligen Reihe, sitzt VOR den Schienen (weiter in
    // -Y, weiter weg von der Wand). Die farbige Stirnflaeche zeigt "nach
    // vorn" (in Weltkoordinaten nach dem Kippen: -X, also weg von der
    // Wand und nach oben Richtung Kofferoeffnung).
    module_pairs = [[0, 1], [2, 3], [4, 5]];
    for (pr = module_pairs) {
        y0 = rail_positions[pr[0]];
        y1 = rail_positions[pr[1]];
        color("#B4B2A9")
            translate([y0, -(tnut_length + 15 + module_len), 0])
                cube([y1 - y0, module_len, bracket_height]);
        color("#F0997B")
            translate([y0, -(tnut_length + 15 + module_len) - 4, 0])
                cube([y1 - y0, 4, bracket_height]);
    }
}

// -- Sockel: an die Wand geschraubt, unten am Wand/Boden-Uebergang --
color("#AFA9EC")
    translate([-sockel_d / 2, -wall_thickness - sockel_h, -floor_thickness])
        rotate([0, 0, 90])
            sockel();
