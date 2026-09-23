// ======================================================================
// spacer.scad -- ABSTANDSHALTER fuer die langen Kofferwaende (oben/unten)
//
// Bleibt FEST im Koffer an einer langen Wand. Fuellt die ~11 mm Luecke zum
// Eurorack-Rahmen, damit der Rahmen beim Transport nicht nach oben/unten
// wandert. Montage: entweder mit 2 Schrauben in die Wand ODER ueber die flache
// Rueckseite mit doppelseitigem Klebeband. Die Vorderseite hat eine leichte
// Anlaufschraege, damit der Rahmen beim Einlegen von oben sanft zentriert wird.
//
// GEOMETRIE (lokal):
//   X = Laenge entlang der Wand          -> "lang"  (100 mm, schlanker Streifen)
//   Y = gap = Wand -> Rail (Fuellung)    -> "breit" (11 mm = Rest-Abstand
//                                           lange Cover-Unterseite <-> Rail)
//   Z = Hoehe                            -> schlank gehalten (11 mm)
// ======================================================================
$fn = 32;

gap        = 11;    // Luecke lange Cover-Unterseite -> Rail (Fuellung, "breit")
sp_len     = 100;   // Laenge entlang der Wand (X) -- langer schlanker Streifen
sp_h       = 11;    // Hoehe (Z) -- schlank statt klobig
lead_in    = 3;     // Anlaufschraege oben-vorne (zentriert den Rahmen)
back_t     = 3;     // Dicke der Klebe-/Schraub-Rueckwand
scr_d      = 3.6;   // Durchgangsloch fuer Wandschraube
scr_head   = 7.2;
scr_inset  = 18;    // Abstand der Schrauben von den Enden

// Schraubenpositionen entlang X (2 Stueck bei 100 mm gegen Kippeln)
screw_x = [scr_inset, sp_len - scr_inset];

module spacer() {
    difference() {
        cube([sp_len, gap, sp_h]);                        // Block Wand(Y=0) -> Rail(Y=gap)
        // Anlaufschraege oben-vorne (Railseite Y=gap, oben) - zentriert den Rahmen
        translate([-1, gap, sp_h]) rotate([0, 90, 0])
            linear_extrude(sp_len + 2)
                polygon([[0, 0], [lead_in, 0], [0, lead_in]]);
        // Schrauben waagerecht durch die Rueckwand (Y=0) in die Kofferwand
        for (x = screw_x)
            translate([x, -1, sp_h/2]) rotate([-90, 0, 0]) {
                cylinder(d = scr_d, h = gap + 2);
                cylinder(d = scr_head, h = back_t);
            }
    }
}
spacer();
