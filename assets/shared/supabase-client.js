// ════════════════════════════════════════════════════════════════
// CLINICA CENTRAL — Supabase Client
// Initializeaza clientul Supabase folosind config-ul din config.js
// ════════════════════════════════════════════════════════════════

(function() {
  if (!window.CLINICA_CONFIG) {
    console.error("[Supabase] CLINICA_CONFIG nu e setat. Asigura-te ca config.js este incarcat inainte.");
    return;
  }
  if (!window.supabase) {
    console.error("[Supabase] Biblioteca @supabase/supabase-js nu e incarcata. Verifica scriptul CDN in HTML.");
    return;
  }

  var url = window.CLINICA_CONFIG.SUPABASE_URL;
  var key = window.CLINICA_CONFIG.SUPABASE_ANON_KEY;

  if (!url || url.indexOf("REPLACE_WITH") === 0) {
    console.error("[Supabase] URL-ul nu e configurat pentru mediul", window.CLINICA_CONFIG.ENV);
    return;
  }

  window.sb = window.supabase.createClient(url, key, {
    auth: {
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false
    }
  });

  console.log("[Supabase] Client initializat pentru", window.CLINICA_CONFIG.ENV);
})();
