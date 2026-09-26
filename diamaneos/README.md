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

Check out at `packages/services/Iwlan`. Include `diamaneos/product.mk` from the
product and `diamaneos/board.mk` from BoardConfig. These select `Iwlan` plus AOSP
`QualifiedNetworksService`, provide the six framework service bindings, and add
only this package's policy. Do not install another WLAN data/network service or
competing overlay simultaneously. CarrierConfig overrides take precedence and
must select the same qualified stack for each carrier.

The service still uses the platform signing certificate for the signature-only
IPsec permission path. It no longer uses `android.uid.system`. All signature and
privileged permissions remain manifest-declared; the signature does not justify
sharing a UID. Moving to a dedicated signing key requires qualification of the
bound-service app-op grant/revocation path first. Do not grant an IPsec app-op
permanently from init as a shortcut.

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
