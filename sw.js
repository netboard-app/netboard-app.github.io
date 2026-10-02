/* Hintergrunddienst: macht die App installierbar und zeigt Mitteilungen */
self.addEventListener("install", function(){ self.skipWaiting(); });
self.addEventListener("activate", function(e){ e.waitUntil(self.clients.claim()); });

self.addEventListener("push", function(e){
  var d = {};
  try { d = e.data ? e.data.json() : {}; } catch(err){ d = { titel:"Logenrunde", text: e.data ? e.data.text() : "" }; }
  e.waitUntil(self.registration.showNotification(d.titel || "Logenrunde", {
    body: d.text || "", icon: "icon-192.png", badge: "icon-192.png",
    tag: d.tag || undefined, renotify: !!d.tag,
    data: { ziel: d.ziel || "" }
  }));
});

// Antippen öffnet die App an der Stelle, auf die die Mitteilung zeigt (zum Beispiel "#eintrag=123")
self.addEventListener("notificationclick", function(e){
  e.notification.close();
  var anker = (e.notification.data && e.notification.data.ziel) || "";
  var ziel = new URL("./" + anker, self.location.href).href;
  e.waitUntil(self.clients.matchAll({ type:"window", includeUncontrolled:true }).then(function(liste){
    for (var i=0; i<liste.length; i++){
      if (liste[i].url.indexOf(self.registration.scope) === 0 && "focus" in liste[i]){
        liste[i].postMessage({ art:"oeffnen", anker:anker });
        return liste[i].focus();
      }
    }
    return self.clients.openWindow(ziel);
  }));
});
