class Featherci < Formula
  desc "Lightweight self-hosted CI/CD system"
  homepage "https://github.com/featherci/featherci"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-darwin-arm64.tar.gz"
      sha256 "cb077e5dcbe9515115bba97a7454593f8a5699879d3fb1a66f1d3cdf48344e71"
    else
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-darwin-amd64.tar.gz"
      sha256 "fc6150a1e052a17dbb95486945fdcdf15d5e787ac7c8ea828ef93e053adb3a24"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-linux-arm64.tar.gz"
      sha256 "3b20daf5d4977eec83f21565cd19c612337b7cbee2fdd5daa4b3055641bbf9fe"
    else
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-linux-amd64.tar.gz"
      sha256 "5e27668f4644fd779799df9bb42591035a8b12235a873ebac6a14a958a5f85e4"
    end
  end

  depends_on "docker" => :optional

  def install
    bin.install "featherci"
    (share/"featherci").install "config.yaml.example"
  end

  def post_install
    (var/"featherci").mkpath
    (var/"log/featherci").mkpath
  end

  def caveats
    <<~EOS
      To start FeatherCI, first generate an encryption key:
        featherci --generate-key

      Then create a config file at #{etc}/featherci/config.yaml:
        mkdir -p #{etc}/featherci
        cp #{opt_share}/featherci/config.yaml.example #{etc}/featherci/config.yaml

      Edit the config file with your settings (secret key, OAuth, admins).

      Start the service:
        brew services start featherci

      Or run manually:
        featherci --config #{etc}/featherci/config.yaml
    EOS
  end

  service do
    run [opt_bin/"featherci", "--config", etc/"featherci/config.yaml"]
    keep_alive true
    working_dir var/"featherci"
    log_path var/"log/featherci/featherci.log"
    error_log_path var/"log/featherci/featherci.error.log"
  end

  test do
    assert_match "FeatherCI", shell_output("#{bin}/featherci --version")
  end
end
