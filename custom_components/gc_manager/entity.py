# Copyright (c) 2026 Kenneth Baker <bakerkj@umich.edu>
# All rights reserved.

"""Shared device info for GC Manager entities."""

from __future__ import annotations

from homeassistant.helpers.device_registry import DeviceEntryType, DeviceInfo

from .const import DEFAULT_NAME, DOMAIN


def gc_device_info(entry_id: str) -> DeviceInfo:
    """The single service device all GC Manager entities belong to."""
    return DeviceInfo(
        identifiers={(DOMAIN, entry_id)},
        name=DEFAULT_NAME,
        entry_type=DeviceEntryType.SERVICE,
    )
