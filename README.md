# Typesense on Railway

A production-ready [Typesense](https://typesense.org) deployment for [Railway](https://railway.com), fronted by a minimal [Caddy](https://caddyserver.com) reverse proxy so it binds correctly to Railway's `$PORT`.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/T-iWQJ?referralCode=ZZkklF&utm_medium=integration&utm_source=template&utm_campaign=generic)

This repo is the upstream service used by the [**TypeLens + Typesense Dashboard** template](https://railway.com/deploy/typelens-typesense-dashboard) — deploy that template to get this Typesense server *plus* the [TypeLens](https://typelens.copperline.io) admin dashboard wired together in one click.

---

## What you get

- **Typesense 30.2** — fast, typo-tolerant search engine
- **Caddy** reverse proxy on `$PORT` → Typesense on `127.0.0.1:8118`
- **Alpine + `parallel`** runtime that supervises both processes and exits if either dies
- Single-container Dockerfile, no extra services required

## Architecture

```
Railway $PORT  ──►  Caddy (reverse_proxy)  ──►  127.0.0.1:8118  Typesense
```

Caddy is configured in [Caddyfile](Caddyfile):
- `admin off`, `persist_config off`, `auto_https off` — Railway terminates TLS, so Caddy stays minimal
- Runtime logs discarded (Typesense handles its own)

Both processes are launched in parallel by [scripts/start.sh](scripts/start.sh); if either exits, the container exits so Railway restarts it.

## Quick deploy

The fastest path:

1. Click the **Deploy on Railway** button above (this Typesense service only), or
2. Deploy the full [TypeLens + Typesense Dashboard template](https://railway.com/deploy/typelens-typesense-dashboard) to also provision the TypeLens UI.

## Configuration

Set these on the Railway service:

| Variable | Required | Description |
|---|---|---|
| `TYPESENSE_API_KEY` | yes | Admin API key clients must present. Generate a strong random value. |
| `TYPESENSE_DATA_DIR` | yes | Where Typesense persists data. Set to the mount path of a Railway volume (e.g. `/data`). |
| `PORT` | auto | Injected by Railway; Caddy listens on it. |

Attach a **Railway volume** mounted at `TYPESENSE_DATA_DIR` — without it, your collections vanish on redeploy.

Additional Typesense options (CORS, peering, log level, etc.) can be passed via env vars per the [Typesense server config reference](https://typesense.org/docs/guide/install-typesense.html#configure-typesense).

## Using it

Once deployed, hit the public Railway URL with the standard Typesense API:

```bash
curl "https://<your-service>.up.railway.app/health"

curl "https://<your-service>.up.railway.app/collections" \
  -H "X-TYPESENSE-API-KEY: $TYPESENSE_API_KEY"
```

Or point any Typesense client (JS, Python, Ruby, Go, PHP, etc.) at the URL.

### Pair it with TypeLens

[TypeLens](https://typelens.copperline.io) is a dashboard for managing Typesense collections, documents, synonyms, and search analytics — connect it to this deployment by providing the Railway URL and your `TYPESENSE_API_KEY`.

## Local development

```bash
docker build -t typesense-railway .
docker run --rm -p 8080:8080 \
  -e PORT=8080 \
  -e TYPESENSE_API_KEY=devkey \
  -e TYPESENSE_DATA_DIR=/tmp/typesense-data \
  -v $(pwd)/.data:/tmp/typesense-data \
  typesense-railway
```

Then `curl http://localhost:8080/health`.

## Upgrading Typesense

Bump the tag in [Dockerfile](Dockerfile):

```dockerfile
FROM typesense/typesense:30.2
```

Check the [Typesense changelog](https://typesense.org/docs/overview/releases.html) before upgrading across major versions.

## Related

- 🔭 **TypeLens dashboard** — [typelens.copperline.io](https://typelens.copperline.io)
- 🚂 **One-click template (Typesense + TypeLens)** — [railway.com/deploy/typelens-typesense-dashboard](https://railway.com/deploy/typelens-typesense-dashboard)
- 📚 **Typesense docs** — [typesense.org/docs](https://typesense.org/docs)

## License

MIT
