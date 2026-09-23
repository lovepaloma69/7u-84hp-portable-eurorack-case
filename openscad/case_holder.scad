// ======================================================================
// case_holder.scad  -- AUFLAGE-SCHIENE ("Profil") + SCHIEBE-RIEGEL
//
// Bleibt FEST im Koffer (an einer kurzen Wand). Traegt den entnehmbaren
// Rahmen (Bracket+Schienen+Module), der AUFLIEGT (Flansch auf der Schiene)
// und nach oben herausgehoben wird.
//
// Halt im Koffer:
//   - Nase liegt auf der internen Kante (13 mm unter dem Rand, 2-3 mm tief)
//   - 2 Schrauben waagerecht in die Kofferwand (B)
//   - OPTIONAL: Einhaengezaehne (with_teeth) in die Wand-Rillen (<=1 mm
//     dick, <=2 mm lang) - Variante zum Ausprobieren.
//   Bleibt komplett unter dem Dichtrand (Deckel schliesst).
//
// SICHERUNG (Schiebe-Riegel, eigenes Druckteil):
//   Nach dem Einlegen des Rahmens wird der Riegel von oben nach INNEN
//   geschoben; sein Balken legt sich ueber die Oberkante des Bracket-
//   Flansches (z=74) -> Rahmen kann nicht mehr hoch. Zurueckschieben =
//   offen. Gefuehrt zwischen zwei L-Schienen (greifen ueber die Riegel-
//   kanten und halten ihn nieder); ein mittiger Griff steht ZWISCHEN den
//   Schienen nach oben und ist von oben mit dem Finger bedienbar. Alles
//   bleibt unter dem Dichtrand (80 mm).
//
// Koordinaten (Koffer-Einbaulage):
//   X = entlang der kurzen Wand (Schienen-Laengsrichtung)
//   Y = von der Wand nach innen; Wand-Innenflaeche (untere Wand) bei Y=0
//   Z = senkrecht; Boden=0, interne Kante=67, Dichtrand=80
// ======================================================================
$fn = 40;

// ---- gemessene Koffer-/Rahmen-Werte ----
ledge_z      = 67;    // interne Kante (13 mm unter Rand 80)
rim_z        = 80;    // Dichtrand (tabu darueber)
ledge_lip    = 2.5;   // wie weit die Kante nach aussen vorsteht (2-3 mm)
// Der Rahmen HAENGT jetzt an seiner FRONT-Kante (Flansch am Bracket-Z=0):
// Front zeigt nach oben, Modulkoerper haengen in den Koffer. rest_z ist die
// Auflageflaeche (Flansch-Unterseite). Tiefer als die Kante (67) gesetzt,
// damit die Front ~16 mm unter der Oeffnung liegt -> Luft fuer Kabel/Potis.
rest_z       = 63.5;  // Oberkante Auflage = Unterseite Rahmen-Flansch
flange_top_z = rest_z + 4;  // Oberkante haengender Flansch (=Front) = 67.5
                            //   -> knapp UEBER Kantenhoehe 67: der Hebel liegt
                            //   direkt auf dem Flansch (kein Spiel, haelt fest),
                            //   raeumt aber die Nase (67) beim Schwenken frei.
nose_top_z   = ledge_z;     // Nase reicht auf Kantenhoehe 67 (haengt an der Kante)
flange_y0    = 7;     // Flansch in Y von 7 (aussen) ..
flange_y1    = 15;    //   .. 15 (siehe Passung-Check im Bracket)

// ---- Profil-Masse ----
prof_len       = 75;    // KURZ: 2 je Wand in die freien End-Zonen des Brackets
                        //   (0..86mm und 225..311mm). Die Verstaerkungs-Kloetze an
                        //   den Segment-Stoessen (Sperrzonen 86..122 und 189..225mm)
                        //   reichen bis auf Auflagehoehe -> ein Profil DORT wuerde den
                        //   Rahmen aufbocken. Darum kurz + an die Enden.
