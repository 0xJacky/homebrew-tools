class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.3/nginx-ui-macos-64.tar.gz"
      sha256  "4ef9a378575aa6b02fbd2ff0264dc2b3e0d77868a8aad19a9c7eeb7406088710"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.3/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "52616033217f1f63fc1143ef0fb2ad631e11fc8964795787e3a4455f5ae0f76a"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.3/nginx-ui-linux-64.tar.gz"
      sha256  "aedc32c05ea6d171732cd41119cfb61177af7d0814ba54e3218cac7b5eda3c63"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v2.6.3/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "28fed561b12171bc14815542c7764d7096b3c1707affa272156b027528c67c4a"
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
