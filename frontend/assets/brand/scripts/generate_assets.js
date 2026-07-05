const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const { optimize } = require('svgo');

// Paths
const BRAND_DIR = path.resolve(__dirname, '..');

// Helper to ensure directories exist
function ensureDirs(folderName) {
  const folderPath = path.join(BRAND_DIR, folderName);
  const svgDir = path.join(folderPath, 'svg');
  const pngDir = path.join(folderPath, 'png');
  const webpDir = path.join(folderPath, 'webp');
  
  fs.mkdirSync(svgDir, { recursive: true });
  fs.mkdirSync(pngDir, { recursive: true });
  fs.mkdirSync(webpDir, { recursive: true });
  
  return { svgDir, pngDir, webpDir };
}

// SVGO configuration for optimization
const svgoConfig = {
  plugins: [
    'preset-default',
    {
      name: 'removeViewBox',
      active: false,
    },
  ],
};

// Export to PNG (1x, 2x, 3x) and WebP
async function exportRaster(svgContent, name, { pngDir, webpDir }, width, height) {
  const buffer = Buffer.from(svgContent);
  
  // PNG 1x
  await sharp(buffer)
    .resize(width, height)
    .png()
    .toFile(path.join(pngDir, `${name}.png`));
    
  // PNG 2x
  await sharp(buffer)
    .resize(width * 2, height * 2)
    .png()
    .toFile(path.join(pngDir, `${name}@2x.png`));
    
  // PNG 3x
  await sharp(buffer)
    .resize(width * 3, height * 3)
    .png()
    .toFile(path.join(pngDir, `${name}@3x.png`));
    
  // WebP
  await sharp(buffer)
    .resize(width * 2, height * 2)
    .webp()
    .toFile(path.join(webpDir, `${name}.webp`));
}

// Generate an asset
async function saveAsset(folder, name, svgRaw, width = 64, height = 64) {
  const { svgDir, pngDir, webpDir } = ensureDirs(folder);
  
  // Optimize SVG
  const result = optimize(svgRaw, { path: path.join(svgDir, `${name}.svg`), ...svgoConfig });
  const svgOpt = result.data;
  
  // Save SVG
  fs.writeFileSync(path.join(svgDir, `${name}.svg`), svgOpt);
  
  // Save PNG and WebP
  await exportRaster(svgOpt, name, { pngDir, webpDir }, width, height);
}

// ==========================================
// 1. Existing Logo Suite Export
// ==========================================
async function exportExistingLogos() {
  console.log('Processing existing logo suite...');
  const logoFolder = ensureDirs('logo');
  const files = fs.readdirSync(logoFolder.svgDir);
  
  for (const file of files) {
    if (file.endsWith('.svg')) {
      const name = path.basename(file, '.svg');
      const svgContent = fs.readFileSync(path.join(logoFolder.svgDir, file), 'utf8');
      
      let width = 64, height = 64;
      if (name.includes('horizontal')) { width = 240; height = 64; }
      else if (name.includes('vertical')) { width = 120; height = 160; }
      else if (name.includes('full')) { width = 200; height = 200; }
      
      await exportRaster(svgContent, name, logoFolder, width, height);
    }
  }
}

