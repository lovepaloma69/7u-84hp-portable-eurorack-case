// ======================================================================
// wood_holder.scad  --  HOLZCASE (7U/84HP, 19 mm Holz)
//
// Block 3, Teil 1: AUFLAGE-HALTERUNG. Wird mit Holzschrauben VON INNEN an
// die kurze Innenwand (links/rechts, wo die Brackets sitzen) geschraubt.
// Der Bracket-FLANSCH (gleicher wie im Koffer) liegt auf der Schiene auf,
// damit der Rahmen nicht ins Case absinkt. Die Schiene sitzt so tief unter
// der Case-Oeffnung, dass die Module oben buendig mit der Oeffnungskante sind.
//
// Der Rahmen ist damit zwischen Koffer und Holzcase wechselbar (gleiches
// Bracket). Teil 2 (Schieber ueber die kurzen Bracket-Kanten) kommt separat.
//
// ALLE Masse zum FEINJUSTIEREN (Fotos folgen). Der WICHTIGSTE Wert ist
// rest_depth -- am echten Case messen und anpassen.
// ======================================================================
$fn = 32;

// ---- Kern-Wert (JUSTIEREN am echten Case) ----
rest_depth   = 4;    // Flansch-UNTERSEITE unter der Oeffnungskante [mm].
                     //   Flansch ist 4 mm dick, Modul-Front = Oberkante Flansch;
                     //   4 mm => Module buendig mit der Oeffnung. Miss nach!

// ---- aus bracket.scad uebernommen (Flansch-Geometrie) ----
flange_reach   = 8;   // wie weit der Flansch zur Wand reicht
frame_wall_gap = 7;   // Flansch-Aussenkante ~7 mm von der Wand (wie im Koffer)

// ---- Halterung ----
hold_len     = 70;    // Laenge entlang der Wand
back_t       = 5;     // Rueckplatte (liegt an der Holzwand)
back_h       = 50;    // Rueckplatte nach unten (Platz fuer 2 Schrauben)
shelf_reach  = 12;    // wie weit die Schiene von der Wand in den Case reicht
shelf_t      = 4;     // Schienen-Dicke
lead_in      = 2.5;   // Anlaufschraege vorn oben (zentriert den Flansch beim Einlegen)

// ---- Holzschrauben (von innen, waagerecht in die Wand) ----
wood_screw_d    = 4.2;   // Durchgangsloch fuer 4 mm Holzschraube
wood_screw_head = 8.5;   // Senkung fuer den Kopf (innenseitig)
wood_screw_ct   = 2.6;   // Senkungstiefe

// Y=0 = Wand (Holz-Innenflaeche). Schienen-Oberkante = z=0 (dort liegt der
// Flansch). Beim Einbau sitzt z=0 also rest_depth unter der Oeffnungskante.
module wood_holder() {
    difference() {
        union() {
            // Schiene: Oberkante z=0, von der Wand (Y=0) shelf_reach in den Case
            translate([0, 0, -shelf_t])
                cube([hold_len, back_t + shelf_reach, shelf_t]);
            // Rueckplatte an der Wand (Y=0..back_t), nach unten
            translate([0, 0, -shelf_t - back_h])
                cube([hold_len, back_t, back_h + shelf_t]);
            // 2 Dreiecks-Gussets unter der Schiene (steift die Auskragung)
            for (gx = [hold_len*0.2, hold_len*0.8 - 6])
                translate([gx, back_t, -shelf_t]) rotate([90,0,90])
                    linear_extrude(6) polygon([[0,0],[shelf_reach,0],[0,-shelf_reach]]);
        }
        // Anlaufschraege vorn oben (Innenkante der Schiene)
        translate([-1, back_t + shelf_reach, 0]) rotate([0,90,0])
            linear_extrude(hold_len+2) polygon([[0,0],[lead_in,0],[0,lead_in]]);
        // 2 Holzschrauben von INNEN (Kopf innen versenkt), waagerecht in die Wand
        for (x = [hold_len*0.22, hold_len*0.78])
            translate([x, back_t + 0.5, -shelf_t - back_h*0.5]) rotate([90, 0, 0]) {
                cylinder(d = wood_screw_d, h = back_t + 2);
                cylinder(d = wood_screw_head, h = wood_screw_ct);   // Senkung innenseitig
            }
    }
}
wood_holder();
