class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.10/nginx-ui-macos-64.tar.gz"
      sha256  "ee6e4becdb69f46e1d67dbbb0a3ddbd7d9c2acb6316db654af5ca92d204d5278"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.10/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "ce73bb328646b7c017a78537f4c05fc1179de70cd5ccfa22329b05091e851739"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.10/nginx-ui-linux-64.tar.gz"
      sha256  "f82aa9e1765d9abf8c9b7c95965f26a9ab96677787933087dc50c985d7fbcae9"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.10/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "89e703c282fed169398240511b6137252113fb4ef28e598df4cdefe7a0c3ce3f"
    end
  end

  def install
    bin.install "nginx-ui"

    # Create configuration directory
    (etc/"nginx-ui").mkpath

    # Create default configuration file if it doesn't exist
    config_file = etc/"nginx-ui/app.ini"
    unless config_file.exist?
      config_file.write <<~EOS
        [app]
        PageSize = 10

        [server]
        Host = 0.0.0.0
        Port = 9000
        RunMode = release

        [cert]
        HTTPChallengePort = 9180

        [terminal]
        StartCmd = login
      EOS
    end

    # Create data directory
    (var/"nginx-ui").mkpath
  end

  def post_install
    # Ensure correct permissions
    (var/"nginx-ui").chmod 0755
  end

  service do
    run [opt_bin/"nginx-ui", "serve", "--config", etc/"nginx-ui/app.ini"]
    keep_alive true
    working_dir var/"nginx-ui"
    log_path var/"log/nginx-ui.log"
    error_log_path var/"log/nginx-ui.err.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nginx-ui --version")
  end
end
