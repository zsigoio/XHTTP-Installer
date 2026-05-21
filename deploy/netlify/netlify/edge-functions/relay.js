// XHTTP Netlify Edge Relay — for deploy/netlify
const TARGET_BASE = (Netlify.env.get("TARGET_DOMAIN") || "").replace(/\/$/, "");
const STRIP = new Set(["host","connection","keep-alive","proxy-authenticate","proxy-authorization","te","trailer","transfer-encoding","upgrade","forwarded","x-forwarded-host","x-forwarded-proto","x-forwarded-port"]);

export default async function handler(request) {
  if (!TARGET_BASE) return new Response("TARGET_DOMAIN not set", { status: 500 });
  try {
    const url = new URL(request.url);
    const headers = new Headers();
    let ip = null;
    for (const [k, v] of request.headers) {
      const lk = k.toLowerCase();
      if (STRIP.has(lk) || lk.startsWith("x-nf-") || lk.startsWith("x-netlify-")) continue;
      if (lk === "x-real-ip") { ip = v; continue; }
      if (lk === "x-forwarded-for") { ip = ip || v; continue; }
      headers.set(k, v);
    }
    if (ip) headers.set("x-forwarded-for", ip);
    const opts = { method: request.method, headers, redirect: "manual" };
    if (request.method !== "GET" && request.method !== "HEAD") opts.body = request.body;
    const up = await fetch(TARGET_BASE + url.pathname + url.search, opts);
    const rh = new Headers();
    for (const [k, v] of up.headers) if (k.toLowerCase() !== "transfer-encoding") rh.set(k, v);
    return new Response(up.body, { status: up.status, headers: rh });
  } catch { return new Response("Bad Gateway", { status: 502 }); }
}
