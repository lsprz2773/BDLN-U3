#!/usr/bin/env node
/**
 * Genera presentacion/diapositivas.pdf a partir de la fuente del deck (presentacion/diapositivas/).
 * Cada diapositiva es una página de 1920×1080 px. Las notas del orador (<aside>) no se imprimen.
 * Uso: node scripts/diapositivas2pdf.js   (requiere Playwright con Chromium)
 */
const fs = require("fs");
const path = require("path");
const { chromium } = require("playwright");

const RAIZ = path.resolve(__dirname, "..");
const DECK = path.join(RAIZ, "presentacion", "diapositivas");
const SALIDA = path.join(RAIZ, "presentacion", "diapositivas.pdf");

// Las imágenes del deck en línea apuntan a sus assets; aquí se usan las copias del repo.
const IMAGENES = {
  "/_blob/011e1ae371b65cd12c89b729f8265aa1": path.join(RAIZ, "presentacion", "modelo-tres-zonas.png"),
  "/_blob/9ade4df053d631d6d0a02343a50efb5d": path.join(RAIZ, "entregables", "06-modelo-logico.png"),
};

(async () => {
  const deck = JSON.parse(fs.readFileSync(path.join(DECK, "deck.json"), "utf8"));
  const hrefs = [...new Set(Object.values(deck.faces).map((f) => f.href).filter(Boolean))];
  let cuerpo = deck.order
    .map((id) => fs.readFileSync(path.join(DECK, "slides", `${id}.html`), "utf8"))
    .join("\n");
  for (const [blob, archivo] of Object.entries(IMAGENES)) {
    const datos = fs.readFileSync(archivo).toString("base64");
    cuerpo = cuerpo.split(blob).join(`data:image/png;base64,${datos}`);
  }
  const html = `<!doctype html><html lang="es"><head><meta charset="utf-8"><title>${deck.title}</title>
${hrefs.map((h) => `<link rel="stylesheet" href="${h}">`).join("\n")}
<style>
@page { size: 1920px 1080px; margin: 0 }
* { box-sizing: border-box; margin: 0 }
html, body { margin: 0; padding: 0 }
section { width: 1920px; height: 1080px; position: relative; overflow: hidden; page-break-after: always; break-after: page }
section aside { display: none }
ul, ol { padding-left: 1.2em }
table { border-collapse: collapse; width: 100% }
th, td { border: 1px solid #C9C3B8; padding: 0.35em 0.6em; text-align: left; vertical-align: top }
th { font-weight: 600 }
</style></head><body>${cuerpo}</body></html>`;

  const navegador = await chromium.launch();
  const pagina = await navegador.newPage({ viewport: { width: 1920, height: 1080 } });
  await pagina.setContent(html, { waitUntil: "networkidle" });
  await pagina.evaluate(() => document.fonts.ready);
  await pagina.pdf({ path: SALIDA, width: "1920px", height: "1080px", printBackground: true, margin: { top: 0, right: 0, bottom: 0, left: 0 } });
  await navegador.close();
  console.log("OK", path.relative(RAIZ, SALIDA), deck.order.length, "diapositivas");
})();
