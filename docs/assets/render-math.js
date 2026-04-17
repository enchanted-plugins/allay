// Render LaTeX equations to self-contained SVGs using MathJax.
//
// GitHub's mobile app renders images but not $$...$$ math. Every equation in
// README.md is pre-rendered here and referenced as an <img>. Re-run after
// editing any equation.
//
// Usage:
//   npm install --prefix . mathjax-full   # once
//   node render-math.js

const fs = require("fs");
const path = require("path");

const MJ_PATH = path.join(__dirname, "node_modules", "mathjax-full");
require(path.join(MJ_PATH, "js", "util", "asyncLoad", "node.js"));

const { mathjax } = require(path.join(MJ_PATH, "js", "mathjax.js"));
const { TeX } = require(path.join(MJ_PATH, "js", "input", "tex.js"));
const { SVG } = require(path.join(MJ_PATH, "js", "output", "svg.js"));
const { liteAdaptor } = require(path.join(MJ_PATH, "js", "adaptors", "liteAdaptor.js"));
const { RegisterHTMLHandler } = require(path.join(MJ_PATH, "js", "handlers", "html.js"));
const { AllPackages } = require(path.join(MJ_PATH, "js", "input", "tex", "AllPackages.js"));

const adaptor = liteAdaptor();
RegisterHTMLHandler(adaptor);

const tex = new TeX({ packages: AllPackages });
const svg = new SVG({ fontCache: "none" });
const html = mathjax.document("", { InputJax: tex, OutputJax: svg });

const FG = "#e6edf3";
const OUT = path.join(__dirname, "math");
fs.mkdirSync(OUT, { recursive: true });

const EQUATIONS = [
  ["a1-drift",
   String.raw`P(\text{drift} \mid s_1, \dots, s_n) = \begin{cases} 1 & \text{if } |\{\,s_i = s_j\,\}| \geq \theta \\ 0 & \text{otherwise} \end{cases}`],
  ["a2-runway",
   String.raw`\hat{R} = \dfrac{C_{\max} - \sum_{i=1}^{n} t_i}{\bar{t}_w} \qquad \mathrm{CI}_{95} = \hat{R} \,\pm\, 1.96 \cdot \dfrac{\sigma_t}{\bar{t}_w} \cdot \hat{R}`],
  ["a3-shannon",
   String.raw`H(O') \,\geq\, \theta \cdot H(O) \qquad \theta = \begin{cases} 1.0 & \text{code} \\ 0.7 & \text{tests} \\ 0.3 & \text{logs} \end{cases}`],
  ["a4-atomic",
   String.raw`\mathrm{write}(\mathit{tmp}) \;\longrightarrow\; \mathrm{validate}(\mathit{tmp}) \;\longrightarrow\; \mathrm{rename}(\mathit{tmp},\, \mathit{target})`],
  ["a5-dedup",
   String.raw`\mathrm{decision}(f) = \begin{cases} \mathrm{BLOCK} & h(f) = h_{\mathrm{cached}} \;\wedge\; \Delta t < \mathrm{TTL} \\ \mathrm{ALLOW} & \Delta t \geq \mathrm{TTL} \end{cases}`],
  ["a6-delta",
   String.raw`\mathrm{decision}(f) = \mathrm{DELTA} \qquad \text{when } h(f) \neq h_{\mathrm{cached}} \;\wedge\; \Delta t < \mathrm{TTL}`],
  ["a7-bayesian",
   String.raw`r_{\mathrm{new}} = \alpha \cdot s_{\mathrm{current}} + (1 - \alpha) \cdot r_{\mathrm{prior}} \qquad \alpha = 0.3`],
  ["a8-attribution",
   String.raw`\mathrm{attr}(c) = \begin{cases} s_{\mathrm{top}} & \exists\, s \in S : \mathrm{alive}(s.\mathit{pid}) \,\wedge\, (t - s.\mathit{start}) < \mathrm{TTL} \\ \texttt{"manual"} & \text{otherwise} \end{cases}`],
  ["a9-repoid",
   String.raw`\mathrm{repo\_id} = \mathrm{sha256}(c_0)_{[:12]} \qquad c_0 = \texttt{git rev-list --max-parents=0 HEAD}`],
  ["a9-unified",
   String.raw`\mathrm{unified\_session} = \bigcup_{w \in W} \mathrm{shards}(w) \qquad W = \mathrm{worktrees}(\mathrm{repo\_id})`],
];

function render(name, source) {
  const node = html.convert(source, { display: true, em: 16, ex: 8, containerWidth: 1200 });
  let svgStr = adaptor.innerHTML(node);
  svgStr = svgStr.replace(/currentColor/g, FG);
  svgStr = `<?xml version="1.0" encoding="UTF-8"?>\n` + svgStr;
  fs.writeFileSync(path.join(OUT, `${name}.svg`), svgStr, "utf8");
  console.log(`  docs/assets/math/${name}.svg`);
}

console.log(`Rendering ${EQUATIONS.length} equations...`);
for (const [name, src] of EQUATIONS) {
  try { render(name, src); } catch (err) {
    console.error(`FAILED: ${name}\n  ${err.message}`);
    process.exitCode = 1;
  }
}
console.log("Done.");
