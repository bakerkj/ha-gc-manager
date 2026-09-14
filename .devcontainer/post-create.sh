#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${HOME}/.local/bin"

find_codex_bin() {
  local path=""

  while IFS= read -r candidate; do
    path="${candidate}"
    break
  done < <(
    find "${HOME}/.vscode-server/extensions" \
      "${HOME}/.vscode-remote/extensions" \
      "${HOME}/.vscode/extensions" \
      -path "*/bin/*/codex" -type f 2>/dev/null | sort -r
  )

  printf '%s' "${path}"
}

write_codex_launcher() {
  cat >"${HOME}/.local/bin/codex" <<'LAUNCHER'
#!/usr/bin/env bash
set -euo pipefail

for root in "${HOME}/.vscode-server/extensions" "${HOME}/.vscode-remote/extensions" "${HOME}/.vscode/extensions"; do
  if [[ -d "${root}" ]]; then
    if codex_bin="$(find "${root}" -path "*/bin/*/codex" -type f 2>/dev/null | sort -r | head -n 1)"; then
      if [[ -n "${codex_bin}" ]]; then
        exec "${codex_bin}" "$@"
      fi
    fi
  fi
done

echo "Codex CLI binary not found yet. Open the ChatGPT/Codex VS Code extension once, then run 'codex' again."
exit 1
LAUNCHER
  chmod +x "${HOME}/.local/bin/codex"
}

ensure_pre_commit() {
  if command -v pre-commit >/dev/null 2>&1; then
    echo "pre-commit already installed: $(pre-commit --version)"
  else
    echo "pre-commit not found; installing..."

    if command -v pipx >/dev/null 2>&1; then
      if pipx install pre-commit; then
        echo "Installed pre-commit with pipx"
      else
        echo "Warning: failed to install pre-commit via pipx; continuing startup."
      fi
    elif python3 -m pip install --user pre-commit; then
      echo "Installed pre-commit with pip --user"
    else
      echo "Warning: failed to install pre-commit; continuing startup."
    fi
  fi

  if command -v pre-commit >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if pre-commit install; then
      echo "Installed git pre-commit hook"
    else
      echo "Warning: failed to install git pre-commit hook; continuing startup."
    fi
  fi
}

codex_bin="$(find_codex_bin)"

if [[ -n "${codex_bin}" ]]; then
  ln -sfn "${codex_bin}" "${HOME}/.local/bin/codex"
  echo "Linked codex -> ${codex_bin}"
else
  write_codex_launcher
  echo "Installed codex launcher at ${HOME}/.local/bin/codex (will auto-link once extension binary exists)."
fi

ensure_pre_commit
