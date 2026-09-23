#!/usr/bin/env python3
"""Schritt 1b: Orthografische 2D-Projektionen (Draufsicht/Seitenansicht/Vorderansicht)
jedes Koerpers rendern, um die Geometrie visuell zu pruefen."""
import trimesh
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from mpl_toolkits.mplot3d import Axes3D

STL_PATH = "printables/variant1/variant1_top_bracket.stl"
OUT_DIR = "analysis"

mesh = trimesh.load(STL_PATH)
bodies = mesh.split(only_watertight=False)
print(f"{len(bodies)} Koerper gefunden")

AXES = {"XY (Draufsicht, Blick -Z)": (0, 1), "XZ (Vorderansicht, Blick -Y)": (0, 2), "YZ (Seitenansicht, Blick -X)": (1, 2)}
colors = ["tab:blue", "tab:orange", "tab:green", "tab:red"]

# Einzelbilder je Koerper
for i, body in enumerate(bodies):
    fig, axs = plt.subplots(1, 3, figsize=(18, 6))
    for ax, (title, (a, b)) in zip(axs, AXES.items()):
        tris = body.triangles[:, :, [a, b]]
        pc = PolyCollection(tris, facecolor="steelblue", edgecolor="black", linewidths=0.1, alpha=0.7)
        ax.add_collection(pc)
        ax.set_title(f"Koerper {i} - {title}")
        ax.set_xlabel("XYZ"[a])
        ax.set_ylabel("XYZ"[b])
        allpts = tris.reshape(-1, 2)
        pad = 5
        ax.set_xlim(allpts[:, 0].min() - pad, allpts[:, 0].max() + pad)
        ax.set_ylim(allpts[:, 1].min() - pad, allpts[:, 1].max() + pad)
        ax.set_aspect("equal")
        ax.grid(True, linewidth=0.3)
    plt.tight_layout()
    outpath = f"{OUT_DIR}/body_{i}_views.png"
    plt.savefig(outpath, dpi=150)
    plt.close()
    print(f"gespeichert: {outpath}")

# Gesamtbild: alle Koerper farbig ueberlagert (Draufsicht XY) mit Positions-Kontext
fig, ax = plt.subplots(figsize=(14, 10))
for i, body in enumerate(bodies):
    tris = body.triangles[:, :, [0, 1]]
    pc = PolyCollection(tris, facecolor=colors[i % len(colors)], edgecolor="none", alpha=0.6, label=f"Koerper {i}")
    ax.add_collection(pc)
ax.set_title("Alle Koerper ueberlagert - Draufsicht XY (Gesamtkontext)")
ax.set_xlabel("X [mm]")
ax.set_ylabel("Y [mm]")
allb = mesh.bounds
ax.set_xlim(allb[0][0] - 10, allb[1][0] + 10)
ax.set_ylim(allb[0][1] - 10, allb[1][1] + 10)
ax.set_aspect("equal")
ax.grid(True, linewidth=0.3)
ax.legend()
plt.tight_layout()
plt.savefig(f"{OUT_DIR}/all_bodies_top_view.png", dpi=150)
plt.close()
print(f"gespeichert: {OUT_DIR}/all_bodies_top_view.png")

# Gesamtbild XZ (Front)
fig, ax = plt.subplots(figsize=(14, 8))
for i, body in enumerate(bodies):
    tris = body.triangles[:, :, [0, 2]]
    pc = PolyCollection(tris, facecolor=colors[i % len(colors)], edgecolor="none", alpha=0.6, label=f"Koerper {i}")
    ax.add_collection(pc)
ax.set_title("Alle Koerper ueberlagert - Vorderansicht XZ (Gesamtkontext)")
ax.set_xlabel("X [mm]")
ax.set_ylabel("Z [mm]")
ax.set_xlim(allb[0][0] - 10, allb[1][0] + 10)
ax.set_ylim(allb[0][2] - 10, allb[1][2] + 10)
ax.set_aspect("equal")
ax.grid(True, linewidth=0.3)
ax.legend()
plt.tight_layout()
plt.savefig(f"{OUT_DIR}/all_bodies_front_view.png", dpi=150)
plt.close()
print(f"gespeichert: {OUT_DIR}/all_bodies_front_view.png")

# 3D-Isometrie aller Koerper zusammen
fig = plt.figure(figsize=(12, 10))
ax = fig.add_subplot(111, projection="3d")
for i, body in enumerate(bodies):
    pc = Poly3DCollection(body.triangles, facecolor=colors[i % len(colors)], edgecolor="none", alpha=0.8)
    ax.add_collection3d(pc)
ax.set_xlim(allb[0][0], allb[1][0])
ax.set_ylim(allb[0][1], allb[1][1])
ax.set_zlim(allb[0][2], allb[1][2])
ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_zlabel("Z")
ax.set_title("3D Isometrie aller Koerper")
ax.view_init(elev=25, azim=-60)
try:
    ax.set_box_aspect((allb[1][0]-allb[0][0], allb[1][1]-allb[0][1], allb[1][2]-allb[0][2]))
except Exception as e:
    print("box_aspect nicht gesetzt:", e)
plt.tight_layout()
plt.savefig(f"{OUT_DIR}/iso_3d.png", dpi=150)
plt.close()
print(f"gespeichert: {OUT_DIR}/iso_3d.png")
