#!/usr/bin/env python3
"""Schritt 1d: Body 0 korrekt vermessen - Z-Hoehen-Variation entlang Y (Zaehne/Stufen),
und echte Loch-Erkennung ueber direkte 3D-Koordinaten (section.discrete), nicht to_planar()."""
import trimesh
import numpy as np

STL_PATH = "printables/variant1/variant1_top_bracket.stl"
mesh = trimesh.load(STL_PATH)
bodies = mesh.split(only_watertight=False)
body0 = bodies[0]

verts = body0.vertices
ys = verts[:, 1]
zs = verts[:, 2]
xs = verts[:, 0]

y_min, y_max = ys.min(), ys.max()
print(f"Y-Bereich: {y_min:.2f} bis {y_max:.2f} (Laenge {y_max-y_min:.2f}mm)")
print()
print("=== Z-Hoehen-Profil entlang Y (feine Baender, 2mm Schritt) ===")
band_w = 2.0
n_bands = int(np.ceil((y_max - y_min) / band_w))
prev_zmax = None
transitions = []
for i in range(n_bands):
    y0 = y_min + i * band_w
    y1 = y0 + band_w
    mask = (ys >= y0) & (ys < y1)
    if mask.sum() == 0:
        continue
    zmax_band = zs[mask].max()
    zmin_band = zs[mask].min()
    if prev_zmax is None or abs(zmax_band - prev_zmax) > 1.0:
        transitions.append((y0, zmin_band, zmax_band))
    prev_zmax = zmax_band

print(f"{len(transitions)} Uebergaenge gefunden (Y, Zmin, Zmax) bei Aenderung > 1mm:")
for t in transitions:
    print(f"  Y={t[0]:8.2f}  Zmin={t[1]:8.2f}  Zmax={t[2]:8.2f}")

print()
print("=== Grobe Klassifikation: 'hohe' vs 'niedrige' Zonen ===")
band_w = 1.0
n_bands = int(np.ceil((y_max - y_min) / band_w))
zone_log = []
for i in range(n_bands):
    y0 = y_min + i * band_w
    y1 = y0 + band_w
    mask = (ys >= y0) & (ys < y1)
    if mask.sum() == 0:
        continue
    zmax_band = zs[mask].max()
    zone_log.append((y0, zmax_band))

# Gruppiere in Zonen mit aehnlichem zmax (Toleranz 0.5mm)
zones = []
cur_start, cur_val = zone_log[0]
for i in range(1, len(zone_log)):
    y0, val = zone_log[i]
    if abs(val - cur_val) > 0.5:
        zones.append((cur_start, zone_log[i-1][0] + band_w, cur_val))
        cur_start, cur_val = y0, val
zones.append((cur_start, zone_log[-1][0] + band_w, cur_val))
print(f"{len(zones)} Zonen erkannt:")
for z in zones:
    print(f"  Y=[{z[0]:8.2f}, {z[1]:8.2f}]  (Breite {z[1]-z[0]:6.2f}mm)  Zmax={z[2]:8.2f}")

print()
print("=== Echte Loch-Suche via section.discrete (3D-Koordinaten, X-Normale) ===")
x_mid = (body0.bounds[0][0] + body0.bounds[1][0]) / 2
section = body0.section(plane_origin=[x_mid, 0, 0], plane_normal=[1, 0, 0])
if section is not None:
    print(f"Anzahl Polylinien (discrete): {len(section.discrete)}")
    for i, poly3d in enumerate(section.discrete):
        pts = np.array(poly3d)
        y_span = pts[:, 1].max() - pts[:, 1].min()
        z_span = pts[:, 2].max() - pts[:, 2].min()
        cy = pts[:, 1].mean()
        cz = pts[:, 2].mean()
        closed = np.allclose(pts[0], pts[-1])
        print(f"  Polylinie {i}: {len(pts)} Punkte, geschlossen={closed}, "
              f"Y-Spanne={y_span:.2f}, Z-Spanne={z_span:.2f}, Zentrum=({cy:.2f},{cz:.2f})")
