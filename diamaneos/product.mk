# SPDX-License-Identifier: Apache-2.0
# Paired with board.mk; carrier provisioning and user Wi-Fi calling choice stay authoritative.
ifneq ($(filter-out aosp,$(DIAMANEOS_IWLAN_IMPLEMENTATION)),)
$(error AOSP IWLAN cannot be selected alongside another device IWLAN implementation)
endif
DIAMANEOS_IWLAN_IMPLEMENTATION := aosp
PRODUCT_PACKAGES += Iwlan QualifiedNetworksService
PRODUCT_PACKAGE_OVERLAYS += packages/services/Iwlan/diamaneos/overlay
