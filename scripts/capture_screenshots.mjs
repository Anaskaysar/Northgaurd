import { chromium } from "playwright";
import { mkdirSync } from "fs";
import path from "path";

const OUT = path.resolve("submission_media/raw");
const BASE = process.env.APP_URL || "http://127.0.0.1:8000";

mkdirSync(OUT, { recursive: true });

async function shot(page, name, opts = {}) {
  await page.screenshot({
    path: path.join(OUT, name),
    fullPage: opts.fullPage ?? false,
  });
  console.log("saved", name);
}

async function main() {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  await page.goto(BASE, { waitUntil: "networkidle", timeout: 30000 });
  await page.waitForTimeout(1500);

  await shot(page, "01_dashboard.png", { fullPage: true });

  // History tab
  await page.getByRole("button", { name: /audit trail/i }).click();
  await page.waitForTimeout(800);
  await shot(page, "02_audit_trail.png", { fullPage: true });

  await browser.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
