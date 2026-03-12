class Featherci < Formula
  desc "Lightweight self-hosted CI/CD system"
  homepage "https://github.com/featherci/featherci"
  version "0.5.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-darwin-arm64.tar.gz"
      sha256 "e5c3af4872b51b1a9756e17a412ba63c3fdd8faa4cb5794a941033a5021e8fab"
    else
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-darwin-amd64.tar.gz"
      sha256 "929acb408b3cffb5490cc30399f62a4c896ddae7cae2bd2fce225459b1e2e559"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-linux-arm64.tar.gz"
      sha256 "1ced3017559766812ffae2666ad42d295746e50d119c18584034796fadd9912e"
    else
      url "https://github.com/featherci/featherci/releases/download/v#{version}/featherci-linux-amd64.tar.gz"
      sha256 "6558305d9d2ac41e27c96d0db9b139458f790bba46cafd8f90d0167fbeb1e028"
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