// ==========================================
// 2. Splash Screen Illustration
// ==========================================
async function generateSplash() {
  console.log('Generating Splash Screen illustration...');
  const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 600" fill="none">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0F172A"/>
      <stop offset="50%" stop-color="#1E1B4B"/>
      <stop offset="100%" stop-color="#311042"/>
    </linearGradient>
    <linearGradient id="bubbleGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#2563EB"/>
      <stop offset="100%" stop-color="#14B8A6"/>
    </linearGradient>
    <linearGradient id="avatarGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#7C3AED"/>
      <stop offset="100%" stop-color="#EC4899"/>
    </linearGradient>
  </defs>
  <rect width="800" height="600" fill="url(#bgGrad)"/>
  
  <!-- Decorative background circles -->
  <circle cx="400" cy="300" r="280" stroke="#2563EB" stroke-width="1.5" stroke-dasharray="10 15" opacity="0.15"/>
  <circle cx="400" cy="300" r="200" stroke="#14B8A6" stroke-width="1" opacity="0.1"/>
  
  <!-- Learner (left side) -->
  <g transform="translate(180, 240)">
    <circle cx="60" cy="60" r="50" fill="url(#avatarGrad)" opacity="0.8"/>
    <circle cx="60" cy="60" r="50" stroke="#FFFFFF" stroke-width="2" fill="none"/>
    <!-- Head silhouette -->
    <path d="M45 45 C45 35, 75 35, 75 45 C75 55, 68 62, 60 62 C52 62, 45 55, 45 45 Z" fill="#FFFFFF"/>
    <!-- Voice waves -->
    <path d="M125 50 Q135 60, 125 70" stroke="#22C55E" stroke-width="3" stroke-linecap="round" fill="none"/>
    <path d="M135 40 Q150 60, 135 80" stroke="#22C55E" stroke-width="3" stroke-linecap="round" fill="none" opacity="0.7"/>
    <path d="M145 30 Q165 60, 145 90" stroke="#22C55E" stroke-width="3" stroke-linecap="round" fill="none" opacity="0.4"/>
  </g>
  
  <!-- AI Assistant (right side) -->
  <g transform="translate(470, 240)">
    <circle cx="60" cy="60" r="50" fill="url(#bubbleGrad)" opacity="0.8"/>
    <circle cx="60" cy="60" r="50" stroke="#FFFFFF" stroke-width="2" fill="none"/>
    <!-- Robot head -->
    <rect x="40" y="42" width="40" height="30" rx="6" fill="#FFFFFF"/>
    <ellipse cx="50" cy="57" rx="3" ry="3" fill="#2563EB"/>
    <ellipse cx="70" cy="57" rx="3" ry="3" fill="#2563EB"/>
    <path d="M53 72 L67 72" stroke="#2563EB" stroke-width="2" stroke-linecap="round"/>
    <path d="M60 30 L60 42" stroke="#FFFFFF" stroke-width="2"/>
    <circle cx="60" cy="28" r="3" fill="#14B8A6"/>
    <!-- Speaking waves -->
    <path d="M-5 50 Q-15 60, -5 70" stroke="#3B82F6" stroke-width="3" stroke-linecap="round" fill="none"/>
    <path d="M-15 40 Q-30 60, -15 80" stroke="#3B82F6" stroke-width="3" stroke-linecap="round" fill="none" opacity="0.7"/>
    <path d="M-25 30 Q-45 60, -25 90" stroke="#3B82F6" stroke-width="3" stroke-linecap="round" fill="none" opacity="0.4"/>
  </g>
  
  <!-- Language clouds floats -->
  <g transform="translate(140, 120)" opacity="0.85">
    <rect width="70" height="35" rx="10" fill="#1E293B" stroke="#475569" stroke-width="1.5"/>
    <text x="35" y="22" font-family="Inter, sans-serif" font-size="14" font-weight="bold" fill="#F8FAFC" text-anchor="middle">English</text>
  </g>
  <g transform="translate(580, 140)" opacity="0.85">
    <rect width="80" height="35" rx="10" fill="#1E293B" stroke="#475569" stroke-width="1.5"/>
    <text x="40" y="22" font-family="Inter, sans-serif" font-size="14" font-weight="bold" fill="#F8FAFC" text-anchor="middle">German</text>
  </g>
  <g transform="translate(360, 60)" opacity="0.85">
    <rect width="80" height="35" rx="10" fill="#1E293B" stroke="#475569" stroke-width="1.5"/>
    <text x="40" y="22" font-family="Inter, sans-serif" font-size="14" font-weight="bold" fill="#F8FAFC" text-anchor="middle">Japanese</text>
  </g>
  <g transform="translate(250, 480)" opacity="0.85">
    <rect width="70" height="35" rx="10" fill="#1E293B" stroke="#475569" stroke-width="1.5"/>
    <text x="35" y="22" font-family="Inter, sans-serif" font-size="14" font-weight="bold" fill="#F8FAFC" text-anchor="middle">French</text>
  </g>
  <g transform="translate(480, 460)" opacity="0.85">
    <rect width="80" height="35" rx="10" fill="#1E293B" stroke="#475569" stroke-width="1.5"/>
    <text x="40" y="22" font-family="Inter, sans-serif" font-size="14" font-weight="bold" fill="#F8FAFC" text-anchor="middle">Spanish</text>
  </g>
</svg>
`;
  await saveAsset('splash', 'splash_illustration', svg, 800, 600);
}

// ==========================================
// 3. Onboarding Illustrations (4 Screens)
// ==========================================
async function generateOnboarding() {
  console.log('Generating Onboarding illustrations...');
  const screens = {
    'onboarding_1': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300" fill="none">
  <rect width="400" height="300" rx="16" fill="#F8FAFC"/>
  <!-- AI Teacher welcomes user -->
  <circle cx="200" cy="150" r="90" fill="#2563EB" opacity="0.1"/>
  <circle cx="200" cy="150" r="70" fill="#2563EB" opacity="0.2"/>
  <!-- AI character -->
  <g transform="translate(160, 110)">
    <rect x="15" y="20" width="50" height="40" rx="10" fill="#2563EB"/>
    <circle cx="30" cy="40" r="4" fill="#FFFFFF"/>
    <circle cx="50" cy="40" r="4" fill="#FFFFFF"/>
    <path d="M35 50 Q40 55, 45 50" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/>
    <path d="M40 8 L40 20" stroke="#2563EB" stroke-width="2"/>
    <circle cx="40" cy="6" r="3" fill="#14B8A6"/>
    <!-- Waving hand -->
    <path d="M72 45 C78 40, 82 45, 80 50 L68 55" stroke="#2563EB" stroke-width="4" stroke-linecap="round"/>
  </g>
</svg>
`,
    'onboarding_2': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300" fill="none">
  <rect width="400" height="300" rx="16" fill="#F8FAFC"/>
  <!-- Voice Conversation waves -->
  <circle cx="200" cy="150" r="80" fill="#14B8A6" opacity="0.1"/>
  <g transform="translate(120, 135)">
    <!-- Central wave lines -->
    <rect x="10" y="10" width="10" height="30" rx="5" fill="#2563EB"/>
    <rect x="30" y="0" width="10" height="50" rx="5" fill="#14B8A6"/>
    <rect x="50" y="20" width="10" height="20" rx="5" fill="#7C3AED"/>
    <rect x="70" y="5" width="10" height="40" rx="5" fill="#22C55E"/>
    <rect x="90" y="15" width="10" height="25" rx="5" fill="#2563EB"/>
    <rect x="110" y="0" width="10" height="50" rx="5" fill="#14B8A6"/>
    <rect x="130" y="10" width="10" height="30" rx="5" fill="#7C3AED"/>
    <rect x="150" y="20" width="10" height="15" rx="5" fill="#22C55E"/>
  </g>
</svg>
`,
    'onboarding_3': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300" fill="none">
  <rect width="400" height="300" rx="16" fill="#F8FAFC"/>
  <!-- Vocabulary learning -->
  <circle cx="200" cy="150" r="80" fill="#7C3AED" opacity="0.1"/>
  <!-- Card shapes representing flip -->
  <g transform="translate(110, 80)">
    <rect x="0" y="10" width="160" height="120" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="2"/>
    <rect x="20" y="-10" width="160" height="120" rx="12" fill="#7C3AED" opacity="0.9"/>
    <!-- Word on card -->
    <text x="100" y="45" font-family="Inter, sans-serif" font-size="20" font-weight="bold" fill="#FFFFFF" text-anchor="middle">Confidence</text>
    <text x="100" y="80" font-family="Inter, sans-serif" font-size="12" fill="#F3E8FF" text-anchor="middle">/ˈkɒnfɪdəns/</text>
  </g>
</svg>
`,
    'onboarding_4': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300" fill="none">
  <rect width="400" height="300" rx="16" fill="#F8FAFC"/>
  <!-- Exam Preparation -->
  <circle cx="200" cy="150" r="80" fill="#22C55E" opacity="0.1"/>
  <g transform="translate(140, 90)">
    <!-- Academic Cap -->
    <path d="M60 10 L110 30 L60 50 L10 30 Z" fill="#0F172A"/>
    <path d="M25 37 L25 70 Q60 85, 95 70 L95 37" fill="#1E293B"/>
    <path d="M100 35 L100 65" stroke="#E2E8F0" stroke-width="2"/>
    <circle cx="100" cy="65" r="4" fill="#14B8A6"/>
    <!-- Score target -->
    <rect x="20" y="80" width="80" height="30" rx="8" fill="#22C55E"/>
    <text x="60" y="100" font-family="Inter, sans-serif" font-size="14" font-weight="bold" fill="#FFFFFF" text-anchor="middle">IELTS 8.0</text>
  </g>
</svg>
`
  };
  
  for (const [name, content] of Object.entries(screens)) {
    await saveAsset('onboarding', name, content, 400, 300);
  }
}

// ==========================================
// 4. Empty State Illustrations (8 States)
// ==========================================
async function generateEmptyStates() {
  console.log('Generating Empty State illustrations...');
  const states = {
    'no_lessons': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none">
  <circle cx="100" cy="100" r="70" fill="#2563EB" opacity="0.05"/>
  <path d="M60 70 H140 V130 C140 135, 135 140, 130 140 H70 C65 140, 60 135, 60 130 Z" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
  <path d="M60 70 L100 95 L140 70" stroke="#CBD5E1" stroke-width="2" fill="none"/>
  <circle cx="100" cy="115" r="15" fill="#2563EB" opacity="0.2"/>
  <text x="100" y="119" font-family="Inter, sans-serif" font-size="12" font-weight="bold" fill="#2563EB" text-anchor="middle">?</text>
</svg>
`,
    'no_vocabulary': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none">
  <circle cx="100" cy="100" r="70" fill="#22C55E" opacity="0.05"/>
  <rect x="70" y="60" width="60" height="80" rx="8" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
  <line x1="80" y1="80" x2="120" y2="80" stroke="#E2E8F0" stroke-width="2"/>
  <line x1="80" y1="100" x2="110" y2="100" stroke="#E2E8F0" stroke-width="2"/>
  <line x1="80" y1="120" x2="100" y2="120" stroke="#E2E8F0" stroke-width="2"/>
  <circle cx="120" cy="130" r="16" fill="#22C55E" opacity="0.2"/>
</svg>
`,
    'no_internet': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none">
  <circle cx="100" cy="100" r="70" fill="#EF4444" opacity="0.05"/>
  <!-- WiFi muted -->
  <path d="M60 80 Q100 40, 140 80" stroke="#CBD5E1" stroke-width="3" stroke-linecap="round" fill="none"/>
  <path d="M75 95 Q100 65, 125 95" stroke="#CBD5E1" stroke-width="3" stroke-linecap="round" fill="none"/>
  <circle cx="100" cy="130" r="6" fill="#CBD5E1"/>
  <!-- Slash -->
  <line x1="50" y1="140" x2="150" y2="60" stroke="#EF4444" stroke-width="4" stroke-linecap="round"/>
</svg>
`,
    'no_notifications': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none">
  <circle cx="100" cy="100" r="70" fill="#F59E0B" opacity="0.05"/>
  <!-- Quiet Bell -->
  <path d="M100 50 C85 50, 80 65, 80 80 L75 120 H125 L120 120 C120 65, 115 50, 100 50 Z" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
  <path d="M90 120 Q100 135, 110 120" stroke="#CBD5E1" stroke-width="2" fill="none"/>
  <circle cx="100" cy="45" r="4" fill="#CBD5E1"/>
</svg>
`,
    'no_chat_history': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none">
  <circle cx="100" cy="100" r="70" fill="#14B8A6" opacity="0.05"/>
  <!-- Chat bubbles -->
  <path d="M55 90 C55 75, 70 65, 90 65 C110 65, 125 75, 125 90 C125 105, 110 115, 90 115 H80 L65 125 L70 115 C55 110, 55 100, 55 90 Z" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
  <circle cx="80" cy="90" r="3" fill="#E2E8F0"/>
  <circle cx="90" cy="90" r="3" fill="#E2E8F0"/>
  <circle cx="100" cy="90" r="3" fill="#E2E8F0"/>
</svg>
`,
    'no_progress': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none">
  <circle cx="100" cy="100" r="70" fill="#7C3AED" opacity="0.05"/>
  <!-- Flat bar chart -->
  <line x1="50" y1="140" x2="150" y2="140" stroke="#CBD5E1" stroke-width="2"/>
  <rect x="60" y="110" width="15" height="30" rx="3" fill="#E2E8F0"/>
  <rect x="90" y="80" width="15" height="60" rx="3" fill="#E2E8F0"/>
  <rect x="120" y="130" width="15" height="10" rx="3" fill="#E2E8F0"/>
</svg>
`,
    'no_exam_history': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none">
  <circle cx="100" cy="100" r="70" fill="#3B82F6" opacity="0.05"/>
  <!-- Test sheets -->
  <rect x="60" y="60" width="65" height="85" rx="5" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>
  <rect x="75" y="50" width="65" height="85" rx="5" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="2" opacity="0.8"/>
  <circle cx="110" cy="95" r="18" fill="#3B82F6" opacity="0.15"/>
</svg>
`,
    'no_downloads': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none">
  <circle cx="100" cy="100" r="70" fill="#0F172A" opacity="0.05"/>
  <!-- Arrow pointing down -->
  <path d="M100 50 L100 120 M85 105 L100 120 L115 105" stroke="#CBD5E1" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
  <path d="M70 140 H130" stroke="#CBD5E1" stroke-width="2" stroke-linecap="round"/>
</svg>
`
  };
  
  for (const [name, content] of Object.entries(states)) {
    await saveAsset('empty-states', name, content, 200, 200);
  }
}

// ==========================================
// 5. Achievement Badges (15 Badges, 3 Tiers each)
// ==========================================
async function generateBadges() {
  console.log('Generating Achievement badges...');
  const badgeTypes = [
    'first_lesson', 'streak_7', 'streak_30', 'words_100', 'words_500', 'words_1000',
    'grammar_master', 'pronunciation_expert', 'speaking_champion', 'writing_expert',
    'reading_hero', 'listening_hero', 'ielts_ready', 'goethe_ready', 'toefl_ready'
  ];
  
  const tiers = {
    'gold': { fill: '#F59E0B', glow: '#FEF3C7', label: 'Gold' },
    'silver': { fill: '#94A3B8', glow: '#F1F5F9', label: 'Silver' },
    'bronze': { fill: '#B45309', glow: '#FFEDD5', label: 'Bronze' }
  };
  
  for (const bType of badgeTypes) {
    for (const [tier, props] of Object.entries(tiers)) {
      const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80" fill="none">
  <defs>
    <linearGradient id="shieldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="${props.fill}"/>
      <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0.3"/>
    </linearGradient>
  </defs>
  <!-- Shield Badge Base -->
  <path d="M40 5 L70 20 L70 50 C70 65, 55 75, 40 78 C25 75, 10 65, 10 50 L10 20 Z" fill="url(#shieldGrad)" stroke="${props.fill}" stroke-width="2"/>
  <!-- Inner Glow circle -->
  <circle cx="40" cy="40" r="22" fill="${props.glow}" opacity="0.6"/>
  <!-- Star icon inside -->
  <path d="M40 28 L43 37 L52 37 L45 42 L48 51 L40 45 L32 51 L35 42 L28 37 L37 37 Z" fill="${props.fill}"/>
  <!-- Small bottom tag -->
  <rect x="25" y="58" width="30" height="10" rx="3" fill="#1E293B"/>
  <text x="40" y="66" font-family="Inter, sans-serif" font-size="7" font-weight="bold" fill="#FFFFFF" text-anchor="middle">${props.label}</text>
</svg>
`;
      await saveAsset('badges', `${bType}_${tier}`, svg, 80, 80);
    }
  }
}

