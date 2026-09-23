#!/usr/bin/env python3
"""Schritt 1c: Praezise Vermessung von Koerper 0 (die 311mm-Spange):
Lochpositionen/-durchmesser via Querschnitt, Nub-Verteilung entlang Y."""
import trimesh
import numpy as np

STL_PATH = "printables/variant1/variant1_top_bracket.stl"
mesh = trimesh.load(STL_PATH)
bodies = mesh.split(only_watertight=False)
body0 = bodies[0]

print("=== Koerper 0: Bounding Box ===")
print(f"min: {body0.bounds[0]}")
print(f"max: {body0.bounds[1]}")
print(f"extents: {body0.extents}")
print()

# --- Loch-Erkennung: Querschnitt senkrecht zur X-Achse (Loch-Achse) bei X=Mitte ---
x_mid = (body0.bounds[0][0] + body0.bounds[1][0]) / 2
print(f"=== Querschnitt bei X={x_mid:.2f} (senkrecht zur vermuteten Loch-Achse) ===")
section = body0.section(plane_origin=[x_mid, 0, 0], plane_normal=[1, 0, 0])
if section is None:
    print("Kein Schnitt gefunden bei dieser X-Position, versuche andere Werte...")
else:
    planar, transform = section.to_planar()
    print(f"Anzahl geschlossener Polygone im Schnitt: {len(planar.polygons_closed)}")
    for i, poly in enumerate(planar.polygons_closed):
        area = poly.area
        bounds = poly.bounds
        cx, cy = poly.centroid.x, poly.centroid.y
        # Kreisdurchmesser schaetzen ueber Flaeche (falls kreisrund) und ueber bounds
        diam_from_area = 2 * np.sqrt(area / np.pi)
        width = bounds[2] - bounds[0]
        height = bounds[3] - bounds[1]
        print(f"  Polygon {i}: bounds={bounds}, centroid=({cx:.2f},{cy:.2f}), "
              f"Flaeche={area:.2f}mm^2, Durchmesser(aus Flaeche)={diam_from_area:.2f}mm, "
              f"bbox_w={width:.2f}, bbox_h={height:.2f}")

print()
print("=== Nub/Bump-Verteilung entlang Y (Draufsicht-Ausdehnung in X je Y-Band) ===")
verts = body0.vertices
ys = verts[:, 1]
xs = verts[:, 0]
y_min, y_max = ys.min(), ys.max()
n_bands = 80
edges = np.linspace(y_min, y_max, n_bands + 1)
for i in range(n_bands):
    mask = (ys >= edges[i]) & (ys < edges[i + 1])
    if mask.sum() == 0:
        continue
    xmin_band = xs[mask].min()
    xmax_band = xs[mask].max()
    width = xmax_band - xmin_band
    if width > 8.5:  # Basis-Dicke ist ~8mm, alles darueber ist ein "Nub"
        print(f"  Y=[{edges[i]:.1f},{edges[i+1]:.1f}]  X-Ausdehnung={width:.2f}mm (xmin={xmin_band:.2f}, xmax={xmax_band:.2f})")

print()
print("=== Z-Profil (Stufen) bei festem Y (z.B. Y=0, Mitte) ===")
y_probe = 0.0
section_z = body0.section(plane_origin=[0, y_probe, 0], plane_normal=[0, 1, 0])
if section_z is not None:
    planar_z, transform_z = section_z.to_planar()
    for i, poly in enumerate(planar_z.polygons_closed):
        print(f"  Polygon {i}: bounds={poly.bounds}")
else:
    print("  kein Schnitt bei Y=0")
