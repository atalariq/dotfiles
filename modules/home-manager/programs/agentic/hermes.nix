{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # Starter context for each domain the owner keeps on this machine. Seeded
  # absent-only (same rule as every other profile file): a skill Hermes grew on
  # its own, or one the owner edited, is never replaced by a rebuild.
  #
  # Content stays deliberately factual - a path plus the conventions that are
  # already written down - so the skill is a pointer, not an authority the
  # model may trust over what it sees on disk.
  domainSkills = {
    dotfiles = {
      description = "Nix flake dotfiles for four hosts at ~/.dotfiles; conventions, validation commands, owner-only operations.";
      body = ''
        # Dotfiles

        Repository: `~/.dotfiles` - a Nix flake covering NixOS (thinkpad-x13),
        nix-darwin (macmini-lab) only; the Linux hosts are NixOS.

        ## Layout

        - `hosts/` - per-host identity, feature selection, displays
        - `modules/home-manager/` - shared defaults and application config
        - `modules/nixos/` - system integration
        - `Justfile` - the command surface; read it before running anything

        ## Validate

        ```sh
        just --list            # what exists
        just fmt               # nixfmt the sources
        just lint              # statix + deadnix, does not rewrite
        just check             # flake checks, current platform
        just build-thinkpad-x13
        ```

        ## Owner-only (never run these; return the command instead)

        Activation, `pkexec`, `sudo`, push, and shared-queue commits. See
        AGENTS.md: privileged operations need owner review after build.

        ## Caution

        A Git flake ignores untracked files - a new source file stays
        invisible until it is added to Git, so a build can succeed while
        silently skipping it.
      '';
    };
    kuliah = {
      description = "Coursework under ~/Kuliah; keep drafts reversible and never present generated work as final.";
      body = ''
        # Kuliah

        Directory: `~/Kuliah`.

        ## Handling

        - Treat everything here as coursework in progress. Nothing is final
          until the owner says so.
        - Prefer adding a draft over rewriting an existing file: coursework is
          usually handed in, and later corrections need a history.
        - When generating answers or reports, show the reasoning. The owner has
          to be able to defend the work without the agent present.
        - Spelling is checked as Indonesian + English (`spelllang=en_us,id`).

        ## Not here

        Code repositories live under `~/Repos`, work under `~/Works`.
      '';
    };
    works = {
      description = "Paid work under ~/Works; scoped changes only, reported back as files-changed-and-why.";
      body = ''
        # Works

        Directory: `~/Works`.

        ## Handling

        - Scope discipline: make the change that was asked for. Wide refactors,
          dependency bumps and formatting sweeps are not the ask unless they
          are.
        - Assume these files are read by people outside this machine, so every
          change should explain itself in the diff.
        - Report back as a short list of files changed and why, with the exact
          command output for any verification that ran.
        - Credentials and client material stay outside the repository and
          outside anything written to the Nix store.
      '';
    };
  };

  skillNames = builtins.attrNames domainSkills;

  # Documented exception to the "no permission lists in the seed" rule.
  # approvals.deny is an unconditional block in Hermes 0.22.4: the globs are
  # checked before --yolo / /yolo / approvals.mode are consulted, so protected
  # operations stay protected even in a yolo session. fnmatch globs,
  # case-insensitive, matched against the whole command text; a denied command
  # returns BLOCKED to the agent and runs nothing.
  #
  # Upstream default is an empty list. Only operations that AGENTS.md already
  # reserves for the owner belong here - never routine commands, because a
  # block cannot be approved from inside the session.
  approvalsDeny = ''

    # Documented exception: owner-only operations block unconditionally.
    approvals:
      deny:
        - "nixos-rebuild switch*"
        - "nixos-rebuild boot*"
        - "nh os switch*"
        - "nh os boot*"
        - "nh home switch*"
        - "nix run .#home-manager -- switch*"
        - "darwin-rebuild*"
        - "nh darwin switch*"
        - "pkexec*"
        - "nix-collect-garbage -d*"
        - "nix-collect-garbage --delete-older*"
        - "nh clean*"
        - "git push*"
        - "dd *"
        - "rm -rf*"
  '';
in
{
  options.dotfiles.programs.agentic.hermes.enable =
    lib.mkEnableOption "Hermes CLI with direct provider configuration";
  config = lib.mkIf config.dotfiles.programs.agentic.hermes.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent ];
    # Hermes rewrites its native profile. Keep it writable and seed/merge only
    # selected preferences; authentication, sessions and local toolsets survive.
    xdg.configFile = {
      "dotfiles/templates/hermes.yaml".text =
        builtins.readFile ./config/hermes/config.yaml
        + lib.optionalString config.dotfiles.programs.agentic.core.enable ''
          mcp_servers:
            codegraph:
              command: codegraph
              args: [serve, --mcp]
        ''
        + approvalsDeny;
    }
    # Skill seeds live beside the config seed; the activation below publishes
    # each one into ~/.hermes/skills/ only when that directory is absent.
    // lib.mapAttrs' (name: skill: {
      name = "dotfiles/templates/hermes-skills/${name}/SKILL.md";
      value.text = ''
        ---
        name: ${name}
        description: "${skill.description}"
        ---

        ${skill.body}
      '';
    }) domainSkills;

    home.activation.seedHermesSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.concatMapStringsSep "\n" (name: ''
        skills_root=${lib.escapeShellArg "${config.home.homeDirectory}/.hermes/skills"}
        skill_dir="$skills_root/${name}"
        if [[ ! -e "$skill_dir" && ! -L "$skill_dir" ]]; then
          run mkdir -p "$skills_root"
          (
            umask 077
            seed_dir=$(run ${pkgs.coreutils}/bin/mktemp -d "$skills_root/.seed.XXXXXX")
            trap 'run ${pkgs.coreutils}/bin/rmdir "$seed_dir" 2>/dev/null || true' EXIT
            run ${pkgs.coreutils}/bin/cp --no-preserve=mode \
              ${
                lib.escapeShellArg (
                  toString config.xdg.configFile."dotfiles/templates/hermes-skills/${name}/SKILL.md".source
                )
              } \
              "$seed_dir/SKILL.md"
            # Publish atomically; never replace a directory that appeared
            # concurrently (an owned skill wins, exactly like absent-only).
            run ${pkgs.coreutils}/bin/mv -T -- "$seed_dir" "$skill_dir" 2>/dev/null || true
          )
        fi
      '') skillNames
    );
  };
}