// ==========================================
// 6. XP Icons (10 Levels/Styles)
// ==========================================
async function generateXPIcons() {
  console.log('Generating XP icons...');
  const colors = [
    '#64748B', '#475569', '#3B82F6', '#2563EB', '#10B981',
    '#059669', '#8B5CF6', '#7C3AED', '#EC4899', '#D946EF'
  ];
  
  for (let i = 0; i < 10; i++) {
    const levelStart = i * 10 + 1;
    const levelEnd = (i + 1) * 10;
    const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <rect width="64" height="64" rx="16" fill="${colors[i]}" opacity="0.1"/>
  <!-- Hexagon border -->
  <polygon points="32,8 52,20 52,44 32,56 12,44 12,20" stroke="${colors[i]}" stroke-width="3" fill="none"/>
  <!-- Inner bolt -->
  <path d="M34 16 L22 34 H32 L30 48 L42 30 H32 Z" fill="${colors[i]}"/>
  <!-- Level text -->
  <rect x="12" y="44" width="40" height="14" rx="4" fill="#0F172A"/>
  <text x="32" y="54" font-family="Inter, sans-serif" font-size="8" font-weight="bold" fill="#FFFFFF" text-anchor="middle">LVL ${levelStart}-${levelEnd}</text>
</svg>
`;
    await saveAsset('xp-levels', `xp_level_${levelStart}_${levelEnd}`, svg, 64, 64);
  }
}

// ==========================================
// 7. Avatar Library (120 Unique Avatars)
// ==========================================
async function generateAvatars() {
  console.log('Generating Avatar Library (120 combinatorially unique avatars)...');
  
  const skins = ['#FFD8B3', '#F2C199', '#C68E65', '#8A5229'];
  const hairColors = ['#1A1A1A', '#5C4033', '#C5A059', '#A52A2A', '#708090'];
  const shirtColors = ['#2563EB', '#14B8A6', '#22C55E', '#EC4899', '#F59E0B', '#7C3AED'];
  
  // Dynamic hair paths
  const hairStyles = [
    // Style 0: Short/Spiky
    (hc) => `<path d="M12 24 C10 12, 54 12, 52 24 C50 20, 14 20, 12 24 Z" fill="${hc}"/>`,
    // Style 1: Curly/Afro
    (hc) => `
      <circle cx="20" cy="18" r="8" fill="${hc}"/>
      <circle cx="32" cy="14" r="9" fill="${hc}"/>
      <circle cx="44" cy="18" r="8" fill="${hc}"/>
      <circle cx="16" cy="26" r="7" fill="${hc}"/>
      <circle cx="48" cy="26" r="7" fill="${hc}"/>
    `,
    // Style 2: Bob/Flat
    (hc) => `<path d="M14 24 C14 10, 50 10, 50 24 V34 H44 V26 H20 V34 H14 Z" fill="${hc}"/>`,
    // Style 3: Long Ponytail
    (hc) => `
      <path d="M16 24 C16 12, 48 12, 48 24 C48 18, 16 18, 16 24 Z" fill="${hc}"/>
      <path d="M44 24 Q56 34, 48 44 C44 44, 42 36, 44 24 Z" fill="${hc}"/>
    `,
    // Style 4: Cap
    (hc) => `<path d="M14 24 C18 14, 46 14, 50 24 L56 26 L48 20 Z" fill="#0F172A"/>`
  ];
  
  let count = 0;
  for (let sIdx = 0; sIdx < skins.length; sIdx++) {
    for (let hcIdx = 0; hcIdx < hairColors.length; hcIdx++) {
      for (let shIdx = 0; shIdx < shirtColors.length; shIdx++) {
        for (let hsIdx = 0; hsIdx < hairStyles.length; hsIdx++) {
          if (count >= 120) break;
          
          const skin = skins[sIdx];
          const hc = hairColors[hcIdx];
          const sc = shirtColors[shIdx];
          const hairDraw = hairStyles[hsIdx](hc);
          
          const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <!-- Circle clip path backdrop -->
  <circle cx="32" cy="32" r="30" fill="#F1F5F9"/>
  <circle cx="32" cy="32" r="30" stroke="#CBD5E1" stroke-width="1.5" fill="none"/>
  
  <g clip-path="url(#circleClip)">
    <clipPath id="circleClip">
      <circle cx="32" cy="32" r="29"/>
    </clipPath>
    
    <!-- Shoulders/Shirt -->
    <path d="M12 56 C12 46, 20 42, 32 42 C44 42, 52 46, 52 56 Z" fill="${sc}"/>
    <!-- Neck -->
    <rect x="28" y="38" width="8" height="8" fill="${skin}"/>
    <!-- Head -->
    <circle cx="32" cy="27" r="13" fill="${skin}"/>
    <!-- Hair -->
    ${hairDraw}
    <!-- Eyes -->
    <circle cx="28" cy="26" r="1.5" fill="#1E293B"/>
    <circle cx="36" cy="26" r="1.5" fill="#1E293B"/>
    <!-- Smile -->
    <path d="M29 32 Q32 35, 35 32" stroke="#1E293B" stroke-width="1.5" stroke-linecap="round"/>
  </g>
</svg>
`;
          count++;
          await saveAsset('avatars', `avatar_${count}`, svg, 64, 64);
        }
      }
    }
  }
}

