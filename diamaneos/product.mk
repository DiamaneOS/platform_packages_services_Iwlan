# SPDX-License-Identifier: Apache-2.0
# Paired with board.mk. Carrier provisioning and user Wi-Fi calling choice stay authoritative.
PRODUCT_PACKAGES += Iwlan QualifiedNetworksService
PRODUCT_PACKAGE_OVERLAYS += packages/services/Iwlan/diamaneos/overlay
