class NginxUi < Formula
  desc     "Yet another Nginx Web UI"
  homepage "https://github.com/0xJacky/nginx-ui"
  license  "AGPL-3.0"

  bottle do
    root_url "https://ghcr.io/v2/0xjacky/tools"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2dcc2c19bfd1380eca9327a004cfaa4e432deeb93138c9f60680998cee3c3e76"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "031ce432dd2c91c0e039dee92d82d1b3a58a2a73e14061d055229bee2d0a9c06"
  end

  on_macos do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.1/nginx-ui-macos-64.tar.gz"
      sha256  "7a1e4a1b2919f3cd097ab8dced933d14fedefaadf0c9a74f0dc9262134206ad3"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.1/nginx-ui-macos-arm64-v8a.tar.gz"
      sha256  "4a6aaf6c2089b121a29ed2e53bbeada81cbb01d8a421d874fb86474b0d7c3c68"
    end
  end

  on_linux do
    on_intel do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.1/nginx-ui-linux-64.tar.gz"
      sha256  "b63d41d38fa1b4a878676aec5a84ac52133eefcd5ec3ea36b2c2c42a1e977341"
    end
    on_arm do
      url     "https://github.com/0xJacky/nginx-ui/releases/download/v3.0.1/nginx-ui-linux-arm64-v8a.tar.gz"
      sha256  "a347ab5bde38e3edfd7e09c20af3c8342d09ba13e05711e13cea96989a01abb6"
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
