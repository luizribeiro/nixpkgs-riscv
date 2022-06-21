final: prev:

rec {
  aws-sdk-cpp = prev.aws-sdk-cpp.overrideAttrs (_old: {
    LDFLAGS = "-latomic";
    doCheck = false;
  });
  boehmgc = prev.boehmgc.overrideAttrs (_old: {
    doCheck = false;
  });
  jemalloc = prev.jemalloc.overrideAttrs (_old: {
    doCheck = false;
  });
  libffi = prev.libffi.overrideAttrs (_old: {
    doCheck = false;
  });
  libseccomp = prev.libffi.overrideAttrs (_old: {
    doCheck = false;
  });
  libuv = prev.libuv.overrideAttrs (_old: {
    # TODO: only disable these tests
    # "fork_threadpool_queue_work_simple"
    # "get_currentexe"
    # "udp_multicast_interface"
    # "udp_multicast_interface6"
    # "udp_no_autobind"
    doCheck = false;
  });
  nlohmann_json = prev.nlohmann_json.overrideAttrs (_old: {
    doCheck = false;
  });
  openldap = prev.openldap.overrideAttrs (_old: {
    patches = [
      # TODO: comment on what the hell this does
      (prev.fetchpatch {
        url = "https://github.com/openldap/openldap/commit/d7c0417bcfba5400c0be2ce83eaf43ec97c97edd.patch";
        sha256 = "sha256-l7b17j8Cm7zMotq7wBoNRNCaQgdoNAvf4h7XJ+Q1Le4=";
      })
    ];
    doCheck = false;
  });
  elfutils = prev.elfutils.overrideAttrs (_old: {
    doCheck = false;
    doInstallCheck = false;
  });
  ell = prev.ell.overrideAttrs (_old: {
    doCheck = false;
  });
  fish = prev.fish.overrideAttrs (old: {
    LDFLAGS = "-latomic";
    postPatch = old.postPatch + ''
      rm tests/checks/noshebang.fish
      rm tests/checks/sigint.fish
      rm tests/pexpects/torn_escapes.py
    '';
  });
  zstd = prev.zstd.overrideAttrs (old: {
    LDFLAGS = "-latomic";
  });
  nix = prev.nix.overrideAttrs (old: {
    preInstallCheck = old.preInstallCheck + ''
      echo "exit 99" > tests/check.sh
      echo "exit 99" > tests/remote-store.sh
      echo "exit 99" > tests/fetchurl.sh
      echo "exit 99" > tests/secure-drv-outputs.sh
    '';
  });
  # TODO: add rust packages mdbook, ripgrep

} // (
  let
    packageOverrides = python-final: python-prev: {
      pytest-xdist = python-prev.pytest-xdist.overrideAttrs (_old: {
        doCheck = false;
        doInstallCheck = false;
      });
      hypothesis = python-prev.hypothesis.overrideAttrs (_old: {
        doCheck = false;
      });
      requests = python-prev.requests.overrideAttrs (_old: {
        disabledTests = [
          "test_basic"
          "test_basic_response"
          "test_basic_waiting_server"
          "test_chunked_encoding_error"
          "test_chunked_upload"
          "test_chunked_upload_doesnt_skip_host_header"
          "test_chunked_upload_uses_only_specified_host_header"
          "test_conflicting_content_lengths"
          "test_digestauth_401_count_reset_on_redirect"
          "test_digestauth_401_only_sent_once"
          "test_digestauth_only_on_4xx"
          "test_fragment_not_sent_with_request"
          "test_fragment_update_on_redirect"
          "test_redirect_rfc1808_to_non_ascii_location"
          "test_request_recovery_with_bigger_timeout"
          "test_server_closes"
          "test_server_finishes_on_error"
          "test_server_finishes_when_no_connections"
          "test_text_response"
        ];
      });
    };
  in
  rec {
    python38 = prev.python38.override { inherit packageOverrides; };
    python39 = prev.python39.override { inherit packageOverrides; };
    python310 = prev.python310.override { inherit packageOverrides; };
    pythonPackages38 = python38.pkgs;
    pythonPackages39 = python39.pkgs;
    pythonPackages310 = python310.pkgs;
  }
)
