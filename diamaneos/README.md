# DiamaneOS IWLAN integration

This fork retains the AOSP IWLAN and Android IKE/IPsec implementation. Downstream
changes give the service a separate app UID and package-specific SELinux domain,
protect its restart provider at the manifest boundary, handle disabled restart
state, and remove subscriber authentication identities and detailed network
objects from selected diagnostic logs. No carrier authentication, TLS/IKE identity
check or cryptographic algorithm is weakened.

Baseline: AOSP `ddf0eb7f277ea6a5a62c63678d17218714f38071`. Keep the upstream history
and review upstream changes normally; downstream changes are not a replacement
for keeping the platform's IPsec/IKE modules current.

## Product wiring

- Check out at `packages/services/Iwlan`. Include `diamaneos/product.mk` from
  the product and `diamaneos/board.mk` from BoardConfig.
- These select `Iwlan` plus AOSP `QualifiedNetworksService`, provide the
  framework service bindings (`diamaneos/overlay`) and add only this package's
  policy.
- Install no other WLAN data/network service or competing overlay alongside.
  `product.mk` refuses a second IWLAN implementation.
- CarrierConfig overrides take precedence and must select the same stack for
  each carrier.

## Signing and networking

- The service uses the platform signing certificate for the signature-only
  IPsec permission path, but not `android.uid.system`.
- All signature and privileged permissions stay manifest-declared. The
  signature does not justify sharing a UID.
- Do not grant an IPsec app-op permanently from init in place of the platform
  signature.
- The app does not inherit `netdomain`, which also grants raw-IP and route
  netlink access.
- The pinned IKE library uses UDP sockets. DNS resolution and network binding
  use netd's dedicated Unix sockets. IpSecService keeps kernel XFRM operations.
- Review socket needs when updating the IKE implementation. Never remove the
  raw/modem/XFRM restrictions to fit a broad macro.

## Qualification before product enablement

This source integration is not a tested FP6 Wi-Fi calling release. Build the app
and policy with neverallows, run `IwlanTests`/`IwlanRobolectricTests`, verify the
separate runtime UID/domain, phone binding, permission grants and revocation,
IPsec kernel features, and system-server-owned tunnel resources.

Confirm the selected Qualcomm IMS/radio implementation supports the AP-assisted
IWLAN data path and QNS handovers. A modem/QTI IWLAN vendor interface requirement
cannot be replaced by a fake service. Retain carrier ePDG authentication,
provisioning and user Wi-Fi calling choice. Validate both SIMs, IPv4/IPv6,
reconnect, suspend, handover, VPN/lockdown, DNS/TLS/IKE failures and call audio.
Emergency routing/location/callback tests need an authorized carrier/lab route.

Do not automatically bundle `ImsServiceEntitlement`: the inspected AOSP revision
includes Firebase/Play messaging dependencies. Carriers requiring TS.43 activation
need a separately reviewed provisioning implementation; do not bypass entitlement
or enable Wi-Fi calling globally merely to make a toggle visible.
