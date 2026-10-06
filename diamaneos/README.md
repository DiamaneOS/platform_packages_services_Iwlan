# DiamaneOS IWLAN integration

This fork keeps the AOSP IWLAN and Android IKE/IPsec implementation. Downstream
changes:

- a separate app UID and package-specific SELinux domain;
- direct networking limited to IKE UDP plus Android DNS/network binding;
- the restart provider protected at the manifest boundary, and disabled restart
  state handled;
- subscriber authentication identities and detailed network objects removed
  from selected diagnostic logs.

No carrier authentication, TLS/IKE identity check or cryptographic algorithm is
weakened.

Baseline: AOSP `ddf0eb7f277ea6a5a62c63678d17218714f38071`. Keep upstream
history and review upstream changes normally; the downstream changes are no
substitute for current IPsec/IKE modules.

## Product wiring

- Check out at `packages/services/Iwlan`. Include `diamaneos/product.mk` from
  the product and `diamaneos/board.mk` from BoardConfig.
- These select `Iwlan` plus AOSP `QualifiedNetworksService`, provide the six
  framework service bindings and add only this package's policy.
- Install no other WLAN data/network service or competing overlay alongside.
  CarrierConfig overrides take precedence and must select the same qualified
  stack for each carrier.

## Signing and networking

- The service still uses the platform signing certificate for the
  signature-only IPsec permission path, but no longer `android.uid.system`. All
  signature and privileged permissions stay manifest-declared; the signature
  does not justify sharing a UID.
- Moving to a dedicated signing key first needs qualification of the
  bound-service app-op grant/revocation path. Do not grant an IPsec app-op
  permanently from init as a shortcut.
- The app does not inherit `netdomain`, which also grants raw-IP and route
  netlink access. The pinned IKE library uses UDP sockets; DNS resolution and
  network binding use netd's dedicated Unix sockets; IpSecService keeps kernel
  XFRM operations.
- Review socket needs when updating the IKE implementation. Never remove the
  raw/modem/XFRM restrictions to fit a broad macro.

## Qualification before product enablement

This source integration is not a tested FP6 Wi-Fi calling release.

- Build the app and policy with neverallows; run
  `IwlanTests`/`IwlanRobolectricTests`.
- Verify the separate runtime UID/domain, phone binding, permission grants and
  revocation, IPsec kernel features and system-server-owned tunnel resources.
- Confirm the selected Qualcomm IMS/radio implementation supports the
  AP-assisted IWLAN data path and QNS handovers. A fake service cannot replace a
  required modem/QTI IWLAN vendor interface.
- Keep carrier ePDG authentication, provisioning and the user's Wi-Fi calling
  choice.
- Validate both SIMs, IPv4/IPv6, reconnect, suspend, handover, VPN/lockdown,
  DNS/TLS/IKE failures and call audio. Emergency routing/location/callback tests
  need an authorized carrier/lab route.
- Do not automatically bundle `ImsServiceEntitlement`: the inspected AOSP
  revision includes Firebase/Play messaging dependencies. Carriers requiring
  TS.43 activation need a separately reviewed provisioning implementation. Do
  not bypass entitlement or enable Wi-Fi calling globally just to make a toggle
  visible.
