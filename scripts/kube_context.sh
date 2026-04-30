#!/usr/bin/env bash
kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
file="${kubeconfig%%:*}"
[[ -r "$file" ]] || exit 0
ctx=$(awk '/^current-context:/ {print $2; exit}' "$file" 2>/dev/null)
[[ -n "$ctx" ]] && printf '⎈ %.8s' "$ctx"
