"""Runs the real Rig.luau + character builders inside Redis' Lua 5.1 and dumps every part as JSON."""
import json, re, subprocess, sys, os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "src", "shared")
HERE = os.path.dirname(os.path.abspath(__file__))
TYPE = r"(?:\{[^{}]*\}\??|\([^()]*\)\s*->\s*[\w\.]+\??|[A-Za-z_][\w\.]*\??)"

def luau_to_lua(src: str) -> str:
    src = re.sub(r"export type \w+ = \{.*?\n\}\n", "", src, flags=re.S)
    src = re.sub(r"^\s*type \w+ = .*$", "", src, flags=re.M)
    src = re.sub(r"\s*::\s*" + TYPE, "", src)
    src = re.sub(r"\)\s*:\s*(?:" + TYPE + r"|\([^()]*\))(?=\s*\n)", ")", src)
    src = re.sub(r"(\b\w+): " + TYPE, r"\1", src)
    src = re.sub(r"^(\s*)([\w\.\[\]]+) ([+\-*/])= (.+)$", r"\1\2 = \2 \3 (\4)", src, flags=re.M)
    def fix_for(m):
        expr = m.group(3)
        if expr.startswith(("pairs(", "ipairs(")):
            return m.group(0)
        return f"for {m.group(1)}, {m.group(2)} in pairs({expr}) do"
    src = re.sub(r"for (\w+), (\w+) in (.+?) do$", fix_for, src, flags=re.M)
    src = src.replace("table.clone", "tableClone")
    src = re.sub(r"require\(script\.Parent\.Parent\.Rig\)", "Rig", src)
    src = re.sub(r"require\(script\.Parent\.Config\)", "Config", src)
    return src

ids = ["GrassAndFlowers", "MagicTree", "LavaStone", "BlueCrystal", "Giraffe", "CosmicMeteor",
       "SolarioLeonario", "DrippoBloxino", "ZombinoRotolino", "FrostyFangolini", "WitchinaMagichina", "GalaxyDragon"]
only = sys.argv[1:] or ids

prelude = open(os.path.join(HERE, "prelude.lua")).read()
rig = luau_to_lua(open(f"{ROOT}/Rig.luau").read())
out = {}
for cid in only:
    body = luau_to_lua(open(f"{ROOT}/Characters/{cid}.luau").read())
    script = prelude + "\nlocal Rig = (function()\n" + rig + "\nend)()\n" + \
        "local build = (function()\n" + body + "\nend)()\n" + r'''
local model = build()
local parts, joints = {}, {}
for _, o in ipairs(ALL) do
  local P = rawget(o, "__props")
  if P.ClassName == "Motor6D" then
    local j = rawget(P.Part1, "__props")
    local par = rawget(P.Part0, "__props")
    table.insert(joints, { name = j.Name, parent = par.Name, p = { j.CFrame.p.X, j.CFrame.p.Y, j.CFrame.p.Z } })
  end
end
for _, o in ipairs(ALL) do
  local P = rawget(o, "__props")
  if P.ClassName == "WeldConstraint" then
    local part = rawget(P.Part1, "__props")
    local j = rawget(P.Part0, "__props")
    local mesh = false
    for _, ch in ipairs(rawget(P.Part1, "__children")) do
      if rawget(ch, "__props").ClassName == "SpecialMesh" then mesh = true end
    end
    local cf = part.CFrame
    local shape = part.Shape or "Block"
    if part.ClassName == "WedgePart" then shape = "Wedge" end
    if mesh then shape = "Ell" end
    table.insert(parts, {
      j = j.Name, s = shape,
      sz = { part.Size.X, part.Size.Y, part.Size.Z },
      r = cf.r, p = { cf.p.X, cf.p.Y, cf.p.Z },
      c = { part.Color.R, part.Color.G, part.Color.B },
      m = part.Material or "SmoothPlastic", t = part.Transparency or 0,
    })
  end
end
return cjson.encode({ id = model:GetAttribute("ItemId"), gait = model:GetAttribute("Gait"), hip = model:GetAttribute("Hip"), joints = joints, parts = parts })
'''
    
    res = subprocess.run(["redis-cli", "-p", "6399", "--no-raw", "EVAL", script, "0"], capture_output=True, text=True)
    txt = res.stdout.strip()
    if not txt.startswith('"'):
        print("FAIL", cid, txt[:600], res.stderr[:300])
        continue
    data = json.loads(json.loads(txt))
    out[cid] = data
    print("ok", cid, len(data["parts"]), "parts", len(data["joints"]), "joints")

json.dump(out, open(os.path.join(HERE, "chars.json"), "w"))
