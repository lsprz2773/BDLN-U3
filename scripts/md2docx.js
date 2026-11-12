#!/usr/bin/env node
/**
 * Convierte los entregables Markdown de `entregables/` a .docx con un estilo sobrio
 * (texto negro, tablas con encabezado gris, sin colores azules ni hipervínculos).
 *
 * Uso: node scripts/md2docx.js            -> genera entregables/docx/*.docx
 *      node scripts/md2docx.js in.md out.docx [--vertical]   -> convierte un archivo cualquiera
 * Requiere el paquete npm `docx`.
 */
const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, WidthType, ShadingType,
  BorderStyle, AlignmentType, HeadingLevel, LevelFormat, ImageRun, PageOrientation, Footer,
  PageNumber, TableLayoutType,
} = require("docx");

const RAIZ = path.resolve(__dirname, "..");
const ORIGEN = path.join(RAIZ, "entregables");
const DESTINO = path.join(ORIGEN, "docx");

const FUENTE = "Arial";
const NEGRO = "000000";
const GRIS_TEXTO = "404040";
const GRIS_BORDE = "8C8C8C";
const GRIS_ENCABEZADO = "D9D9D9";
const GRIS_CODIGO = "F2F2F2";

// Carta: 12240 x 15840 DXA, márgenes de 1" (1440)
const MARGEN = 1080;
const ANCHO_CARTA = 12240;
const ALTO_CARTA = 15840;

const ENTREGABLES = [
  { md: "01-requerimientos-consultas.md", horizontal: true },
  { md: "02-diccionario-entidades.md", horizontal: true },
  { md: "03-catalogo-relaciones.md", horizontal: true },
  { md: "04-restricciones-integridad.md", horizontal: true },
  { md: "05-cardinalidades.md", horizontal: true },
  { md: "06-modelo-logico.md", horizontal: true },
  { md: "07-conclusiones.md", horizontal: false },
];

// ------------------------------------------------------------ texto en línea
function runs(texto, base = {}) {
  const res = [];
  const re = /(\*\*[^*]+\*\*|\*[^*\s][^*]*\*|`[^`]+`)/g;
  let ultimo = 0;
  let m;
  while ((m = re.exec(texto)) !== null) {
    if (m.index > ultimo) res.push(new TextRun({ text: texto.slice(ultimo, m.index), ...base }));
    const t = m[0];
    if (t.startsWith("**")) res.push(...runs(t.slice(2, -2), { ...base, bold: true }));
    else if (t.startsWith("`")) res.push(new TextRun({ text: t.slice(1, -1), ...base, font: "Consolas" }));
    else res.push(...runs(t.slice(1, -1), { ...base, italics: true }));
    ultimo = m.index + t.length;
  }
  if (ultimo < texto.length) res.push(new TextRun({ text: texto.slice(ultimo), ...base }));
  return res;
}

// ------------------------------------------------------------ tablas
function celdas(linea) {
  return linea.trim().replace(/^\|/, "").replace(/\|$/, "").split("|").map((c) => c.trim());
}

function tabla(lineas, anchoUtil) {
  const enc = celdas(lineas[0]);
  const filas = lineas.slice(2).map(celdas);
  const n = enc.length;
  // ancho proporcional a la raíz de la longitud del contenido, con mínimo
  const peso = enc.map((h, i) => {
    const largo = Math.max(h.length, ...filas.map((f) => (f[i] || "").length));
    return Math.max(Math.sqrt(largo), 3.2);
  });
  const total = peso.reduce((a, b) => a + b, 0);
  const anchos = peso.map((p) => Math.floor((p / total) * anchoUtil));
  anchos[n - 1] += anchoUtil - anchos.reduce((a, b) => a + b, 0);
  const borde = { style: BorderStyle.SINGLE, size: 4, color: GRIS_BORDE };
  const bordes = { top: borde, bottom: borde, left: borde, right: borde };
  const tam = n >= 6 ? 16 : 18; // 8 / 9 pt
  const fila = (valores, esEnc) =>
    new TableRow({
      tableHeader: esEnc,
      cantSplit: false,
      children: valores.map((v, i) =>
        new TableCell({
          width: { size: anchos[i], type: WidthType.DXA },
          borders: bordes,
          shading: esEnc ? { type: ShadingType.CLEAR, color: "auto", fill: GRIS_ENCABEZADO } : undefined,
          margins: { top: 50, bottom: 50, left: 80, right: 80 },
          children: [new Paragraph({ spacing: { before: 0, after: 0 }, children: runs(v || "", { size: tam, bold: esEnc || undefined, color: NEGRO }) })],
        })
      ),
    });
  return new Table({
    width: { size: anchoUtil, type: WidthType.DXA },
    columnWidths: anchos,
    layout: TableLayoutType.FIXED,
    rows: [fila(enc, true), ...filas.map((f) => fila(f, false))],
  });
}