web_t          = 4;     // Dicke der Rueckwand (gegen die Kofferwand)
shelf_in       = 8;     // wie weit die Auflage nach innen reicht
shelf_t        = 3.5;   // Dicke der Auflage
web_bot_z      = 48;    // Rueckwand reicht so weit nach unten (fuer Schrauben)
gusset         = 6;     // Dreiecks-Verstaerkung unter der Auflage

// ---- Schrauben (B), waagerecht in die Kofferwand ----
// Eine Reihe TIEF, damit Kopf/Senkung nicht in die Flansch-/Auflage-Ebene
// (>=60) ragt (dort brach der Nutzer eine ueberlappende Kante ab).
screw_d        = 3.6;   screw_head_d = 7.2;   screw_head_t = 2.4;
screw_z        = [ 54 ];   // Kopf 50.4..57.6, klar unter Auflage (60) & Flansch (63.5)

// ---- Einhaengezaehne (optional, Variante) ----
with_teeth   = false;  // true = Zaehne an der Nase, greifen in die Wand-Rillen
tooth_th     = 1.0;    // Spitzen-Dicke (Y) - <= 1 mm (Spitze muss in die Rille);
                       //   Basis ist per Taper dicker -> bricht nicht mehr ab
tooth_len    = 6.0;    // Laenge nach unten (Z) - LANG bleibt (guter Halt, war ok)
tooth_w      = 4.0;    // Breite (X) - groesser
tooth_pitch  = 8;      // Zahn-Abstand (gleich wie vorher)
tooth_base_th= 2.4;    // Dicke (Y) an der Wurzel (Taper von 1 mm Spitze -> hier)

// ---- SCHNAPP-/KLICK-Verschluss (Sicherung) ----
// Biegsame Rast-Zunge am Profil: HOCH in Z (steif -> haelt den Flansch nieder,
// auch bei Erschuetterung), aber DUENN in Y (biegt seitlich zum Loesen). Der
// Haken oben rastet ueber die Flansch-Oberkante; eine Einlauf-Schraege laesst
// die Zunge beim Einlegen automatisch wegfedern und dann einschnappen.
// Loesen: Griff-Steg zur Wand druecken, Rahmen hoch. Optionale Transport-
// Schraube (with_tscrew) klemmt die Zunge zusaetzlich fest.
with_riegel  = true;
snap_n       = 2;             // Zungen je Profil
snap_x       = 17;            // |X|-Position der Zungen
snap_len     = 30;           // Zungen-Laenge (X)
snap_yt      = 2.2;          // Zungen-Dicke (Y) - die federnde Zunge an der Wand
snap_y       = 1.8;          // Zunge/Saeule GANZ an die Wand (Y=1.8..4.0, ueber die
                             //   Rueckwand). NICHTS auf der Auflage (Y>=4) -> Bracket flach.
snap_z0      = flange_top_z; // 67.5 Arm-Unterkante = Flansch-Oberkante
snap_z1      = snap_z0 + 4;  // 71.5
hook_reach   = 4.0;          // Arm bis Y=8 -> ~1 mm Ueberdeckung ueber die Flansch-Kante (7)
hook_h       = 4.0;          // Arm VOLL HOCH (war 2.2 duenne Lippe -> brach): massiver
                             //   Balken z=67.5..71.5, biegt/bricht nicht mehr
arm_w        = 20;           // Arm-BREITE (X) - war 8, jetzt richtig breit (viel Platz da)
anchor_w     = 12;           // BREITE der Verbindung/Hals (X), womit der Arm am Profil
                             //   sitzt - >= halbe Arm-Breite (war nur 4 -> Arm brach ab)
single_arm   = false;        // false = 2 Arme (FESTE Seite); true = 1 Arm mittig (LOESE-Seite)
neck_single  = 6;            // Anker-Breite der Loese-Seite (halb so breit)
flex_len     = 26;           // Laenge der waagerechten Feder-Zunge (X) = Federweg
flex_w       = 10;           // Breite von Hook/Griff (X) der Feder-Zunge

