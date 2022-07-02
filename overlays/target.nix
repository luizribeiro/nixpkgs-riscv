final: prev:

{
  linux-firmware = prev.linux-firmware.overrideAttrs (old: {
    postInstall = ''
      cp $out/lib/firmware/brcm/brcmfmac43430-sdio.AP6212.txt \
        $out/lib/firmware/brcm/brcmfmac43430-sdio.starfive,visionfive-v1.txt
    '';
    outputHash = null;
  });
}
