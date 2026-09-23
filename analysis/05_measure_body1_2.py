#!/usr/bin/env python3
"""Schritt 1e: Body 1 (Deckplatte) und Body 2 (Kamm-Klammer) praezise vermessen."""
import trimesh
import numpy as np

STL_PATH = "printables/variant1/variant1_top_bracket.stl"
mesh = trimesh.load(STL_PATH)
bodies = mesh.split(only_watertight=False)
body1, body2 = bodies[1], bodies[2]

def hole_diam_via_section(body, axis_normal, axis_origin_idx_val, label):
    section = body.section(plane_origin=axis_origin_idx_val, plane_normal=axis_normal)
    if section is None:
        print(f"  ({label}) kein Schnitt gefunden")
        return
    print(f"  ({label}) {len(section.discrete)} Polylinien:")
    for i, poly3d in enumerate(section.discrete):
        pts = np.array(poly3d)
        mins = pts.min(axis=0)
        maxs = pts.max(axis=0)
        span = maxs - mins
        print(f"    Polylinie {i}: bbox_span={span}, center={(mins+maxs)/2}")

print("=== Body 1 (Deckplatte, 61x10x2mm) ===")
print(f"bounds: {body1.bounds}")
b1_zmid = (body1.bounds[0][2] + body1.bounds[1][2]) / 2
hole_diam_via_section(body1, [0, 0, 1], [0, 0, b1_zmid], "Schnitt Z-Mitte, Blick von oben")

print()
print("=== Body 2 (Kamm-Klammer, 61x15.5x38mm) ===")
print(f"bounds: {body2.bounds}")
b2_zmid_top = body2.bounds[1][2] - 1.0  # knapp unter der Deckflaeche, wo die Loecher sind
hole_diam_via_section(body2, [0, 0, 1], [0, 0, b2_zmid_top], "Schnitt nahe Deckflaeche (Loecher)")

print()
print("=== Body 2 Zahn-Geometrie (Schnitt bei Z=-20, im Zahnbereich) ===")
z_probe = -20.0
section_xy = body2.section(plane_origin=[0, 0, z_probe], plane_normal=[0, 0, 1])
if section_xy is None:
    print(f"  kein Schnitt bei Z={z_probe}")
else:
    for i, poly3d in enumerate(section_xy.discrete):
        pts = np.array(poly3d)
        mins = pts.min(axis=0)
        maxs = pts.max(axis=0)
        print(f"  Polylinie {i}: X=[{mins[0]:.2f},{maxs[0]:.2f}] (Breite {maxs[0]-mins[0]:.2f}), "
              f"Y=[{mins[1]:.2f},{maxs[1]:.2f}] (Breite {maxs[1]-mins[1]:.2f})")

print()
print("=== Body 2 - Schnitt durch einen Zahn (X=25, mitten im ersten Zahn) ===")
hole_diam_via_section(body2, [1, 0, 0], [25, 0, 0], "Zahn-Querschnitt YZ")