// ==========================================
// 8. AI Assistant Avatar (Front/Side + States)
// ==========================================
async function generateAIAssistant() {
  console.log('Generating AI Assistant avatar states...');
  const states = {
    // Front Idle
    'assistant_front_idle': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <circle cx="32" cy="32" r="30" fill="#2563EB" opacity="0.1"/>
  <circle cx="32" cy="32" r="30" stroke="#2563EB" stroke-width="2" fill="none"/>
  <rect x="18" y="20" width="28" height="22" rx="6" fill="#2563EB"/>
  <circle cx="26" cy="30" r="2" fill="#FFFFFF"/>
  <circle cx="38" cy="30" r="2" fill="#FFFFFF"/>
  <path d="M28 36 L36 36" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/>
</svg>
`,
    // Front Talking
    'assistant_front_talking': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <circle cx="32" cy="32" r="30" fill="#2563EB" opacity="0.1"/>
  <circle cx="32" cy="32" r="30" stroke="#2563EB" stroke-width="2" fill="none"/>
  <rect x="18" y="20" width="28" height="22" rx="6" fill="#2563EB"/>
  <circle cx="26" cy="30" r="2" fill="#14B8A6"/>
  <circle cx="38" cy="30" r="2" fill="#14B8A6"/>
  <ellipse cx="32" cy="36" rx="4" ry="2" fill="#FFFFFF"/>
</svg>
`,
    // Front Listening
    'assistant_front_listening': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <circle cx="32" cy="32" r="30" fill="#22C55E" opacity="0.1"/>
  <circle cx="32" cy="32" r="30" stroke="#22C55E" stroke-width="2" fill="none"/>
  <rect x="18" y="20" width="28" height="22" rx="6" fill="#2563EB"/>
  <circle cx="26" cy="30" r="2.5" fill="#22C55E"/>
  <circle cx="38" cy="30" r="2.5" fill="#22C55E"/>
  <path d="M28 36 Q32 39, 36 36" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" fill="none"/>
</svg>
`,
    // Front Thinking
    'assistant_front_thinking': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <circle cx="32" cy="32" r="30" fill="#F59E0B" opacity="0.1"/>
  <circle cx="32" cy="32" r="30" stroke="#F59E0B" stroke-width="2" fill="none"/>
  <rect x="18" y="20" width="28" height="22" rx="6" fill="#2563EB"/>
  <circle cx="25" cy="28" r="2" fill="#FFFFFF"/>
  <circle cx="37" cy="28" r="2" fill="#FFFFFF"/>
  <path d="M28 36 Q32 32, 36 36" stroke="#FFFFFF" stroke-width="1.5" stroke-linecap="round" fill="none"/>
</svg>
`,
    // Side Idle
    'assistant_side_idle': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <circle cx="32" cy="32" r="30" fill="#2563EB" opacity="0.1"/>
  <rect x="22" y="20" width="20" height="22" rx="6" fill="#2563EB"/>
  <circle cx="34" cy="30" r="2" fill="#FFFFFF"/>
  <path d="M30 36 L36 36" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/>
</svg>
`
  };
  
  for (const [name, content] of Object.entries(states)) {
    await saveAsset('ai-assistant', name, content, 64, 64);
  }
}

// ==========================================
// 9. Exam Icons (16 Icons)
// ==========================================
async function generateExamIcons() {
  console.log('Generating Exam icons...');
  const exams = [
    'ielts', 'toefl', 'pte', 'oet', 'celpip', 'cambridge',
    'goethe', 'testdaf', 'delf', 'dalf', 'dele', 'siele',
    'jlpt', 'topik', 'hsk', 'duolingo'
  ];
  
  for (const exam of exams) {
    const label = exam.toUpperCase();
    const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <rect width="64" height="64" rx="16" fill="#1E293B"/>
  <rect x="4" y="4" width="56" height="56" rx="12" stroke="#2563EB" stroke-width="2" fill="none"/>
  <text x="32" y="38" font-family="Inter, sans-serif" font-size="10" font-weight="bold" fill="#14B8A6" text-anchor="middle">${label}</text>
</svg>
`;
    await saveAsset('exam-icons', `exam_${exam}`, svg, 64, 64);
  }
}

