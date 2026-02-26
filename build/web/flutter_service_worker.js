'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "6bdca56fde9066877d5b52626fcfe474",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/favicon-70x70.png": "45671e0caab2d6fca426ac4e0f923aed",
"icons/favicon-120x120.png": "4dcae267f3dd2f214bf76a923387191d",
"icons/favicon-16x16.png": "54c4d9be5ec9b6f20b4cda99303acf50",
"icons/Icon-192.png": "0a40a6bc62ec249c754c24caf61a7a93",
"icons/Icon-maskable-192.png": "0a40a6bc62ec249c754c24caf61a7a93",
"icons/favicon-152x152.png": "5b536a0ffee77a4f423ef997a7fcfc65",
"icons/favicon-57x57.png": "11509692d15ccac6b395372dc60ee05b",
"icons/favicon-310x310.png": "7bcc2a10413cfe4f74c6459bc60e2388",
"icons/favicon-144x144.png": "751a8522a409b1a694c923be426ae8ff",
"icons/Icon-maskable-512.png": "af86885cf3a0f37909bfae97e2107da3",
"icons/favicon-32x32.png": "27d59cf767ef407f4af0977b9a07af0f",
"icons/favicon-192x192.png": "0a40a6bc62ec249c754c24caf61a7a93",
"icons/48x48.png": "e926e4041c5fde576350b5d9e75e09fd",
"icons/favicon-48x48.png": "36812310202fe799de21e67b4bc12795",
"icons/favicon-72x72.png": "44b6c9df4cf08ef69931476e03b6e23b",
"icons/favicon-76x76.png": "7e2e8f7907494bdba3c808f0d5662aec",
"icons/favicon-60x60.png": "d2c4aea052dfdb71b456513a505adbef",
"icons/128x128.png": "3cd69bcb08683e2124d5fe989d8f4eaa",
"icons/favicon-180x180.png": "642e9b2e0df5f9165fc3e9d0ff5ff837",
"icons/16x16.png": "64e07539fc77e183fe12a823cbc96552",
"icons/Icon-512.png": "af86885cf3a0f37909bfae97e2107da3",
"icons/favicon-150x150.png": "edc9c4e9cbbf155d1e1d0288e5ec69c2",
"icons/favicon-64x64.png": "2cb22e30cdf513af9cf2f8ba1a98182b",
"icons/favicon-196x196.png": "1c99b6d3fd3fe71dea6d45b9e10055a6",
"icons/favicon-114x114.png": "4d72423c1c695f377bc1ed649c95de58",
"icons/favicon-96x96.png": "def74de3970a928112f492296c325908",
"icons/favicon-128x128.png": "3cd69bcb08683e2124d5fe989d8f4eaa",
"icons/favicon-24x24.png": "789090a394f8648cf7483b6d38f4501f",
"main.dart.js": "1aada3d0db951c2986fb593f683c1445",
"index.html": "139582552fae43b909dc8a0d9ccdfde0",
"/": "139582552fae43b909dc8a0d9ccdfde0",
"favicon.ico": "f6c97e81424e5930cdd8a510a12ba9e2",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"version.json": "4d5213fc901c411cd81e25f07c486780",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "e9c434c5239e2b3ad68c88f6a2cfc7cd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/AssetManifest.bin.json": "dc8eacaf4cd3485b478982a64e5c430c",
"assets/fonts/MaterialIcons-Regular.otf": "cfbfef7e2bb919cd07dbc1dcbcae690d",
"assets/AssetManifest.bin": "1eaaf6c90afc0f1d1e46bb82fddeb44b",
"assets/assets/images/TurayevAlijon.png": "66aa1445c4c4135ecc9bf92b1a6bc6b2",
"assets/assets/images/person.jpeg": "f51f27a84b9f1ce9450d13177f4dfd93",
"assets/assets/images/logo.png": "f09bf5658928aa0f7fd29aec4e71dfe5",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"manifest.json": "156e6b9afd0c0564b32fd78ee931bbf9"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
