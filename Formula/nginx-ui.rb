class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.1/nginx-ui-macos-64.tar.gz"
      sha256  "5871d6cf1811960af40d21fc776de568af7dfabdd9571ff6257af945477bbdec"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.1/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "96b4e5cc7d11b40d34004c35b94083bc45c5f217db816c35ab377ad0b34e1dde"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.1/nginx-ui-linux-64.tar.gz"
      sha256  "8caa38db01a1b97b742c07015d0e19269c2cd13fdcd08aa9e948a5435d35fb08"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.9.1/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "efe481a5842c0f6583fb1ef7229b6d9eb0a5b03d17fdcd3612287ff0c1e1061f"
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
