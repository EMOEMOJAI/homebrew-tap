class Sidecarkeeper < Formula
  desc "Auto-reconnect Apple Sidecar so an iPad stays a Mac's second display"
  homepage "https://emoemojai.github.io/SidecarKeeper/"
  url "https://github.com/EMOEMOJAI/SidecarKeeper/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "13ec6d2fd5b1baee0ba8f513b303df1d9d70975262cf4eec1ce37ba747ad0254"
  license "MIT"
  head "https://github.com/EMOEMOJAI/SidecarKeeper.git", branch: "main"

  depends_on macos: :sonoma

  uses_from_macos "swift" => :build

  # The CLI that performs the actual connect, at the same commit SidecarKeeper pins.
  resource "sidecarlauncher" do
    url "https://github.com/Ocasio-J/SidecarLauncher/archive/4b7a9df950a64239b2a073428f0390fc16934a9e.tar.gz"
    sha256 "c82a38dfadcf0e4cd1697fcd682702e67d687056e75c5a42c78d3e328ae714e6"
  end

  def install
    system "swiftc", "-O", "-framework", "AppKit", "Sources/SidecarKeeper/main.swift",
           "-o", "sidecar-keeper"
    bin.install "sidecar-keeper"

    resource("sidecarlauncher").stage do
      # The source directory is itself called SidecarLauncher, so build under another name.
      system "swiftc", "-O", "SidecarLauncher/main.swift", "-o", "launcher"
      libexec.install "launcher" => "SidecarLauncher"
      (libexec/"LICENSE-SidecarLauncher").write File.read("LICENSE")
    end
  end

  service do
    run [opt_bin/"sidecar-keeper", "--launcher", opt_libexec/"SidecarLauncher"]
    keep_alive true
    process_type :background
    log_path var/"log/sidecarkeeper.log"
    error_log_path var/"log/sidecarkeeper.log"
  end

  def caveats
    <<~EOS
      Unlock your iPad, then start SidecarKeeper and have it run at every login:
        brew services start sidecarkeeper

      It keeps the first reachable iPad connected. Its decisions are logged to
        ~/Library/Logs/sidecar-keeper.log
      and `sidecar-keeper status`, `pause` and `resume` control it.

      To choose a specific iPad or use the experimental wired-only mode, use the
      standard installer instead of the Homebrew service:
        https://github.com/EMOEMOJAI/SidecarKeeper#install
      Do not run both at once, or two watchers will compete.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/sidecar-keeper --version").strip
    assert_match "--wired", shell_output("#{bin}/sidecar-keeper --help")
    assert_match "unknown argument", shell_output("#{bin}/sidecar-keeper --bogus 2>&1", 2)
    assert_predicate libexec/"SidecarLauncher", :executable?
    # `devices` only lists; it never connects, so it is safe to run anywhere.
    assert_match "Commands:", shell_output("#{libexec}/SidecarLauncher 2>&1", 1)
  end
end
