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
  # TODO: fix neovim once riscv64 support lands on luajit
  # see https://github.com/LuaJIT/LuaJIT/issues/628
  # since neovim doesn't compile against lua 5.1 properly anymore it seems.
  # just pretending vim is neovim for now.. ugh
  neovim = prev.vim;
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
  fd = prev.fd.overrideAttrs (old: {
    # fd tests are really flaky on riscv64 for some reason, sometimes different
    # tests fail so just skipping all of them
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
  mdbook = prev.mdbook.overrideAttrs (old: {
    checkFlags = [
      "--exact"
      "--skip missing_optional_backends_are_not_fatal"
    ];
  });
  ripgrep = prev.ripgrep.overrideAttrs (old: {
    checkFlags = [
      "--exact"
      "--skip misc::compressed_brotli"
      "--skip misc::compressed_lz4"
      "--skip misc::compressed_zstd"
    ];
  });
  zstd = prev.zstd.overrideAttrs (old: {
    # PR: https://github.com/NixOS/nixpkgs/pull/180028
    LDFLAGS = "-latomic";
  });
  nix = (prev.nix.overrideAttrs (old: {
    preInstallCheck = old.preInstallCheck + ''
      echo "exit 99" > tests/check.sh
      echo "exit 99" > tests/remote-store.sh
      echo "exit 99" > tests/fetchurl.sh
      echo "exit 99" > tests/secure-drv-outputs.sh
    '';
  })).override
    {
      withLibseccomp = false;
    };
}

// (
  let
    packageOverrides = python-final: python-prev: {
      pandas = python-prev.pandas.overrideAttrs (_old: {
        doCheck = false;
        doInstallCheck = false;
      });
      ttp = python-prev.ttp.overrideAttrs (_old: {
        doCheck = false;
        doInstallCheck = false;
      });
      pytest-xdist = python-prev.pytest-xdist.overrideAttrs (_old: {
        doCheck = false;
        doInstallCheck = false;
      });
      hypothesis = python-prev.hypothesis.overrideAttrs (_old: {
        doCheck = false;
        doInstallCheck = false;
      });
      requests = python-prev.requests.overrideAttrs (old: {
        disabledTests = old.disabledTests ++ [
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

// (
  let
    llvmPatch = ''
      rm test/ExecutionEngine/frem.ll
      rm test/ExecutionEngine/mov64zext32.ll
      rm test/ExecutionEngine/test-interp-vec-arithm_float.ll
      rm test/ExecutionEngine/test-interp-vec-arithm_int.ll
      rm test/ExecutionEngine/test-interp-vec-logical.ll
      rm test/ExecutionEngine/test-interp-vec-setcond-fp.ll
      rm test/ExecutionEngine/test-interp-vec-setcond-int.ll
      substituteInPlace unittests/Support/CMakeLists.txt \
        --replace "CrashRecoveryTest.cpp" ""
      rm unittests/Support/CrashRecoveryTest.cpp
      substituteInPlace unittests/ExecutionEngine/Orc/CMakeLists.txt \
        --replace "OrcCAPITest.cpp" ""
      rm unittests/ExecutionEngine/Orc/OrcCAPITest.cpp
    '';
  in
  rec {
    llvmPackages_14 = prev.llvmPackages_14 // {
      # FIXME: not sure why I have to override both llvm and libllvm?
      llvm = prev.llvmPackages_14.llvm.overrideAttrs (old: {
        postPatch = old.postPatch + llvmPatch;
      });
      libllvm = prev.llvmPackages_14.libllvm.overrideAttrs (old: {
        postPatch = old.postPatch + llvmPatch;
      });
    };
  }

) // (
  let
    bootstrapVersion = "1.17.10";
    go_bootstrap = prev.fetchurl {
      # built as:
      #  nix build .\#pkgsCross.riscv64.pkgsStatic.go
      #  tar cvzf go-riscv64-unknown-linux-gnu-1.17.10.tar.gz -C result .
      url = "https://public.tpl.wtf/~luiz/go-riscv64-unknown-linux-gnu-${bootstrapVersion}.tar.gz";
      sha256 = "sha256-gcS1rne5xH7O9b3GT60GuxbnOeICo7YyhFe2fmV3Jog=";
    };
    goBootstrap = prev.runCommand "go-bootstrap" { } ''
      mkdir $out
      tar xvf ${go_bootstrap}
      cp -r . $out/
    '';
    overriddenAttrs = {
      GOROOT_BOOTSTRAP = "${goBootstrap}/share/go";
      disallowedReferences = [ goBootstrap ];
      doCheck = false;
    };
  in
  {
    go_1_17 = prev.go_1_17.overrideAttrs (_old: overriddenAttrs);
    go_1_18 = prev.go_1_18.overrideAttrs (_old: overriddenAttrs);
  }
)