// ---- SEPARATER Feder-CLIP (Loese-Seite): Profil B wird FLACH mit Zaehnen
//   gedruckt (Zaehne stark) + Schlitz; der Clip steckt hinein und wird AUFRECHT
//   einzeln gedruckt -> die Feder-Zunge biegt in der Layer-Ebene = bruchfest.
with_clipslot = false;       // true = Schlitz fuer den Clip in die Rueckwand (Profil B flach)
clip_len      = 28;          // Gesamtlaenge Clip (X)
clip_foot_w   = 12;          // Fuss-Breite (X), steckt im Schlitz
clip_foot_t   = 2.6;         // Fuss-Dicke (Y)
clip_yt       = 2.8;         // Zungen-Dicke (Y) - federt, aber robust (aufrecht = Layer-Ebene)
clip_foot_z0  = web_bot_z + 8;  // Fuss-Unterkante (steckt bis hier runter im Schlitz)
clip_barb_h   = 0.7;            // Ueberstand der Schnapp-Nase (Rast gegen Herausziehen)
clip_barb_z0  = clip_foot_z0 + 2;  // Nase sitzt hier (rastet in den Schlitz-Recess)
clip_screw_d  = 3.2;            // optionales Schraubloch (selbstschneidend, Transport-Sicherung)
arm_count    = 2;            // 2 = Profil 1 (FEST, 2 Arme); 1 = Profil 2 (FEDERND, 1 Arm mittig)
                             //   Profil 2: mit -D arm_count=1 -D anchor_w=6 exportieren
with_grip    = false;        // Profil-1-Griff-Variante: zentraler Hebel-Steg nach OBEN
                             //   (Modul-Richtung) zum Rauskippen. Mit -D with_grip=true
grip_top_z   = 77;           // Oberkante Griff-Steg (unter Dichtrand 80)
grip_z       = snap_z1 + 3;  // 74.5 Griff-Steg-Oberkante (unter Rand 80)
snap_slot    = 1.4;          // Spalt hinter/neben der Zunge (Federweg + Druck)
with_tscrew  = false;        // optionale Transport-Schraube (klemmt die Zunge)
tscrew_pilot = 2.6;

render_part = 0;   // 0=Profil+Hebel (offen), 1=Profil druckfertig, 2=Hebel druckfertig,
                   // 3=Kontroll: Profil+Hebel ZU (+Flansch-Attrappe), 4=Draufsicht offen+zu

// ----------------------------------------------------------------------
// Einhaengezaehne (Stueck B): sitzen an der NASEN-UNTERSEITE - der Flaeche,
// die auf der Kante aufliegt - und zeigen nach UNTEN in die waagerechten
// Rillen der Kante. Reihe entlang der Wand (X), Abstand tooth_pitch (<=20mm).
// tooth_th (<=1 mm) duenn in Y (quer zur Rille), tooth_len (<=2 mm) tief nach
// unten. tooth_w breit in X (entlang der Rille). Beim Aufsetzen des Profils
// fallen die Zaehne in die Rillen und haengen sich ein.
// Nasen-Unterseite liegt bei z = ledge_z - shelf_t; Zaehne ragen von dort
// tooth_len nach unten. Mittig ueber der Kante (Y = -ledge_lip .. 0).
tooth_y = -ledge_lip + tooth_th/2;   // Zaehne an der AEUSSERSTEN Kante von B
                                     // (Aussenflaeche buendig mit der Nasen-Aussenkante Y=-ledge_lip)
