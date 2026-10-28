# Tokscale

The module installs the pinned CLI without uploads, login or autosubmit setup.
Run local reports explicitly, for example:

```sh
tokscale --client codex --json --no-spinner
```

Use native `--home PATH` for synthetic report inputs instead of scanning the
owner's histories during tests. `--test-data` generates display data and does
not verify a client's session parser.

In pinned release 4.20.1, a missing price can appear as numeric `cost: 0` in JSON,
including for an unrecognized gateway model. Treat that as unknown, not free.
Offline reports can also lack pricing for recognized models. Native custom
pricing belongs in the writable `~/.config/tokscale/custom-pricing.json`; enter
only independently verified model/provider rates. Do not invent a price for a
routed alias or treat aggregate estimates as a shared provider spending cap.

Token totals and billing estimates have separate acceptance. Use provider usage
and billing controls for spending decisions; the native report's zero cost is
not evidence that a request was unbilled.
