var __getOwnPropNames = Object.getOwnPropertyNames;
var __commonJS = (cb, mod) => function __require() {
  return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
};
var __toBinary = /* @__PURE__ */ (() => {
  var table = new Uint8Array(128);
  for (var i = 0; i < 64; i++)
    table[i < 26 ? i + 65 : i < 52 ? i + 71 : i < 62 ? i - 4 : i * 4 - 205] = i;
  return (base64) => {
    var n = base64.length, bytes2 = new Uint8Array((n - (base64[n - 1] == "=") - (base64[n - 2] == "=")) * 3 / 4 | 0);
    for (var i2 = 0, j = 0; i2 < n; ) {
      var c0 = table[base64.charCodeAt(i2++)], c1 = table[base64.charCodeAt(i2++)];
      var c2 = table[base64.charCodeAt(i2++)], c3 = table[base64.charCodeAt(i2++)];
      bytes2[j++] = c0 << 2 | c1 >> 4;
      bytes2[j++] = c1 << 4 | c2 >> 2;
      bytes2[j++] = c2 << 6 | c3;
    }
    return bytes2;
  };
})();

// wasm-binary:./sha256.wat
var require_sha256 = __commonJS({
  "wasm-binary:./sha256.wat"(exports2, module2) {
    module2.exports = __toBinary("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");
  }
});

// wasm-module:./sha256.wat
var bytes = require_sha256();
var compiled = new WebAssembly.Module(bytes);
module.exports = (imports) => {
  const instance = new WebAssembly.Instance(compiled, imports);
  return instance.exports;
};
