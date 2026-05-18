# Inngest Basic Auth Nginx Proxy for Railway.app

An nginx reverse proxy that sits in front of a self-hosted [Inngest](https://www.inngest.com) instance on Railway and password-protects the dashboard, while letting all API traffic through without the nginx password — API requests are still secured by Inngest's own event keys and signing keys.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/bYH8Xt?referralCode=WSv72h)

## The problem

When you self-host Inngest on Railway and enable public networking, the Inngest dashboard becomes publicly accessible to anyone — there is no built-in authentication. This proxy sits in front of Inngest and adds HTTP basic auth to the dashboard without touching the Inngest service itself.

## How it works

All Inngest API endpoints (event ingestion, function registration, run management, etc.) must remain publicly reachable so your apps and the Inngest SDK can call them without a password. Only the dashboard UI at `/` is protected.

| Path | Protected | Purpose |
|------|-----------|---------|
| `/` (dashboard) | **Yes — basic auth** | Inngest web UI |
| `/e/{key}` | No | Event ingestion from your apps |
| `/fn/` | No | SDK function registration and sync |
| `/invoke/` | No | Function invocation |
| `/health` | No | Health checks |
| `/v0/` | No | Core API |
| `/v1/` | No | REST API v1 — runs, events, apps, cancellations, signals, traces |
| `/v1/realtime/` | No | WebSocket realtime connection |
| `/api/` | No | REST API v2 |
| `/dev` | No | Dev server info and OTLP traces |
| `/metrics` | No | Prometheus metrics |

## Networking

The Inngest API is exposed publicly at `https://<nginx-proxy-public-url>`. This URL can be used to access the dashboard (with a password) and is the address you give to any external services that need to send events or call the API.

However, if your app is hosted in the same Railway project as Inngest, it is recommended to connect directly using Railway's private networking: `http://inngest.railway.internal:8288`. This keeps traffic internal and avoids the public internet entirely. Use `https://<nginx-proxy-public-url>` only for dashboard access in that case.

## Setup

Deploy this template on Railway and set the following environment variables.

**`INNGEST_SERVE_ORIGIN`**

The URL of your app's Inngest serve endpoint. Inngest calls this URL to trigger your functions. If your app is in the same Railway project, use the private network URL.

Example: `http://my-app.railway.internal:3000`

**`DASHBOARD_USERNAME`**

Username for the dashboard login prompt.

**`DASHBOARD_PASSWORD`**

Password for the dashboard login prompt.

## Notes

**First load** — On the first visit to the dashboard you may need to enter the username and password a few times before it loads. This is normal; the browser sends several requests for the initial page and each one triggers the auth prompt.