module hook_teeth() {
    for (x = [-prof_len/2 + 15 : tooth_pitch : prof_len/2 - 15]) {
        yo = tooth_y - tooth_th/2;                        // Aussenflaeche (buendig Nasenkante)
        // duenne Spitze, volle Laenge -> passt in die Rille, guter Halt
        translate([x - tooth_w/2, yo, ledge_z - shelf_t - tooth_len])
            cube([tooth_w, tooth_th, tooth_len + 0.6]);   // X=Breite, Y=1mm duenn, Z=nach unten
        // Wurzel-Taper: obere 2 mm von 1 mm auf tooth_base_th aufweiten -> bricht nicht ab
        hull() {
            translate([x - tooth_w/2, yo, ledge_z - shelf_t - 2.0]) cube([tooth_w, tooth_th, 0.1]);
            translate([x - tooth_w/2, yo, ledge_z - shelf_t])        cube([tooth_w, tooth_base_th, 0.6]);
        }
    }
}

// Rast-Zunge (Teil des Profils): am AUSSEREN Ende verankert, Cantilever zur
// Mitte. Duenn in Y (federt seitlich zum Loesen), hoch in Z (steif -> haelt
// den Flansch nieder). Am freien Ende ein Haken ueber den Flansch + Einlauf-
// Schraege (Flansch drueckt die Zunge beim Einlegen weg, dann Klick) + Griff.
module one_snap() {                              // rechter Schnapper (X>0)
    xa = prof_len/2 - 3;
    xf = xa - snap_len;                          // Arm-Ende (Mitte-waerts)
    // BREITE Verbindung (Hals): solide Wand unter dem Arm auf der Wandseite
    // (Y=0.5..4), von der Rueckwand hoch bis zur Arm-Ebene. anchor_w breit
    // (>= halbe Arm-Breite) -> der Arm sitzt satt am Profil statt an duennem Hals.
    translate([xf + arm_w - anchor_w, 0.5, ledge_z - 4])
        cube([anchor_w, snap_y + snap_yt - 0.5, snap_z1 - (ledge_z - 4)]);
    // Basis-Steg unter dem Arm (volle Arm-Breite) - traegt den Haken
    translate([xf, snap_y, snap_z0]) cube([arm_w, snap_yt, snap_z1 - snap_z0]);
    // Haken/Arm ueber den Flansch (45°-Einlauf unten-innen)
    translate([xf, snap_y + snap_yt, snap_z0]) rotate([90, 0, 90])
        linear_extrude(height = arm_w)
            polygon([[1.4, 0], [hook_reach, 0], [hook_reach, hook_h],
                     [0, hook_h], [0, 1.4]]);
    // Griff-Steg
    translate([xf, snap_y - 1, snap_z1]) cube([arm_w, snap_yt + 2, grip_z - snap_z1]);
}
module one_snap_center() {                       // Profil 2 (LOESE-Seite): EIN federnder Arm
    // WAAGERECHTE Feder-Zunge: verankert rechts, Hook am freien (linken) Ende.
    // Biegt in Y in der XY-Ebene -> hochkant gedruckt federt sie IN der Layer-Ebene
    // (bruchfest) und laesst sich zum Loesen wegdruecken. Grob mittig auf dem Profil.
    xa = flex_len/2;                             // Anker rechts
    xf = -flex_len/2;                            // freies Ende (Hook/Griff) links
    // schmaler Anker verbindet die Zunge mit dem Profil
    translate([xa - neck_single, 0.5, ledge_z - 4])
        cube([neck_single, snap_y + snap_yt - 0.5, snap_z1 - (ledge_z - 4)]);
    // duenne, lange Zunge -> federt weich in Y
    translate([xf, snap_y, snap_z0]) cube([flex_len - neck_single, snap_yt, snap_z1 - snap_z0]);
    // Hook am freien Ende ueber den Flansch (45°-Einlauf)
    translate([xf, snap_y + snap_yt, snap_z0]) rotate([90, 0, 90])
        linear_extrude(height = flex_w)
            polygon([[1.4, 0], [hook_reach, 0], [hook_reach, hook_h], [0, hook_h], [0, 1.4]]);
    // Griff zum Wegdruecken (loesen)
    translate([xf, snap_y - 1, snap_z1]) cube([flex_w, snap_yt + 2, grip_z - snap_z1]);
}
module snap_hooks() {
    if (arm_count == 1) one_snap_center();       // Profil 2 (federnd)
    else { one_snap(); mirror([1, 0, 0]) one_snap(); }  // Profil 1 (fest, unveraendert)
}

