{
  flake.modules.homeManager.starship =
    { ... }:
    {
      programs.starship = {
        enable = true;
        settings = {
          "$schema" = "https://starship.rs/config-schema.json";

          # ── Performance ──────────────────────────────────────────────
          scan_timeout = 10;
          command_timeout = 500;
          add_newline = true;
          follow_symlinks = false;

          # ── Layout ───────────────────────────────────────────────────
          format = ''
            $directory$git_branch$git_status$fill$cmd_duration$jobs$nix_shell$line_break$character
          '';

          # ── Fill ─────────────────────────────────────────────────────
          fill.symbol = " ";
          fill.style = "dimmed";

          # ── Directory ────────────────────────────────────────────────
          directory = {
            truncation_length = 3;
            truncation_symbol = "…/";
            truncate_to_repo = true;
            style = "bold blue";
            format = "[ $path]($style)[$read_only]($read_only_style) ";
          };

          # ── Git ──────────────────────────────────────────────────────
          git_branch = {
            symbol = "";
            style = "bold purple";
            truncation_length = 20;
            truncation_symbol = "…";
            format = "[on $symbol$branch]($style) ";
          };

          git_status = {
            style = "bold purple";
            format = "([$all_status$ahead_behind]($style) )";
            ignore_submodules = true;
            ahead = "[⇡ $count](green) ";
            behind = "[⇣ $count](red) ";
            diverged = "[⇡ $ahead ⇣ $behind](red) ";
            untracked = "[? $count](yellow) ";
            stashed = "[* $count](cyan) ";
            staged = "[+ $count](green) ";
            modified = "[! $count](yellow) ";
            deleted = "[✘ $count](red) ";
          };

          # ── Character ────────────────────────────────────────────────
          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[❯](bold red)";
            vimcmd_symbol = "[❮](bold purple)";
          };

          # ── Enabled Modules ──────────────────────────────────────────
          cmd_duration = {
            min_time = 2000;
            format = "[ took $duration]($style)";
            style = "bold yellow";
          };

          jobs = {
            format = "[ $number background]($style)";
            style = "bold cyan";
          };

          nix_shell = {
            format = "[ $state( \\($name\\))]($style)";
            style = "bold blue";
            pure_msg = "[pure](bold green)";
            impure_msg = "[impure](bold red)";
          };

          status = {
            format = "[$symbol$common_meaning$signal_name$maybe_int]($style) ";
            symbol = "✘ ";
            success_symbol = "✔ ";
            error_symbol = "✘ ";
            style = "bold red";
            map_symbol = true;
            disabled = false;
          };

          time = {
            disabled = false;
            format = "[ $time]($style)";
            style = "dimmed";
            time_format = "%R";
          };

          # ── Disabled (default-enabled, not needed) ───────────────────
          package.disabled = true;
          nodejs.disabled = true;
          python.disabled = true;
          rust.disabled = true;
          golang.disabled = true;
          java.disabled = true;
          docker_context.disabled = true;
          hostname.disabled = true;
          username.disabled = true;
        };
      };
    };
}
