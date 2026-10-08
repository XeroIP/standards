// A static file server for checking a built documentation site.
//
// Serving over HTTP rather than opening file:// is deliberate. Several
// generators resolve assets from an absolute root path, and a file:// page
// silently loses them — which looks like a broken design system rather than a
// broken way of loading it.
//
// Shared by check-rendered-design.js and capture-screens.js so both resolve
// URLs the same way. A gate and the screenshots taken to explain it disagreeing
// about which file a URL means would be its own bug.

const http = require("http");
const fs = require("fs");
const path = require("path");

const MIME = {
  ".html": "text/html", ".css": "text/css", ".js": "text/javascript",
  ".mjs": "text/javascript", ".json": "application/json", ".svg": "image/svg+xml",
  ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
  ".gif": "image/gif", ".webp": "image/webp", ".woff": "font/woff",
  ".woff2": "font/woff2", ".ttf": "font/ttf", ".ico": "image/x-icon",
  ".xml": "application/xml", ".txt": "text/plain",
};

/**
 * Serve `rootDir` on `port`. Resolves once listening.
 *
 * Generators disagree about URL shape — `/page/`, `/page`, `/page.html` — so
 * all three resolve here. That keeps the caller's page list portable across
 * toolchains instead of encoding one generator's convention.
 */
function serve(rootDir, port) {
  const server = http.createServer((req, res) => {
    const urlPath = decodeURIComponent(req.url.split("?")[0]);

    // Refuse traversal outside the served root before touching the filesystem.
    const resolved = path.resolve(rootDir, "." + urlPath);
    if (resolved !== path.resolve(rootDir) && !resolved.startsWith(path.resolve(rootDir) + path.sep)) {
      res.writeHead(403); res.end("forbidden"); return;
    }

    let file = resolved;
    if (fs.existsSync(file) && fs.statSync(file).isDirectory()) {
      file = path.join(file, "index.html");
    } else if (!fs.existsSync(file) && fs.existsSync(file + ".html")) {
      file += ".html";
    } else if (!fs.existsSync(file) && fs.existsSync(path.join(file, "index.html"))) {
      file = path.join(file, "index.html");
    }

    if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) {
      res.writeHead(404); res.end("not found"); return;
    }
    res.writeHead(200, { "Content-Type": MIME[path.extname(file)] || "application/octet-stream" });
    fs.createReadStream(file).pipe(res);
  });
  return new Promise((resolve) => server.listen(port, () => resolve(server)));
}

/**
 * Launch Chromium.
 *
 * Playwright resolves its own browser unless CHROMIUM_PATH says otherwise.
 * The override exists because sandboxes and CI images often preinstall a
 * revision that differs from the one Playwright expects, and downloading a
 * second copy to satisfy a version check wastes several hundred megabytes.
 */
async function launchBrowser() {
  let chromium;
  try {
    ({ chromium } = require("playwright"));
  } catch {
    console.error("playwright is not installed. It is an optional dependency:");
    console.error("  npm install --no-save playwright && npx playwright install chromium");
    process.exit(2);
  }
  const executablePath = process.env.CHROMIUM_PATH || undefined;
  return chromium.launch(executablePath ? { executablePath } : {});
}

module.exports = { serve, launchBrowser, MIME };
