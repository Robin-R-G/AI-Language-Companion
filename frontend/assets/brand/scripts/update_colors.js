const fs = require('fs');
const path = require('path');

const LOGO_SVG_DIR = path.resolve(__dirname, '..', 'logo', 'svg');
const GENERATE_ASSETS_FILE = path.resolve(__dirname, 'generate_assets.js');

// Helper to replace text in file
function replaceInFile(filePath, replacements) {
  if (!fs.existsSync(filePath)) {
    console.log(`File not found: ${filePath}`);
    return;
  }
  let content = fs.readFileSync(filePath, 'utf8');
  let original = content;
  
  for (const [target, replacement] of Object.entries(replacements)) {
    // Case-insensitive replacement
    const regex = new RegExp(target, 'gi');
    content = content.replace(regex, replacement);
  }
  
  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Updated colors in: ${filePath}`);
  } else {
    console.log(`No color changes needed in: ${filePath}`);
  }
}

function main() {
  const replacements = {
    '#4F46E5': '#2563EB', // Old Primary -> New Primary (Blue)
    '#4f46e5': '#2563EB',
    '#06B6D4': '#14B8A6', // Old Secondary (Teal) -> New Tertiary (Teal)
    '#06b6d4': '#14B8A6'
  };

  console.log('Replacing color codes in generation script and logo files...');

  // 1. Update generate_assets.js
  replaceInFile(GENERATE_ASSETS_FILE, replacements);

  // 2. Update existing logo SVGs
  if (fs.existsSync(LOGO_SVG_DIR)) {
    const files = fs.readdirSync(LOGO_SVG_DIR);
    for (const file of files) {
      if (file.endsWith('.svg')) {
        const filePath = path.join(LOGO_SVG_DIR, file);
        // Logo files might also need `#7C3AED` as secondary, which is already present
        replaceInFile(filePath, replacements);
      }
    }
  }

  console.log('Color code replacement completed successfully.');
}

main();
