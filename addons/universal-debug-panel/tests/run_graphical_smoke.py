"""Usage: python3 run_graphical_smoke.py ENGINE PROJECT [--empty|--demo]."""
import subprocess
import sys
import tempfile
from pathlib import Path

if len(sys.argv) < 3:
    raise SystemExit("Usage: run_graphical_smoke.py ENGINE PROJECT [--empty|--demo]")
engine, project = sys.argv[1:3]
flags = sys.argv[3:]
log = str(Path(tempfile.mkdtemp(prefix="udp-smoke-")) / "godot.log")
command = [engine, "--path", project, "--log-file", log,
           "res://addons/universal-debug-panel/tests/graphical_startup.tscn", "--", *flags]
try:
    result = subprocess.run(command, capture_output=True, text=True, timeout=15)
except subprocess.TimeoutExpired as error:
    print("FAIL: graphical smoke timed out", error.stdout, error.stderr)
    raise SystemExit(1)
output = result.stdout + result.stderr
print(output)
failed = (result.returncode != 0 or "GRAPHICAL STARTUP PASS" not in output
          or any(marker in output for marker in ["SCRIPT ERROR", "GRAPHICAL STARTUP FAIL", "handle_crash", "ERROR: IM_ASSERT", "Invalid call", "Parse Error"]))
print("SMOKE RESULT:", "FAIL" if failed else "PASS", "engine exit:", result.returncode, "log:", log)
raise SystemExit(1 if failed else 0)
