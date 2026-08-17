class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.9/nginx-ui-macos-64.tar.gz"
      sha256  "a7cf0807af65c6e20fd3dd2d85a4b1fef5511797d2871bebf91202f86392e44d"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.9/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "fc623c8ac66250d09e05cb8acbc613a7b3a0b2d77d5da21173ddcfc978072e3b"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.9/nginx-ui-linux-64.tar.gz"
      sha256  "987f63878cbb71b46d39ab5e82b141dc0a198326236d61c1a23a22d9449f8b0c"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.9/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "715813f0c5a1a7b37f683a0268ef5d5edecf0329f44833e6e83d75e942ea0a3d"
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
