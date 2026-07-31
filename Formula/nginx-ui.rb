class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.6/nginx-ui-macos-64.tar.gz"
      sha256  "1d53355649e19a40d973f71c7e25aa3d66666d159b0fe090a90e402bc654af0e"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.6/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "3ba8299f39540640c03faabe6cba3a5b7674b21230ca34cea4629b4cf4579d0f"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.6/nginx-ui-linux-64.tar.gz"
      sha256  "5cf71740fa31e99a5a82f0152240da4de30b3cbbaed9d73abf17263348053529"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.5.6/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "20e140f0a7162a86f94a61ea2834ac3118a4d3ed1f6ba5be46ee11efb830556f"
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
