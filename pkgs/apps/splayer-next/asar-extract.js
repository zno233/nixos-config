// 从 app.asar 提取文件，跳过头部标记 unpacked 的条目。
// 原因：electron-builder 会把全平台文件（darwin/win32/linux-arm64 等）标记为
// unpacked，但 .deb 只随包携带当前平台的部分，其余兄弟文件缺失，
// 导致 `asar extract` 直接崩溃。运行时这些文件不会被加载，跳过即可。
// 用官方 @electron/asar 库读取内容，避免手写偏移公式踩坑（v3/v4 头格式差异）。
const asar = require('@electron/asar');
const fs = require('fs');
const path = require('path');

const [, , asarPath, outDir] = process.argv;
const { header } = asar.getRawHeader(asarPath);

let count = 0;
let skipped = 0;

function walk(dir, prefix) {
  for (const [name, entry] of Object.entries(dir.files || {})) {
    const p = prefix + '/' + name;
    if (entry.files) {
      walk(entry, p);
    } else if (entry.unpacked) {
      skipped++;
    } else {
      const content = asar.extractFile(asarPath, p.slice(1));
      const dest = path.join(outDir, p);
      fs.mkdirSync(path.dirname(dest), { recursive: true });
      fs.writeFileSync(dest, content);
      count++;
    }
  }
}

walk(header, '');
console.error(`extracted ${count} files, skipped ${skipped} unpacked entries`);