// Schlitz in der Rueckwand (mittig) fuer den Clip-Fuss (nur Profil B, flach)
module clip_slot() {
    translate([-0.2, 0.9, clip_foot_z0 - 1])
        cube([clip_foot_w + 0.4, clip_foot_t + 0.3, nose_top_z - (clip_foot_z0 - 1) + 0.1]);
    // Recess fuer die Schnapp-Nase (die Innenwand ist hier freigestellt, oben bleibt
    // sie stehen -> die Nase rastet ein und faengt beim Herausziehen)
    translate([1.5, 3.3, clip_barb_z0 - 1])
        cube([clip_foot_w - 3, 1.5, 3]);
}
// Separater Feder-CLIP: Fuss (steckt im Schlitz) + waagerechte Feder-Zunge +
// Hook ueber den Flansch + Griff. AUFRECHT drucken (render_part=8) -> die Zunge
// federt in Y in der Layer-Ebene = bruchfest. Loesen: Griff wegdruecken.
module flex_clip() {
    tl = clip_len - clip_foot_w;                 // Zungenlaenge (freies Teil)
    difference() {
        union() {
            // Fuss (X=0..clip_foot_w) - steckt im Schlitz
            translate([0, 1.0, clip_foot_z0]) cube([clip_foot_w, clip_foot_t, snap_z1 - clip_foot_z0]);
            // Schnapp-Nase an der Fuss-Innenseite: Rampe unten (reindruecken), flach
            // oben (faengt beim Herausziehen). Rastet in den Schlitz-Recess.
            translate([2, 1.0 + clip_foot_t, clip_barb_z0]) rotate([90, 0, 90])
                linear_extrude(clip_foot_w - 4)
                    polygon([[0, 0], [clip_barb_h, 1.0], [0, 2.0]]);
            // Feder-Zunge (X=-tl..0), duenn in Y
            translate([-tl, snap_y, snap_z0]) cube([tl, clip_yt, snap_z1 - snap_z0]);
            // Hook am freien Ende ueber den Flansch (45°-Einlauf)
            translate([-tl, snap_y + clip_yt, snap_z0]) rotate([90, 0, 90])
                linear_extrude(height = flex_w)
                    polygon([[1.4, 0], [hook_reach, 0], [hook_reach, hook_h], [0, hook_h], [0, 1.4]]);
            // Griff
            translate([-tl, snap_y - 1, snap_z1]) cube([flex_w, clip_yt + 2, grip_z - snap_z1]);
        }
        // optionales Schraubloch (durch den Fuss, Transport-Sicherung in die Wand)
        translate([clip_foot_w/2, 1.0 + clip_foot_t + 0.5, clip_foot_z0 + 9]) rotate([90, 0, 0])
            cylinder(d = clip_screw_d, h = clip_foot_t + 2, $fn = 24);
    }
}

module grip_lever() {                            // Profil-1-Griff: zentraler Hebel-Steg nach OBEN
    translate([-5, web_t - 2.5, nose_top_z])     //   (Modul-Richtung), an der Nasen-Innenseite hoch
        cube([10, 2.5, grip_top_z - nose_top_z]);
    translate([-9, web_t - 2.5, grip_top_z - 2.5]) // breiter T-Kopf, innen ueberstehend -> zum Untergreifen
        cube([18, 5, 2.5]);
}

