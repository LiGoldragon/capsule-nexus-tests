# Upgrades

## Capsule Nexus 0.9.0 — the shared layer's 0.2.0

The regressions follow Capsule Nexus onto the nexus crates and the
translator crates 0.2.0 (capsule-nexus 09dc078). Nothing they pass changes:
they call the daemon's bodies directly and name no place to a CLI, and the
emitter they replace still answers an `EmissionResult`. The patch still
applies, at new offsets.