// ==========================================
// 10. Language Icons (12 Flag Circles)
// ==========================================
async function generateLanguageIcons() {
  console.log('Generating Language icons...');
  const langs = {
    'english': '#3B82F6', 'german': '#F59E0B', 'french': '#EF4444',
    'spanish': '#F97316', 'japanese': '#FFFFFF', 'korean': '#EC4899',
    'chinese': '#DC2626', 'malayalam': '#059669', 'hindi': '#EA580C',
    'arabic': '#16A34A', 'italian': '#22C55E', 'portuguese': '#047857'
  };
  
  for (const [lang, color] of Object.entries(langs)) {
    const code = lang.substring(0, 2).toUpperCase();
    const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <circle cx="32" cy="32" r="28" fill="${color}"/>
  <circle cx="32" cy="32" r="28" stroke="#E2E8F0" stroke-width="2" fill="none"/>
  <text x="32" y="38" font-family="Inter, sans-serif" font-size="16" font-weight="bold" fill="#0F172A" text-anchor="middle">${code}</text>
</svg>
`;
    await saveAsset('language-icons', `lang_${lang}`, svg, 64, 64);
  }
}

// ==========================================
// 11. Category Icons (20 Icons)
// ==========================================
async function generateCategoryIcons() {
  console.log('Generating Category icons...');
  const categories = [
    'vocabulary', 'grammar', 'speaking', 'writing', 'reading',
    'listening', 'translation', 'flashcards', 'ai_tutor', 'live_class',
    'voice_call', 'progress', 'leaderboard', 'calendar', 'settings',
    'profile', 'subscription', 'downloads', 'bookmarks', 'history'
  ];
  
  for (const cat of categories) {
    const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <rect width="64" height="64" rx="16" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1.5"/>
  <!-- Central shape -->
  <circle cx="32" cy="32" r="16" fill="#2563EB" opacity="0.1"/>
  <circle cx="32" cy="32" r="8" fill="#2563EB"/>
</svg>
`;
    await saveAsset('category-icons', `cat_${cat}`, svg, 64, 64);
  }
}

