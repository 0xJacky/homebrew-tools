class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.1/nginx-ui-macos-64.tar.gz"
      sha256  "c283e634a8681e95d3c27176f3e48360cf3fc29274af047994d6aa6097e81a8c"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.1/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "333d9ee3854cea4cce5a1e24fb923f61e1c67f4006a2b1bfecc365f09347285d"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.1/nginx-ui-linux-64.tar.gz"
      sha256  "8e54b3100ffaf33be51fae68864ea2932c5d7413ce6193ee6960b89b91eb607c"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.1/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "2b51856c6eba8a9b0dc2318bae34fe16f4e34f585df0ee017b6df42ec645e1d2"
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
