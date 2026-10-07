/* Service worker: makes the app work with no network at all.
   It caches the app shell on install and serves from cache first, so once
   the phone has loaded the page a single time it never needs the internet
   again — airplane mode, dead Wi-Fi, doesn't matter.

   This caches the PROGRAM only. Your stats live in localStorage and are
   never touched by, or visible to, this worker.

   Bump VERSION whenever index.html changes, or phones will keep serving
   the old cached copy forever. */
const VERSION = 'vbstats-2026-10-07d';

const ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-512.png',
  './icon-maskable.png',
  './apple-touch-icon.png',
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(VERSION)
      // individual failures must not abort the whole install
      .then(c => Promise.all(ASSETS.map(a => c.add(a).catch(() => {}))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  if (new URL(req.url).origin !== location.origin) return;

  e.respondWith(
    caches.match(req, { ignoreSearch: true }).then(hit => {
      if (hit) return hit;
      return fetch(req).then(res => {
        if (res && res.ok) {
          const copy = res.clone();
          caches.open(VERSION).then(c => c.put(req, copy));
        }
        return res;
      }).catch(() =>
        // offline and uncached: any navigation still lands on the app
        req.mode === 'navigate' ? caches.match('./index.html') : Response.error()
      );
    })
  );
});
