# DiamaneOS IWLAN integration

This fork keeps the AOSP IWLAN and Android IKE/IPsec implementation. It is the
AP-assisted alternative to a modem-backed IWLAN. The Fairphone 6 product uses
Qualcomm's modem-backed IWLAN and does not select this package.

Downstream changes:

- a separate app UID and package-specific SELinux domain;
- direct networking limited to IKE UDP plus Android DNS/network binding;
- the restart provider protected at the manifest boundary, and disabled restart
  state handled;
- subscriber authentication identities and detailed network objects removed
  from selected diagnostic logs.

No carrier authentication, TLS/IKE identity check or cryptographic algorithm is
weakened.

Upstream history is kept; DiamaneOS changes are the commits on top. Review
upstream changes normally: the downstream changes are no substitute for
current IPsec/IKE modules.

## Product wiring

- Check out at `packages/services/Iwlan`. Include `diamaneos/product.mk` from
  the product and `diamaneos/board.mk` from BoardConfig.
- These select `Iwlan` plus AOSP `QualifiedNetworksService`, provide the
  framework service bindings (`diamaneos/overlay`) and add only this package's
  policy.
- Install no other WLAN data/network service or competing overlay alongside;
  `product.mk` refuses a second IWLAN implementation.
- CarrierConfig overrides take precedence and must select the same stack for
  each carrier.

## Signing and networking

- The service uses the platform signing certificate for the signature-only
  IPsec permission path, but not `android.uid.system`.
- All signature and privileged permissions stay manifest-declared; the
  signature does not justify sharing a UID.
- Do not grant an IPsec app-op permanently from init in place of the platform
  signature.
- The app does not inherit `netdomain`, which also grants raw-IP and route
  netlink access.
- The pinned IKE library uses UDP sockets; DNS resolution and network binding
  use netd's dedicated Unix sockets; IpSecService keeps kernel XFRM operations.
- Review socket needs when updating the IKE implementation. Never remove the
  raw/modem/XFRM restrictions to fit a broad macro.

## Checks for a product that selects it

- Build the app and policy with neverallows; run `IwlanTests` and
  `IwlanRobolectricTests`.
- Verify the separate runtime UID/domain, phone binding, permission grants and
  revocation, IPsec kernel features and system-server-owned tunnel resources.
- The Qualcomm IMS/radio implementation must support the AP-assisted IWLAN data
  path and QNS handovers. A fake service cannot replace a required modem/QTI
  IWLAN vendor interface.
- Keep carrier ePDG authentication, provisioning and the user's Wi-Fi calling
  choice.
- Cover both SIMs, IPv4/IPv6, reconnect, suspend, handover, VPN/lockdown,
  DNS/TLS/IKE failures and call audio.
- TS.43 entitlement is a separate package, the
  [ImsServiceEntitlement fork](https://github.com/DiamaneOS/platform_packages_apps_ImsServiceEntitlement);
  this package does not select it.
- Do not bypass entitlement or enable Wi-Fi calling globally just to make a
  toggle visible.
