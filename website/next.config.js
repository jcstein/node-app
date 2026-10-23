const withNextra = require('nextra')({
  theme: 'nextra-theme-docs',
  themeConfig: './theme.config.tsx',
  latex: true,
})

module.exports = withNextra()

// ESM-only package. Dynamic import is what `opennextjs-cloudflare migrate` writes
// into a CommonJS Next config, and it no-ops outside `next dev`.
import('@opennextjs/cloudflare').then((m) => m.initOpenNextCloudflareForDev())
