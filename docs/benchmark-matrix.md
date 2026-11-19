# Benchmark matrix

No optimization is accepted without a baseline and repeatable comparison.

| Category | Measurements | Workload |
|---|---|---|
| Startup | WebView initialization, first render | Cold and warm starts |
| Loading | Navigation-to-content, page completion | Fixed pages and network conditions |
| Rendering | Frame time, jank, scroll smoothness | Identical page and viewport |
| Memory | PSS/RSS per process, peak and steady state | Separate browser/renderer/GPU processes |
| CPU | Utilization and time to settle | Same page and background conditions |
| Stability | Renderer crashes, ANRs, reloads | Repeated navigation and long run |
| Compatibility | HTML/CSS/JS APIs, media, storage | Web Platform Tests and real host apps |
| Security | Upstream status, sandbox/process flags | No disabled mitigations |

Record Chromium SHA, build type, GN args, Android fingerprint, selected provider, device temperature, power mode, available RAM, page revision and network conditions. Use at least five samples where appropriate; report median and spread, not only the best result.

Revert changes that improve a microbenchmark but regress real app behavior, stability, security or compatibility.
