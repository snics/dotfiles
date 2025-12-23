# CRD Wizard Integration

> Integrate crd-wizard as a kubectl plugin and k9s plugin with multiple modes (TUI, TUI+AI, Web UI) for visualizing Kubernetes CRDs and CRs

## 🎯 Goal

Add CR(D) Wizard to the dotfiles setup to provide an intuitive interface for visualizing and exploring Kubernetes Custom Resource Definitions (CRDs) and Custom Resources (CRs). This tool will help quickly understand the state of custom controllers and managed resources through multiple interfaces:
- TUI mode for lightweight terminal access
- TUI with AI support via OpenRouter for intelligent documentation
- Web UI mode for graphical interface

## 📋 Requirements

- Install crd-wizard via kubectl krew plugin manager
- Configure as k9s plugin with three access modes:
  1. Normal TUI mode without AI
  2. TUI mode with AI support via OpenRouter
  3. Web UI mode (opens in browser)
- Set up AI integration with OpenRouter API
- Document all keyboard shortcuts and usage patterns
- Ensure seamless integration with existing k9s workflow

## 💡 Implementation Ideas

### Approach

1. Add crd-wizard installation via krew (already have krew in Brewfile)
2. Create k9s plugin configuration file with three separate commands
3. Set up environment variables for OpenRouter API key in ~/.secrets
4. Add documentation to README.md with usage examples
5. Test all three modes to ensure proper functionality

### Files to Modify

- `brew/Brewfile` - Add crd-wizard tap if needed (check if krew installation is sufficient)
- `k9s/plugins.yaml` - Create k9s plugin configuration with three modes
- `.secrets.example` - Add OPENROUTER_API_KEY placeholder
- `README.md` - Add crd-wizard to Kubernetes & DevOps Tools section
- `zsh/settings/aliases.zsh` or `zsh/settings/functions.zsh` - Add convenience aliases (optional)

### K9s Plugin Configuration

Create `~/.config/k9s/plugins.yaml` with:

```yaml
plugins:
  # CRD Wizard - TUI mode without AI
  crd-wizard-tui:
    shortCut: Shift-W
    description: CRD Wizard (TUI)
    dangerous: false
    scopes:
      - crds
    command: bash
    background: false
    confirm: false
    args:
      - -c
      - "crd-wizard tui --kind $COL-KIND"
  
  # CRD Wizard - TUI mode with AI via OpenRouter
  crd-wizard-ai:
    shortCut: Shift-A
    description: CRD Wizard (TUI + AI)
    dangerous: false
    scopes:
      - crds
    command: bash
    background: false
    confirm: false
    args:
      - -c
      - |
        if [ -z "$OPENROUTER_API_KEY" ]; then
          echo "Error: OPENROUTER_API_KEY not set in ~/.secrets"
          read -p "Press enter to continue..."
        else
          crd-wizard tui --enable-ai --ai-provider openrouter --openrouter-api-key "$OPENROUTER_API_KEY" --kind $COL-KIND
        fi
  
  # CRD Wizard - Web UI mode
  crd-wizard-web:
    shortCut: Shift-B
    description: CRD Wizard (Web UI)
    dangerous: false
    scopes:
      - crds
    command: bash
    background: true
    confirm: false
    args:
      - -c
      - |
        crd-wizard web &
        sleep 2
        open http://localhost:8080
```

### Steps

1. ✅ Install crd-wizard via krew:
   ```bash
   kubectl krew install crd-wizard
   ```

2. ✅ Create k9s plugin configuration:
   - Create directory: `mkdir -p ~/.config/k9s`
   - Symlink from dotfiles: `ln -sf ~/.dotfiles/k9s/plugins.yaml ~/.config/k9s/plugins.yaml`

3. ✅ Update .secrets.example with OpenRouter API key:
   ```bash
   # OpenRouter API Key for AI-powered tools (crd-wizard, etc.)
   export OPENROUTER_API_KEY="your_openrouter_api_key_here"
   ```

4. ✅ Update README.md:
   - Add to Kubernetes & DevOps Tools section
   - Document the three k9s plugin modes
   - Add usage examples

5. ✅ Test all three modes:
   - TUI without AI (Shift-W in k9s)
   - TUI with AI (Shift-A in k9s)
   - Web UI (Shift-B in k9s)

## 📦 Dependencies

- [kubectl](https://kubernetes.io/docs/reference/kubectl/) - Already installed
- [krew](https://krew.sigs.k8s.io/) - Already installed (line 88 in Brewfile)
- [k9s](https://k9scli.io/) - Already installed (line 83 in Brewfile)
- [crd-wizard](https://github.com/pehlicd/crd-wizard) - To be installed via krew
- OpenRouter API account and key - User needs to obtain

### OpenRouter Setup

1. Sign up at https://openrouter.ai/
2. Get API key from dashboard
3. Add to ~/.secrets file:
   ```bash
   export OPENROUTER_API_KEY="sk-or-v1-..."
   ```

## 🔗 Related

- GitHub Repository: https://github.com/pehlicd/crd-wizard
- K9s Plugins Documentation: https://k9scli.io/topics/plugins/
- OpenRouter Documentation: https://openrouter.ai/docs
- Existing k9s config: `~/.config/k9s/`

## 📝 Notes

### CRD Wizard Features

- **Web UI & TUI**: Dual interface options for different workflows
- **AI Integration**: Supports Ollama (default), Google Gemini, and can be configured for OpenRouter
- **Multi-Cluster Support**: Auto-discovers and switches between kubeconfig contexts
- **Real-time Visualization**: CRDs and CRs across the cluster

### AI Provider Options

While the original supports Ollama and Gemini, we need to verify OpenRouter compatibility:
- Check if crd-wizard supports custom OpenAI-compatible endpoints
- OpenRouter provides OpenAI-compatible API
- May need to use `--ai-provider` flag with custom endpoint configuration
- Alternative: Use OpenRouter with OpenAI-compatible mode

### K9s Plugin Shortcuts

- **Shift-W**: TUI mode (quick access, no AI overhead)
- **Shift-A**: TUI with AI (intelligent documentation and explanations)
- **Shift-B**: Web UI in browser (graphical interface)

### Keyboard Shortcuts in CRD Wizard

- `a` - Show AI analysis of selected CRD (in TUI with AI enabled)
- `c` - Switch between Kubernetes clusters
- Standard k9s navigation keys

## ✅ Done Criteria

- [x] crd-wizard installed via krew
- [x] K9s plugin configuration created with three modes
- [x] OpenRouter API key setup documented in .secrets.example
- [x] README.md updated with crd-wizard information
- [x] All three modes tested successfully
- [x] Documentation includes keyboard shortcuts and usage
- [x] Committed to repository with proper commit message
- [x] Pushed to remote repository

---

**Created:** 2024-12-23  
**Status:** Planning  
**Priority:** Medium

