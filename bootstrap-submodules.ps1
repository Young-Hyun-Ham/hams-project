<# 
  bootstrap-submodules.ps1
  - Run in the SUPER project root (e.g. F:\project)
  - This will REMOVE existing folders under submodule paths and re-add them as git submodules.
#>

$ErrorActionPreference = "Stop"

# ---- Safety: must be at git repo root
if (-not (Test-Path ".git")) {
  throw "❌ .git not found. Run this script at the super-project root (where .git exists)."
}

# ---- Define submodules (path + url) from your list
$submodules = @(
  # ========================================================
  # 01.workspace / nextjs
  # ========================================================
  @{ Path = "01.workspace/nextjs/hams-BAP"; Url = "https://github.com/Young-Hyun-Ham/hams-BAP.git" },

  # ========================================================
  # 01.workspace / python
  # ========================================================
  @{ Path = "01.workspace/python/hams-chat-socket";       Url = "https://github.com/Young-Hyun-Ham/hams-chat-socket.git" },
  @{ Path = "01.workspace/python/hams-langGraph-backend"; Url = "https://github.com/Young-Hyun-Ham/hams-langGraph-backend.git" },
  @{ Path = "01.workspace/python/hams-stock-worker";      Url = "https://github.com/Young-Hyun-Ham/hams-stock-worker.git" },

  # ========================================================
  # 01.workspace / svelte-kit
  # ========================================================
  @{ Path = "01.workspace/svelte-kit/hams-chat";           Url = "https://github.com/Young-Hyun-Ham/hams-chat.git" },
  @{ Path = "01.workspace/svelte-kit/hams-health";         Url = "https://github.com/Young-Hyun-Ham/hams-health.git" },
  @{ Path = "01.workspace/svelte-kit/hams-langGraph-front";Url = "https://github.com/Young-Hyun-Ham/hams-langGraph-front.git" },
  @{ Path = "01.workspace/svelte-kit/hams-stock";          Url = "https://github.com/Young-Hyun-Ham/hams-stock.git" },
  @{ Path = "01.workspace/svelte-kit/hams-todos";          Url = "https://github.com/Young-Hyun-Ham/hams-todos.git" },
  @{ Path = "01.workspace/svelte-kit/hams-wedding";        Url = "https://github.com/Young-Hyun-Ham/hams-wedding.git" },

  # ========================================================
  # 99.reference
  # ========================================================
  @{ Path = "99.reference/react-flow";       Url = "https://github.com/cutiefunny/react-flow.git" },
  @{ Path = "99.reference/open-webui";       Url = "https://github.com/open-webui/open-webui.git" },
  @{ Path = "99.reference/clt-chatbot";      Url = "https://github.com/cutiefunny/clt-chatbot.git" },
  @{ Path = "99.reference/workflowbuilder";  Url = "https://github.com/synergycodes/workflowbuilder.git" },
  @{ Path = "99.reference/continue";         Url = "https://github.com/continuedev/continue.git" },
  @{ Path = "99.reference/msa-project";      Url = "https://github.com/ysw1206/msa-project.git" },
  @{ Path = "99.reference/dify";             Url = "https://github.com/langgenius/dify.git" },
  @{ Path = "99.reference/mcp-server";       Url = "https://github.com/modelcontextprotocol/servers.git" },
  @{ Path = "99.reference/n8n";              Url = "https://github.com/n8n-io/n8n.git" },
  @{ Path = "99.reference/yt-assets";        Url = "https://github.com/citizendev9c/yt-assets.git" }
)

Write-Host "=== 1) Pre-check: show current git status ==="
git status

Write-Host "`n=== 2) Remove existing folders at submodule paths (if any) ==="
foreach ($m in $submodules) {
  $p = $m.Path.Replace("/", "\")
  if (Test-Path $p) {
    Write-Host "🧹 Removing: $p"
    Remove-Item -Recurse -Force $p
  } else {
    Write-Host "✅ Not found (skip remove): $p"
  }
}

Write-Host "`n=== 3) Clean old submodule metadata if it exists (safe) ==="
# If .gitmodules exists from a previous attempt, we keep it;
# but if it contains wrong entries, it's usually safer to regenerate.
# We'll delete it and re-add cleanly.
if (Test-Path ".gitmodules") {
  Write-Host "🧼 Removing existing .gitmodules to regenerate cleanly"
  Remove-Item -Force ".gitmodules"
}

# Also remove possible leftover git config entries for submodules (best effort)
foreach ($m in $submodules) {
  $name = ($m.Path -replace "[/\\]", ".")  # make a stable key-ish
  # best-effort cleanup; ignore errors
  try { git config --remove-section "submodule.$name" | Out-Null } catch {}
}

Write-Host "`n=== 4) Add submodules ==="
foreach ($m in $submodules) {
  Write-Host "➕ Adding submodule: $($m.Url) -> $($m.Path)"
  git submodule add $m.Url $m.Path
}

Write-Host "`n=== 5) Initialize & update submodules (recursive) ==="
git submodule update --init --recursive

Write-Host "`n=== 6) Verify: submodule status ==="
git submodule status

Write-Host "`n=== 7) Stage & commit (super project) ==="
git add .gitmodules
git add 01.workspace 99.reference

# Show what will be committed
git status

# Commit (change message as you want)
git commit -m "Initialize workspace with git submodules"

Write-Host "`n✅ Done. Next: push your super project repo."
Write-Host "   git push -u origin main"