module profil() {
    difference() {
        union() {
            translate([-prof_len/2, 0, web_bot_z])                       // Rueckwand (bis Nasen-Oberkante)
                cube([prof_len, web_t, nose_top_z - web_bot_z]);
            translate([-prof_len/2, -ledge_lip, ledge_z - shelf_t])      // Nase auf der Kante (fest 63.5..70)
                cube([prof_len, ledge_lip + web_t, nose_top_z - (ledge_z - shelf_t)]);
            translate([-prof_len/2, web_t, rest_z - shelf_t])            // Auflage nach innen (tiefer, 56.5..60)
                cube([prof_len, shelf_in, shelf_t]);
            for (gx = [-prof_len/2 + 12, -gusset/2, prof_len/2 - 12 - gusset]) // Gussets (mittleres zentriert)
                translate([gx, web_t, rest_z - shelf_t])
                    rotate([90, 0, 90]) linear_extrude(height = gusset)
                        polygon([[0,0],[shelf_in,0],[0,-gusset]]);
            if (with_teeth)  hook_teeth();
            if (with_riegel) snap_hooks();
            if (with_grip)   grip_lever();
        }
        for (z = screw_z)                                                // Wandschrauben
            for (x = [-prof_len/2 + 6, prof_len/2 - 6])                   // GANZ AUSSEN (klar an den Stütz-Gussets vorbei, auch bei schmalem Profil B)
                translate([x, web_t + 0.5, z]) rotate([90, 0, 0]) {
                    cylinder(d = screw_d, h = web_t + ledge_lip + 2);
                    cylinder(d = screw_head_d, h = screw_head_t + 0.5);
                }
        if (with_clipslot) clip_slot();   // Schlitz fuer den Feder-Clip (Profil B, flach)
    }
}

// ======================================================================
flange_dummy_col = "#3d86c6";
module flange_dummy() {                        // Rahmen-Flansch-Attrappe (zum Kontrollieren)
    translate([-prof_len/2, flange_y0, rest_z])
        cube([prof_len, flange_y1 - flange_y0, flange_top_z - rest_z]);
}
if (render_part == 0) {                        // Profil mit Snap-Zungen (Einbaulage)
    profil();
} else if (render_part == 1) {                 // Profil druckfertig (flach)
    rotate([-90, 0, 0]) translate([0, -web_bot_z, 0]) profil();
} else if (render_part == 2) {                 // = 0
    profil();
} else if (render_part == 3) {                 // Kontroll: Profil + Flansch-Attrappe
    color("#3f9e6c") profil();
    color(flange_dummy_col) flange_dummy();
} else if (render_part == 4) {                 // = 3
    color("#3f9e6c") profil();
    color(flange_dummy_col) flange_dummy();
} else if (render_part == 5) {                // VOLLMONTAGE: Profil (Snap) + echtes
    color("#3f9e6c") profil();                //   Bracket-Segment in Einbaulage (haengend)
    // export/segment_1.stl: (ex=Bracket-Hoehe, ey=Bracket-Y, ez=Laenge) ->
    // Koffer: case_x=ez-55, case_y=23-ey, case_z=flange_top_z-ex
    color([0.24,0.52,0.78]) multmatrix([[0,0,1,-55],[0,-1,0,23],[-1,0,0,flange_top_z],[0,0,0,1]])
        import("export/segment_1.stl");
    // Boden/Rand-Referenz
    color([0.8,0.8,0.8,0.25]) translate([-prof_len/2, -6, 0]) cube([prof_len, 60, 1]);   // Boden z=0
} else if (render_part == 7) {                // Profil HOCHKANT-druckfertig (fuer den
    translate([0, 0, -web_bot_z]) profil();   //   federnden Arm: Feder biegt in Layer-Ebene)
} else if (render_part == 8) {                // Feder-CLIP allein, AUFRECHT druckfertig
    translate([0, 0, -clip_foot_z0]) flex_clip();
} else if (render_part == 9) {                // Kontrolle: Profil B (flach) + Clip gesteckt + Flansch
    color("#3f9e6c") profil();
    color("#e08a2a") flex_clip();
    color(flange_dummy_col) flange_dummy();
}
