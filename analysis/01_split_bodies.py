#!/usr/bin/env python3
"""Schritt 1a: STL laden, in zusammenhaengende Koerper zerlegen, Bounding Boxes ausgeben."""
import trimesh
import numpy as np

STL_PATH = "printables/variant1/variant1_top_bracket.stl"

scene_or_mesh = trimesh.load(STL_PATH)
print(f"Typ des geladenen Objekts: {type(scene_or_mesh)}")

if isinstance(scene_or_mesh, trimesh.Scene):
    mesh = trimesh.util.concatenate(scene_or_mesh.dump())
else:
    mesh = scene_or_mesh

print(f"Gesamt-Bounding-Box (min): {mesh.bounds[0]}")
print(f"Gesamt-Bounding-Box (max): {mesh.bounds[1]}")
print(f"Gesamt-Extents (X,Y,Z):   {mesh.extents}")
print(f"Ist watertight (gesamt):   {mesh.is_watertight}")
print(f"Anzahl Dreiecke gesamt:    {len(mesh.faces)}")
print()

bodies = mesh.split(only_watertight=False)
print(f"Anzahl zusammenhaengender Koerper: {len(bodies)}")
print()

for i, body in enumerate(bodies):
    ext = body.extents
    center = body.centroid
    bmin = body.bounds[0]
    bmax = body.bounds[1]
    print(f"--- Koerper {i} ---")
    print(f"  Dreiecke:      {len(body.faces)}")
    print(f"  Watertight:    {body.is_watertight}")
    print(f"  Volumen:       {body.volume:.2f} mm^3" if body.is_watertight else "  Volumen:       n/a (nicht watertight)")
    print(f"  Bounding min:  {bmin}")
    print(f"  Bounding max:  {bmax}")
    print(f"  Extents(X,Y,Z):{ext}")
    print(f"  Schwerpunkt:   {center}")
    print()
