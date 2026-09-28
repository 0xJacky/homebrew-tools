class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.7.0/nginx-ui-macos-64.tar.gz"
      sha256  "6ba15d55147e837b887a851a5c92f2f679f887ff06fae94ed27bc691ece2f7ab"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.7.0/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "58d22bacd24be7b17a1319e3109e8f91ad2720da9579df67802becda655f1a83"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.7.0/nginx-ui-linux-64.tar.gz"
      sha256  "c0e2c6967ac2d8071cc98c41dd06c694169ec049beee158821565207e63a1a39"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.7.0/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "e47df68636c0d0975b5fe944381a0ce90db6f1c21e77a7d723a5e30755667e67"
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

  post_install_steps do
    # Ensure correct permissions
    set_permissions "nginx-ui", "0755", base: :var, recursive: false
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
