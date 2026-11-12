#!/usr/bin/env node
/**
 * Genera presentacion/diapositivas.pptx a partir de la fuente del deck (presentacion/diapositivas/).
 * Cada diapositiva se renderiza a PNG (1920×1080, escala 2) y se coloca a sangre en una
 * diapositiva 16:9; las notas del orador (<aside>) pasan a las notas de PowerPoint.
 * El texto de las diapositivas queda como imagen (no editable), idéntico al PDF.
 * Uso: node scripts/diapositivas2pptx.js   (requiere Playwright con Chromium y pptxgenjs)
 */
const fs = require("fs");
const path = require("path");
const { chromium } = require("playwright");
const PptxGenJS = require("pptxgenjs");

const RAIZ = path.resolve(__dirname, "..");
const DECK = path.join(RAIZ, "presentacion", "diapositivas");
const SALIDA = path.join(RAIZ, "presentacion", "diapositivas.pptx");

const IMAGENES = {
  "/_blob/011e1ae371b65cd12c89b729f8265aa1": path.join(RAIZ, "presentacion", "modelo-tres-zonas.png"),
  "/_blob/9ade4df053d631d6d0a02343a50efb5d": path.join(RAIZ, "entregables", "06-modelo-logico.png"),
};

const ESTILO = `
* { box-sizing: border-box; margin: 0 }
html, body { margin: 0; padding: 0; width: 1920px; height: 1080px; overflow: hidden }
section { width: 1920px; height: 1080px; position: relative; overflow: hidden }
section aside { display: none }
ul, ol { padding-left: 1.2em }
table { border-collapse: collapse; width: 100% }
th, td { border: 1px solid #C9C3B8; padding: 0.35em 0.6em; text-align: left; vertical-align: top }
th { font-weight: 600 }`;

const textoPlano = (html) =>
  html.replace(/<[^>]+>/g, "").replace(/&nbsp;/g, " ").replace(/&amp;/g, "&").replace(/\s+/g, " ").trim();

(async () => {
  const deck = JSON.parse(fs.readFileSync(path.join(DECK, "deck.json"), "utf8"));
  const hrefs = [...new Set(Object.values(deck.faces).map((f) => f.href).filter(Boolean))];
  const enlaces = hrefs.map((h) => `<link rel="stylesheet" href="${h}">`).join("\n");

  const pptx = new PptxGenJS();
  pptx.layout = "LAYOUT_WIDE"; // 13.333 × 7.5 in (16:9)
  pptx.title = deck.title;

  const navegador = await chromium.launch();
  const pagina = await navegador.newPage({ viewport: { width: 1920, height: 1080 }, deviceScaleFactor: 2 });

  for (const id of deck.order) {
    let seccion = fs.readFileSync(path.join(DECK, "slides", `${id}.html`), "utf8");
    for (const [blob, archivo] of Object.entries(IMAGENES)) {
      if (seccion.includes(blob)) {
        const datos = fs.readFileSync(archivo).toString("base64");
        seccion = seccion.split(blob).join(`data:image/png;base64,${datos}`);
      }
    }
    const notas = (seccion.match(/<aside[^>]*>([\s\S]*?)<\/aside>/) || [, ""])[1];
    const html = `<!doctype html><html lang="es"><head><meta charset="utf-8">${enlaces}<style>${ESTILO}</style></head><body>${seccion}</body></html>`;
    await pagina.setContent(html, { waitUntil: "networkidle" });
    await pagina.evaluate(() => document.fonts.ready);
    const png = await pagina.screenshot({ type: "png", clip: { x: 0, y: 0, width: 1920, height: 1080 } });

    const diapo = pptx.addSlide();
    diapo.addImage({ data: `image/png;base64,${png.toString("base64")}`, x: 0, y: 0, w: "100%", h: "100%" });
    if (notas) diapo.addNotes(textoPlano(notas));
  }

  await navegador.close();
  await pptx.writeFile({ fileName: SALIDA });
  console.log("OK", path.relative(RAIZ, SALIDA), deck.order.length, "diapositivas");
})();
