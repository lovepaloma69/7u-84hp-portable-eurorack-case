// ======================================================================
// assembly_explainer.scad -- NUR Veranschaulichung, kein Druckteil.
// Zeigt: Profil bleibt FEST im Koffer, der Rahmen (Bracket+Module) liegt
// nur auf und wird komplett nach oben herausgehoben. KEIN Fang, kein Riegel.
// explode=1 hebt den Rahmen heraus, damit die Trennung sichtbar ist.
// ======================================================================
$fn = 32;
explode = 0;      // 0 = eingesetzt, 1 = Rahmen herausgehoben
L = 70;
lift = explode * 55;   // wie weit der Rahmen angehoben gezeigt wird

// ---- KOFFERWAND + Kante (FEST) ----
color("#bdbbb4") {
    translate([-L/2, -6, 0]) cube([L, 6, 67]);       // untere Wand
    translate([-L/2, -6, 67]) cube([L, 3, 13]);      // obere Wand (Stufe=Kante bei 67)
}
color("#c0435a") translate([-L/2, -3, 66.6]) cube([L, 3, 0.5]);  // Kante markiert

// ---- PROFIL (FEST im Koffer: Auflage-Schiene) ----
color("#3d7ea6") {
    translate([-L/2, 0, 48]) cube([L, 4, 22]);          // Rueckwand
    translate([-L/2, -2.5, 63.5]) cube([L, 6.5, 6.5]);  // Nase auf der Kante
    translate([-L/2, 4, 66.5]) cube([L, 8, 3.5]);       // Auflage (Oberkante z=70)
}
color("#333") translate([0, -7, 58]) rotate([-90,0,0]) cylinder(d=3.4, h=6);  // Schraube-Andeutung

// ---- RAHMEN (ENTNEHMBAR: Bracket + Flansch + Module) ----
color("#7ec4e8") translate([-L/2, 3, 70 + lift]) cube([L, 11, 4]);   // Auflage-Flansch
color("#6a6a6a") translate([-L/2, 12, 40 + lift]) cube([L, 8, 30]);  // Bracket
color("#e6cfa8") translate([-L/2+3, 20, 20 + lift]) cube([L-6, 40, 50]); // Module

// ---- Pfeil "herausheben" ----
if (explode == 1)
    color("#2e7d32") {
        translate([0, 20, 74]) cylinder(d=4, h=42);
        translate([0, 20, 116]) cylinder(d1=9, d2=0, h=9);
    }
