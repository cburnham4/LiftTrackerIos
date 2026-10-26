#!/usr/bin/env node
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import http from "node:http";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const outDir = join(root, "exported-store-screenshots");
const SLIDE_COUNT = 6;
const HOOK = "__LIFTTRACKER_EXPORT_SLIDE__";
const PORT = 3010;

function waitForPort(port, maxMs = 120000) {
  const start = Date.now();
  return new Promise((resolve, reject) => {
    const tryOnce = () => {
      const req = http.get(`http://127.0.0.1:${port}`, (res) => {
        res.resume();
        resolve();
      });
      req.on("error", () => {
        if (Date.now() - start > maxMs) {
          reject(new Error(`Port ${port} did not open within ${maxMs}ms`));
          return;
        }
        setTimeout(tryOnce, 400);
      });
    };
    tryOnce();
  });
}

async function main() {
  mkdirSync(outDir, { recursive: true });
  console.log("Building Next.js…");
  await new Promise((resolve, reject) => {
    const b = spawn("npm", ["run", "build"], { cwd: root, stdio: "inherit", shell: true });
    b.on("close", (code) => (code === 0 ? resolve() : reject(new Error(`build exited ${code}`))));
  });

  console.log(`Starting production server on :${PORT}…`);
  const server = spawn("npm", ["run", "start", "--", "-p", String(PORT)], {
    cwd: root, stdio: "inherit", shell: true, env: { ...process.env, PORT: String(PORT) },
  });
  await waitForPort(PORT);

  const puppeteer = (await import("puppeteer")).default;
  const browser = await puppeteer.launch({
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox", "--font-render-hinting=none"],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 900, deviceScaleFactor: 1 });
  await page.goto(`http://127.0.0.1:${PORT}`, { waitUntil: "networkidle0", timeout: 120000 });
  await page.waitForFunction(`typeof window.${HOOK} === "function"`, { timeout: 90000 });
  await page.waitForFunction(() => !document.body?.textContent?.includes("Loading assets"), { timeout: 90000 });

  for (let i = 0; i < SLIDE_COUNT; i++) {
    console.log(`Exporting slide ${i + 1}/${SLIDE_COUNT}…`);
    const result = await page.evaluate(async (idx, hook) => {
      const fn = window[hook];
      if (!fn) throw new Error("export hook missing");
      return fn(idx);
    }, i, HOOK);
    if (!result?.filename || !result?.dataUrl) throw new Error(`Slide ${i} empty`);
    const b64 = result.dataUrl.replace(/^data:image\/\w+;base64,/, "");
    writeFileSync(join(outDir, result.filename), Buffer.from(b64, "base64"));
    console.log("  →", result.filename);
  }
  await browser.close();
  server.kill("SIGTERM");
  console.log("Done. PNGs in:", outDir);
}
main().catch((e) => { console.error(e); process.exit(1); });
