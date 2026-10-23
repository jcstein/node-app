# quazar website

Docs site for quazar, built with [Nextra](https://nextra.site) 2 and Next.js. Cloudflare Workers Builds deploys it as a Worker named `node-app` through the OpenNext Cloudflare adapter. The production hostname is [node-app.jcstein.dev](https://node-app.jcstein.dev).

## Local development

Use Node.js 22 (see `.node-version`). From this directory:

```sh
pnpm i
pnpm dev
```

`pnpm dev` is the Next.js dev server at http://localhost:3000.

To build and run the same Worker bundle Cloudflare serves:

```sh
pnpm preview
```

That runs `opennextjs-cloudflare build`, then `opennextjs-cloudflare preview` (Workers runtime, default http://localhost:8787).

## Cloudflare Workers Builds

Connect this GitHub repo in Workers Builds. There is no GitHub Actions workflow. Exact project settings:

| Setting | Value |
| --- | --- |
| Project type | Worker (Workers Builds, Git-connected) |
| Worker name | `node-app` (from `wrangler.jsonc`) |
| Production branch | `main` |
| Root directory | `website` |
| Build command | `pnpm exec opennextjs-cloudflare build` |
| Deploy command | `pnpm exec opennextjs-cloudflare deploy` |
| Preview command | `pnpm exec wrangler preview` |
| Output directory | not used (OpenNext writes `.open-next/`; Wrangler deploys that Worker) |

`pnpm build` must stay as `next build`. The OpenNext build command calls it, then adapts the output. Do not set the Workers Builds build command to `pnpm build`.

Build variables (Settings > Build > Build variables and secrets). These are build-time only. There are no runtime secrets.

| Name | Value |
| --- | --- |
| `NODE_VERSION` | `22` |

`.node-version` in this directory also requests Node 22. Workers Builds defaults to Node 24, so set `NODE_VERSION` as well. The site has no `NEXT_PUBLIC_` variables and no `.env` files. Do not add a `SKIP_DEPENDENCY_INSTALL` variable; Workers Builds should install from `pnpm-lock.yaml`.

No R2, KV, or D1 bindings. Pages are statically generated. The Worker still serves them so Nextra's Next.js build keeps working.

After the first successful deploy, attach the hostname in the Worker dashboard: Settings > Domains & Routes > Add custom domain `node-app.jcstein.dev`. The `jcstein.dev` zone must be on the same Cloudflare account. The route is not in `wrangler.jsonc`, so a deploy can succeed before DNS is attached.

## Vercel

This directory has no `vercel.json`. The previous deployment was a Vercel project pointed at `website` (https://node-app-jcstein.vercel.app/). Disconnect that project after `node-app.jcstein.dev` is serving traffic.

## License

This project is licensed under the MIT License.
