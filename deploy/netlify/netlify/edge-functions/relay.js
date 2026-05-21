// XHTTP Netlify Edge Relay
export const config = { path: "/*" };

export default async function handler(req) {
  const base = (Netlify.env.get("TARGET_DOMAIN") || "").replace(/\/$/, "");
  if (!base) return new Response("TARGET_DOMAIN not set", { status: 500 });
  try {
    const url = new URL(req.url);
    const h = new Headers();
    let ip = null;
    for (const [k, v] of req.headers) {
      const lk = k.toLowerCase();
      if (["host","connection","keep-alive","transfer-encoding","upgrade","forwarded","x-forwarded-host","x-forwarded-proto","x-forwarded-port"].includes(lk) || lk.startsWith("x-nf-") || lk.startsWith("x-netlify-")) continue;
      if (lk === "x-real-ip") { ip = v; continue; } if (lk === "x-forwarded-for") { ip = ip || v; continue; }
      h.set(k, v);
    }
    if (ip) h.set("x-forwarded-for", ip);
    const opts = { method: req.method, headers: h, redirect: "manual" };
    if (req.method !== "GET" && req.method !== "HEAD") opts.body = req.body;
    const up = await fetch(base + url.pathname + url.search, opts);
    const rh = new Headers();
    for (const [k, v] of up.headers) if (k.toLowerCase() !== "transfer-encoding") rh.set(k, v);
    return new Response(up.body, { status: up.status, headers: rh });
  } catch { return new Response("Bad Gateway", { status: 502 }); }
}
