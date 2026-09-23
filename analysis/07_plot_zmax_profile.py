#!/usr/bin/env python3
"""Schritt 1g: Zmax-Profil entlang Y plotten, mit den 6 bekannten Schraublochpositionen
markiert, um das 3U+3U+1U Rail-Paar-Muster visuell zu identifizieren."""
import trimesh
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

mesh = trimesh.load("printables/variant1/variant1_top_bracket.stl")
bodies = mesh.split(only_watertight=False)
body0 = bodies[0]
verts = body0.vertices
ys = verts[:, 1]
zs = verts[:, 2]
y_min, y_max = ys.min(), ys.max()

band_w = 0.5
edges = np.arange(y_min, y_max + band_w, band_w)
centers = []
zmax_list = []
zmin_list = []
for i in range(len(edges) - 1):
    mask = (ys >= edges[i]) & (ys < edges[i + 1])
    if mask.sum():
        zmax_list.append(zs[mask].max())
        zmin_list.append(zs[mask].min())
    else:
        zmax_list.append(np.nan)
        zmin_list.append(np.nan)
    centers.append((edges[i] + edges[i + 1]) / 2)
centers = np.array(centers)
zmax_arr = np.array(zmax_list)
zmin_arr = np.array(zmin_list)

screw_holes_orig_y = [-180.61, -57.82, -46.40, -13.45, -2.01, 120.96]

fig, ax = plt.subplots(figsize=(22, 6))
ax.plot(centers, zmax_arr, label="Zmax(Y)", color="steelblue", linewidth=1.2)
ax.plot(centers, zmin_arr, label="Zmin(Y)", color="darkorange", linewidth=1.2)
for sh in screw_holes_orig_y:
    ax.axvline(sh, color="red", linestyle="--", linewidth=0.8, alpha=0.7)
    ax.text(sh, 162, "S", color="red", ha="center", fontsize=9)
ax.set_xlabel("Y [mm] (0 = Original-STL-Koordinate)")
ax.set_ylabel("Z [mm]")
ax.set_title("Zmax/Zmin-Profil von Koerper 0 entlang Y - rote Linien (S) = die 6 gemessenen Schraublöcher")
ax.legend()
ax.grid(True, linewidth=0.3)
ax.set_xticks(np.arange(-185, 130, 10))
plt.xticks(rotation=90)
plt.tight_layout()
plt.savefig("analysis/zmax_profile.png", dpi=150)
print("gespeichert: analysis/zmax_profile.png")