// ==========================================
// 12. Notification Icons (6 Icons)
// ==========================================
async function generateNotificationIcons() {
  console.log('Generating Notification icons...');
  const notifications = [
    'lesson_reminder', 'practice_reminder', 'streak_reminder',
    'subscription', 'achievement', 'exam_reminder'
  ];
  
  for (const notif of notifications) {
    const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <circle cx="32" cy="32" r="28" fill="#1E293B"/>
  <!-- Outer notification glow circle -->
  <circle cx="48" cy="16" r="6" fill="#EF4444"/>
  <text x="32" y="38" font-family="Inter, sans-serif" font-size="10" font-weight="bold" fill="#FFFFFF" text-anchor="middle">🔔</text>
</svg>
`;
    await saveAsset('notification-icons', `notif_${notif}`, svg, 64, 64);
  }
}

// ==========================================
// 13. Completion Certificates
// ==========================================
async function generateCertificates() {
  console.log('Generating Completion Certificates (Landscape, dual themes)...');
  const themes = {
    'certificate_light': { bg: '#FFFFFF', border: '#2563EB', text: '#0F172A', secondary: '#475569' },
    'certificate_dark': { bg: '#0F172A', border: '#14B8A6', text: '#F8FAFC', secondary: '#94A3B8' }
  };
  
  for (const [theme, props] of Object.entries(themes)) {
    const svg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 842 595" fill="none">
  <!-- Certificate border base -->
  <rect width="842" height="595" fill="${props.bg}"/>
  <rect x="20" y="20" width="802" height="555" stroke="${props.border}" stroke-width="8" fill="none"/>
  <rect x="35" y="35" width="772" height="525" stroke="${props.border}" stroke-width="2" stroke-dasharray="10 15" fill="none" opacity="0.6"/>
  
  <!-- Content -->
  <text x="421" y="140" font-family="Inter, sans-serif" font-size="42" font-weight="bold" fill="${props.text}" text-anchor="middle">CERTIFICATE OF COMPLETION</text>
  <text x="421" y="200" font-family="Inter, sans-serif" font-size="18" fill="${props.secondary}" text-anchor="middle">This is proudly presented to</text>
  
  <!-- Candidate Name -->
  <line x1="200" y1="290" x2="642" y2="290" stroke="${props.secondary}" stroke-width="2"/>
  <text x="421" y="275" font-family="Inter, sans-serif" font-size="32" font-weight="bold" fill="${props.text}" text-anchor="middle">John Doe</text>
  
  <!-- Reason -->
  <text x="421" y="340" font-family="Inter, sans-serif" font-size="16" fill="${props.secondary}" text-anchor="middle">for successfully mastering the curriculum of</text>
  <text x="421" y="380" font-family="Inter, sans-serif" font-size="24" font-weight="bold" fill="${props.border}" text-anchor="middle">AI Language Coach - IELTS Preparation</text>
  
  <!-- QR Code verification placeholder -->
  <g transform="translate(100, 430)">
    <rect width="80" height="80" fill="${props.text}"/>
    <rect x="10" y="10" width="60" height="60" fill="${props.bg}"/>
    <rect x="20" y="20" width="40" height="40" fill="${props.text}"/>
  </g>
  
  <!-- Signatures -->
  <g transform="translate(540, 480)">
    <line x1="0" y1="0" x2="200" y2="0" stroke="${props.secondary}" stroke-width="1.5"/>
    <text x="100" y="20" font-family="Inter, sans-serif" font-size="12" fill="${props.secondary}" text-anchor="middle">Authorized Signature</text>
  </g>
</svg>
`;
    await saveAsset('certificates', theme, svg, 842, 595);
  }
}

