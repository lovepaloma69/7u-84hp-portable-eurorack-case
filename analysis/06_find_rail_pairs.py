#!/usr/bin/env python3
"""Schritt 1f: Rail-Paar-Muster in Koerper 0 finden (3U+3U+1U Hypothese).
Sucht nach Merkmalsclustern entlang Y (erhoehtes Zmax = Schraubdom/Zapfen),
gruppiert benachbarte Cluster zu Paaren (Rail-oben + Rail-unten je Reihe)
und misst den Abstand zwischen den Paar-Zentren."""
import trimesh
import numpy as np

STL_PATH = "printables/variant1/variant1_top_bracket.stl"
mesh = trimesh.load(STL_PATH)
bodies = mesh.split(only_watertight=False)
body0 = bodies[0]

verts = body0.vertices
ys = verts[:, 1]
zs = verts[:, 2]
y_min, y_max = ys.min(), ys.max()

# Feines Scanning: Zmax je 0.5mm-Band
band_w = 0.5
edges = np.arange(y_min, y_max + band_w, band_w)
centers = []
zmax_list = []
for i in range(len(edges) - 1):
    mask = (ys >= edges[i]) & (ys < edges[i + 1])
    if mask.sum() == 0:
        zmax_list.append(np.nan)
    else:
        zmax_list.append(zs[mask].max())
    centers.append((edges[i] + edges[i + 1]) / 2)
centers = np.array(centers)
zmax_arr = np.array(zmax_list)

# Baseline = haeufigster/niedrigster Zmax-Wert (Grundniveau der Spange ohne Merkmale)
valid = ~np.isnan(zmax_arr)
baseline = np.nanpercentile(zmax_arr, 25)
print(f"Baseline Zmax (25. Perzentil): {baseline:.2f}")
threshold = baseline + 1.0

# Zusammenhaengende Baender ueber der Schwelle = ein "Merkmal" (Schraubdom/Zapfen)
above = valid & (zmax_arr > threshold)
features = []
in_feat = False
for i in range(len(centers)):
    if above[i] and not in_feat:
        start = centers[i]
        in_feat = True
    if in_feat and (not above[i] or i == len(centers) - 1):
        end = centers[i] if not above[i] else centers[i]
        features.append((start, end, (start + end) / 2))
        in_feat = False

print(f"\n{len(features)} einzelne Merkmal-Baender gefunden (Y-Start, Y-Ende, Zentrum):")
for f in features:
    print(f"  [{f[0]:8.2f}, {f[1]:8.2f}]  Zentrum={f[2]:8.2f}  Breite={f[1]-f[0]:.2f}")

# Cluster benachbarte Merkmale (Luecke < 15mm) zu "Paaren"
print(f"\n=== Gruppierung zu Paaren (Luecke < 15mm = gleiche Reihe) ===")
pair_groups = []
cur_group = [features[0]]
for f in features[1:]:
    gap = f[0] - cur_group[-1][1]
    if gap < 15:
        cur_group.append(f)
    else:
        pair_groups.append(cur_group)
        cur_group = [f]
pair_groups.append(cur_group)

pair_centers = []
for g in pair_groups:
    y0 = g[0][0]
    y1 = g[-1][1]
    center = (y0 + y1) / 2
    pair_centers.append(center)
    print(f"  Gruppe: Y=[{y0:.2f},{y1:.2f}] Zentrum={center:.2f}  ({len(g)} Merkmale)")

print(f"\n=== Abstaende zwischen Gruppenzentren ===")
for i in range(1, len(pair_centers)):
    gap = pair_centers[i] - pair_centers[i - 1]
    print(f"  Gruppe {i-1} -> Gruppe {i}: {gap:.2f}mm  (3U=128.5mm? 1U=~44.45mm?)")
