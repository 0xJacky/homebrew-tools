class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.4/nginx-ui-macos-64.tar.gz"
      sha256  "749dbd79e9c2217192411e09216860cb45ff32bc9cfdb152d05592be5da7305a"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.4/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "f0dcdc1a8e8ae78fc48ea2f5b529eeccb616c8616dad6770f0decd0eb01b8cc3"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.4/nginx-ui-linux-64.tar.gz"
      sha256  "34bc625f9710ba14fe52932f9a477c48c480cda46bb94acd57676d0c7c644d94"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.8.4/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "531c59d4fcac6a1738fee9bb28abf1865c01a961c042ab14c7550fc09e47d665"
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
