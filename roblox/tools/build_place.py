"""
Packs roblox/src into EvolveYourWorld.rbxlx - a Roblox place file you can open in Roblox Studio
by double-clicking it. Same layout as default.project.json (Rojo):
  src/shared -> ReplicatedStorage.Shared
  src/server -> ServerScriptService.Server
  src/client -> StarterPlayer.StarterPlayerScripts.Client
  *.server.luau = Script, *.client.luau = LocalScript, *.luau = ModuleScript,
  a folder with init.luau = ModuleScript whose children are the other files.
Run:  python3 roblox/tools/build_place.py
"""
import os
from xml.sax.saxutils import escape

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SRC = os.path.join(ROOT, "src")
OUT = os.path.join(ROOT, "EvolveYourWorld.rbxlx")

ref = [0]


def new_ref():
    ref[0] += 1
    return f"RBX{ref[0]:08X}"


def cdata(text):
    return "<![CDATA[" + text.replace("]]>", "]]]]><![CDATA[>") + "]]>"


def item(cls, name, source=None, children=""):
    props = f'<string name="Name">{escape(name)}</string>'
    if source is not None:
        props += f'<ProtectedString name="Source">{cdata(source)}</ProtectedString>'
    return f'<Item class="{cls}" referent="{new_ref()}"><Properties>{props}</Properties>{children}</Item>\n'


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def file_item(path):
    base = os.path.basename(path)
    if base.endswith(".server.luau"):
        return item("Script", base[: -len(".server.luau")], read(path))
    if base.endswith(".client.luau"):
        return item("LocalScript", base[: -len(".client.luau")], read(path))
    if base.endswith(".luau"):
        return item("ModuleScript", base[: -len(".luau")], read(path))
    return ""


def dir_children(path):
    out = ""
    for name in sorted(os.listdir(path)):
        full = os.path.join(path, name)
        if name == "init.luau":
            continue
        out += dir_item(full) if os.path.isdir(full) else file_item(full)
    return out


def dir_item(path, name=None):
    name = name or os.path.basename(path)
    init = os.path.join(path, "init.luau")
    if os.path.exists(init):
        return item("ModuleScript", name, read(init), dir_children(path))
    return item("Folder", name, None, dir_children(path))


body = (
    item("Workspace", "Workspace")
    + item("ReplicatedStorage", "ReplicatedStorage", None, dir_item(os.path.join(SRC, "shared"), "Shared"))
    + item("ServerScriptService", "ServerScriptService", None, dir_item(os.path.join(SRC, "server"), "Server"))
    + item("StarterPlayer", "StarterPlayer", None,
           item("StarterPlayerScripts", "StarterPlayerScripts", None, dir_item(os.path.join(SRC, "client"), "Client")))
)
xml = ('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
       'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
       'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n'
       + body + "</roblox>\n")
with open(OUT, "w", encoding="utf-8") as f:
    f.write(xml)
print("wrote", OUT, len(xml), "bytes")