// ------------------------------------------------------------ documento
function convertir(rutaMd, horizontal) {
  const md = fs.readFileSync(rutaMd, "utf8");
  const baseImg = path.dirname(rutaMd);
  const anchoPagina = horizontal ? ALTO_CARTA : ANCHO_CARTA;
  const anchoUtil = anchoPagina - 2 * MARGEN;
  const lineas = md.split("\n");
  const hijos = [];
  let titulo = "";
  let i = 0;
  const parrafo = (t, opts = {}) => hijos.push(new Paragraph({ spacing: { after: 120 }, ...opts, children: runs(t) }));

  while (i < lineas.length) {
    const l = lineas[i];
    if (!l.trim()) { i++; continue; }
    // bloques de código
    if (l.startsWith("```")) {
      const lenguaje = l.slice(3).trim();
      const bloque = [];
      i++;
      while (i < lineas.length && !lineas[i].startsWith("```")) bloque.push(lineas[i++]);
      i++;
      if (lenguaje === "mermaid") continue; // el diagrama se incluye como imagen
      bloque.forEach((b, k) =>
        hijos.push(new Paragraph({
          shading: { type: ShadingType.CLEAR, color: "auto", fill: GRIS_CODIGO },
          spacing: { before: k === 0 ? 60 : 0, after: k === bloque.length - 1 ? 160 : 0 },
          children: [new TextRun({ text: b.length ? b : " ", font: "Consolas", size: 16, color: NEGRO })],
        }))
      );
      continue;
    }
    // encabezados
    const h = l.match(/^(#{1,4}) (.*)$/);
    if (h) {
      const nivel = h[1].length;
      if (nivel === 1) {
        titulo = h[2];
        hijos.push(new Paragraph({ heading: HeadingLevel.TITLE, children: runs(h[2]) }));
      } else {
        const niveles = { 2: HeadingLevel.HEADING_1, 3: HeadingLevel.HEADING_2, 4: HeadingLevel.HEADING_3 };
        hijos.push(new Paragraph({ heading: niveles[nivel], children: runs(h[2]) }));
      }
      i++;
      continue;
    }
    // imágenes
    const img = l.match(/^!\[([^\]]*)\]\(([^)]+)\)/);
    if (img) {
      const ruta = path.join(baseImg, img[2]);
      const datos = fs.readFileSync(ruta);
      const ancho = datos.readUInt32BE(16);
      const alto = datos.readUInt32BE(20);
      const maxPx = Math.floor((anchoUtil / 1440) * 96);
      const w = Math.min(maxPx, ancho);
      hijos.push(new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [new ImageRun({ type: "png", data: datos, transformation: { width: w, height: Math.round((alto * w) / ancho) }, altText: { title: img[1], description: img[1], name: img[1] } })],
      }));
      hijos.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 200 }, children: runs(img[1], { italics: true, size: 18, color: GRIS_TEXTO }) }));
      i++;
      continue;
    }
    // la referencia a la fuente Mermaid no aplica en el documento
    if (l.startsWith("Fuente del diagrama (Mermaid")) { i++; continue; }
    // tablas
    if (l.startsWith("|")) {
      const bloque = [];
      while (i < lineas.length && lineas[i].startsWith("|")) bloque.push(lineas[i++]);
      hijos.push(tabla(bloque, anchoUtil));
      hijos.push(new Paragraph({ spacing: { after: 120 }, children: [] }));
      continue;
    }
    // listas (viñetas y numeradas, con un nivel de anidación)
    const li = l.match(/^(\s*)(-|\d+\.) (.*)$/);
    if (li) {
      const nivel = li[1].length >= 2 ? 1 : 0;
      const numerada = /\d+\./.test(li[2]);
      let texto = li[3];
      i++;
      while (i < lineas.length && lineas[i].trim() && !/^(\s*)(-|\d+\.) /.test(lineas[i]) && !lineas[i].startsWith("|") && !lineas[i].startsWith("#") && !lineas[i].startsWith("```")) {
        texto += " " + lineas[i].trim();
        i++;
      }
      hijos.push(new Paragraph({
        numbering: { reference: numerada ? "numeros" : "vinetas", level: nivel },
        spacing: { after: 60 },
        children: runs(texto),
      }));
      continue;
    }
    // párrafo normal (une líneas consecutivas)
    let texto = l.trim();
    i++;
    while (i < lineas.length && lineas[i].trim() && !/^(#|\||```|!\[|\s*(-|\d+\.) )/.test(lineas[i])) {
      texto += " " + lineas[i].trim();
      i++;
    }
    parrafo(texto);
  }

  const encabezado = (tam, antes, despues) => ({
    run: { font: FUENTE, size: tam, bold: true, color: NEGRO },
    paragraph: { spacing: { before: antes, after: despues }, keepNext: true, keepLines: true },
  });
  const doc = new Document({
    creator: "Equipo QATO'K",
    title: titulo,
    styles: {
      default: {
        document: { run: { font: FUENTE, size: 21, color: NEGRO } },
        title: { run: { font: FUENTE, size: 36, bold: true, color: NEGRO }, paragraph: { spacing: { before: 0, after: 240 }, keepNext: true } },
        heading1: encabezado(28, 320, 140),
        heading2: encabezado(24, 240, 120),
        heading3: encabezado(22, 200, 100),
        // estilos no usados de la plantilla, neutralizados para que el documento no contenga azul
        heading4: encabezado(21, 160, 80),
        heading5: encabezado(21, 160, 80),
        heading6: encabezado(21, 160, 80),
        hyperlink: { run: { color: NEGRO, underline: {} } },
      },
    },
    numbering: {
      config: [
        { reference: "vinetas", levels: [
          { level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 270 } } } },
          { level: 1, format: LevelFormat.BULLET, text: "–", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 1080, hanging: 270 } } } },
        ] },
        { reference: "numeros", levels: [
          { level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 360 } } } },
          { level: 1, format: LevelFormat.BULLET, text: "–", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 1080, hanging: 270 } } } },
        ] },
      ],
    },
    sections: [{
      properties: {
        page: {
          size: { width: ANCHO_CARTA, height: ALTO_CARTA, orientation: horizontal ? PageOrientation.LANDSCAPE : PageOrientation.PORTRAIT },
          margin: { top: MARGEN, bottom: MARGEN, left: MARGEN, right: MARGEN },
        },
      },
      footers: {
        default: new Footer({ children: [new Paragraph({ alignment: AlignmentType.RIGHT, children: [
          new TextRun({ text: "QATO'K · " + titulo + " · Página ", size: 16, color: GRIS_TEXTO }),
          new TextRun({ children: [PageNumber.CURRENT], size: 16, color: GRIS_TEXTO }),
        ] })] }),
      },
      children: hijos,
    }],
  });
  return Packer.toBuffer(doc);
}

(async () => {
  const args = process.argv.slice(2);
  if (args.length >= 2) {
    const buf = await convertir(path.resolve(args[0]), !args.includes("--vertical"));
    fs.writeFileSync(path.resolve(args[1]), buf);
    console.log("OK", args[1]);
    return;
  }
  fs.mkdirSync(DESTINO, { recursive: true });
  for (const e of ENTREGABLES) {
    const buf = await convertir(path.join(ORIGEN, e.md), e.horizontal);
    const salida = path.join(DESTINO, e.md.replace(/\.md$/, ".docx"));
    fs.writeFileSync(salida, buf);
    console.log("OK", path.relative(RAIZ, salida));
  }
})();