// ==========================================
// 14. Mascot Emotions (5 Mascot SVGs)
// ==========================================
async function generateMascot() {
  console.log('Generating Mascot emotions...');
  const emotions = {
    'mascot_happy': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none">
  <!-- Body circle -->
  <circle cx="50" cy="50" r="30" fill="#2563EB"/>
  <!-- Eyes -->
  <ellipse cx="40" cy="45" rx="4" ry="6" fill="#FFFFFF"/>
  <ellipse cx="60" cy="45" rx="4" ry="6" fill="#FFFFFF"/>
  <ellipse cx="40" cy="45" rx="2" ry="3" fill="#14B8A6"/>
  <ellipse cx="60" cy="45" rx="2" ry="3" fill="#14B8A6"/>
  <!-- Happy mouth -->
  <path d="M40 60 Q50 70, 60 60" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" fill="none"/>
  <!-- Antenna -->
  <line x1="50" y1="20" x2="50" y2="10" stroke="#2563EB" stroke-width="3"/>
  <circle cx="50" cy="8" r="4" fill="#14B8A6"/>
</svg>
`,
    'mascot_thinking': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none">
  <circle cx="50" cy="50" r="30" fill="#2563EB"/>
  <ellipse cx="40" cy="45" rx="4" ry="4" fill="#FFFFFF"/>
  <ellipse cx="60" cy="45" rx="4" ry="4" fill="#FFFFFF"/>
  <!-- Thinking eyes/look up -->
  <circle cx="42" cy="43" r="2" fill="#F59E0B"/>
  <circle cx="62" cy="43" r="2" fill="#F59E0B"/>
  <!-- Straight mouth -->
  <line x1="42" y1="62" x2="58" y2="62" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round"/>
</svg>
`,
    'mascot_celebrating': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none">
  <circle cx="50" cy="50" r="30" fill="#7C3AED"/>
  <!-- Winking eyes -->
  <path d="M35 45 Q40 40, 45 45" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" fill="none"/>
  <path d="M55 45 Q60 40, 65 45" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" fill="none"/>
  <!-- Open mouth -->
  <circle cx="50" cy="62" r="5" fill="#FFFFFF"/>
</svg>
`,
    'mascot_listening': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none">
  <circle cx="50" cy="50" r="30" fill="#22C55E"/>
  <circle cx="40" cy="45" r="4" fill="#FFFFFF"/>
  <circle cx="60" cy="45" r="4" fill="#FFFFFF"/>
  <!-- Ears details/headphones -->
  <rect x="15" y="40" width="8" height="20" rx="4" fill="#0F172A"/>
  <rect x="77" y="40" width="8" height="20" rx="4" fill="#0F172A"/>
  <path d="M20 40 A30 30 0 0 1 80 40" stroke="#0F172A" stroke-width="3" fill="none"/>
</svg>
`,
    'mascot_teaching': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none">
  <circle cx="50" cy="50" r="30" fill="#2563EB"/>
  <circle cx="40" cy="45" r="4" fill="#FFFFFF"/>
  <circle cx="60" cy="45" r="4" fill="#FFFFFF"/>
  <!-- Glasses -->
  <rect x="33" y="40" width="14" height="10" rx="2" stroke="#FFFFFF" stroke-width="2" fill="none"/>
  <rect x="53" y="40" width="14" height="10" rx="2" stroke="#FFFFFF" stroke-width="2" fill="none"/>
  <line x1="47" y1="45" x2="53" y2="45" stroke="#FFFFFF" stroke-width="2"/>
</svg>
`
  };
  
  for (const [name, content] of Object.entries(emotions)) {
    await saveAsset('mascot', name, content, 100, 100);
  }
}

// ==========================================
// 15. Lottie/Wave Placeholder animations
// ==========================================
async function generateAnimations() {
  console.log('Generating Animation SVGs and assets...');
  
  const anims = {
    'lottie_loading': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none">
  <circle cx="50" cy="50" r="35" stroke="#CBD5E1" stroke-width="8" fill="none"/>
  <circle cx="50" cy="50" r="35" stroke="#2563EB" stroke-width="8" stroke-dasharray="80 200" fill="none"/>
</svg>
`,
    'lottie_typing': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none">
  <circle cx="25" cy="50" r="6" fill="#2563EB"/>
  <circle cx="50" cy="50" r="6" fill="#2563EB" opacity="0.6"/>
  <circle cx="75" cy="50" r="6" fill="#2563EB" opacity="0.3"/>
</svg>
`,
    'wave_speaking': `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 64" fill="none">
  <path d="M10 32 Q30 10, 50 32 T90 32 T130 32 T170 32" stroke="#22C55E" stroke-width="3" stroke-linecap="round" fill="none"/>
</svg>
`
  };
  
  for (const [name, content] of Object.entries(anims)) {
    await saveAsset('animations', name, content, 100, 100);
  }
}

// ==========================================
// 16. Marketing Assets (Mockups/Banners)
// ==========================================
async function generateMarketing() {
  console.log('Generating Marketing assets...');
  const banner = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 500" fill="none">
  <defs>
    <linearGradient id="mktGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#2563EB"/>
      <stop offset="100%" stop-color="#7C3AED"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="500" fill="url(#mktGrad)"/>
  <circle cx="800" cy="250" r="300" fill="#14B8A6" opacity="0.2"/>
  
  <text x="80" y="200" font-family="Inter, sans-serif" font-size="48" font-weight="bold" fill="#FFFFFF">AI Language Coach</text>
  <text x="80" y="260" font-family="Inter, sans-serif" font-size="24" fill="#E2E8F0">Master spoken and written language skills.</text>
  
  <!-- Play Store Badge Mockup -->
  <rect x="80" y="320" width="180" height="54" rx="10" fill="#0F172A" stroke="#475569" stroke-width="2"/>
  <text x="170" y="352" font-family="Inter, sans-serif" font-size="14" font-weight="bold" fill="#FFFFFF" text-anchor="middle">GET IT ON Google Play</text>
</svg>
`;
  await saveAsset('marketing', 'marketing_banner', banner, 1024, 500);
}

// ==========================================
// 17. Design System Tokens (JSON/CSS/Flutter)
// ==========================================
function generateDesignTokens() {
  console.log('Generating Design System token files...');
  const tokensPath = ensureDirs('design-tokens');
  
  // JSON Tokens
  const jsonTokens = {
    colors: {
      primary: '#2563EB',
      primaryContainer: '#EEF2FF',
      onPrimary: '#FFFFFF',
      secondary: '#14B8A6',
      secondaryContainer: '#ECFEFF',
      onSecondary: '#0891B2',
      background: '#F8FAFC',
      surface: '#FFFFFF',
      surfaceVariant: '#F1F5F9',
      outline: '#E2E8F0',
      success: '#22C55E',
      warning: '#F59E0B',
      error: '#EF4444',
      info: '#3B82F6'
    },
    spacing: [4, 8, 12, 16, 20, 24, 32, 40, 48, 64],
    radius: {
      small: 8,
      medium: 12,
      large: 16,
      xl: 24
    },
    elevation: {
      flat: 0,
      low: 1,
      medium: 2,
      high: 3,
      modal: 4
    }
  };
  fs.writeFileSync(path.join(tokensPath.svgDir, 'design_tokens.json'), JSON.stringify(jsonTokens, null, 2));
  
  // CSS Variables
  const cssVars = `
:root {
  --color-primary: #2563EB;
  --color-primary-container: #EEF2FF;
  --color-on-primary: #FFFFFF;
  --color-secondary: #14B8A6;
  --color-background: #F8FAFC;
  --color-surface: #FFFFFF;
  
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 12px;
  --spacing-base: 16px;
  
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
}
  `;
  fs.writeFileSync(path.join(tokensPath.svgDir, 'design_tokens.css'), cssVars);
  
  // Flutter theme class
  const flutterTheme = `
import 'package:flutter/material.dart';

class BrandDesignSystem {
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryContainer = Color(0xFFEEF2FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}
  `;
  fs.writeFileSync(path.join(tokensPath.svgDir, 'design_tokens.dart'), flutterTheme);
}

// ==========================================
// Execute Pipeline
// ==========================================
async function main() {
  try {
    console.log('Starting AI Language Coach brand asset generation pipeline...');
    
    await exportExistingLogos();
    await generateSplash();
    await generateOnboarding();
    await generateEmptyStates();
    await generateBadges();
    await generateXPIcons();
    await generateAvatars();
    await generateAIAssistant();
    await generateExamIcons();
    await generateLanguageIcons();
    await generateCategoryIcons();
    await generateNotificationIcons();
    await generateCertificates();
    await generateMascot();
    await generateAnimations();
    await generateMarketing();
    generateDesignTokens();
    
    console.log('AI Language Coach brand asset generation completed successfully!');
  } catch (error) {
    console.error('Error during asset generation:', error);
    process.exit(1);
  }
}

main();
