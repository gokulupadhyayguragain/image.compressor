require('dotenv').config();
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');

const PORT = process.env.PORT || 3000;
const UPLOAD_DIR = path.resolve(__dirname, '..', 'input');
const OUTPUT_DIR = path.resolve(__dirname, '..', 'output');
const FRONTEND_DIR = path.resolve(__dirname, '..', 'frontend');

if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });
if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });

const app = express();

// Very small CORS middleware to allow the frontend served from a different origin
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', process.env.CORS_ORIGIN || '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, UPLOAD_DIR);
  },
  filename: function (req, file, cb) {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, unique + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

// Simple health
app.get('/health', (req, res) => res.json({ ok: true }));

// POST /compress - accepts a single file named `image`
app.post('/compress', upload.single('image'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'no file uploaded' });

  const inPath = req.file.path;
  const outName = 'compressed-' + req.file.filename;
  const outPath = path.join(OUTPUT_DIR, outName);

  try {
    const mime = req.file.mimetype || '';
    let finalOutPath = outPath;
    
    // Get original file size BEFORE compression
    const originalSize = fs.statSync(inPath).size;
    
    // Apply compression with fixed quality settings
    if (mime === 'image/png') {
      await sharp(inPath)
        .png({ 
          compressionLevel: 9, 
          quality: 80,
          palette: true,
          effort: 10
        })
        .toFile(finalOutPath);
    } else if (mime === 'image/webp') {
      await sharp(inPath)
        .webp({ 
          quality: 80,
          effort: 6
        })
        .toFile(finalOutPath);
    } else if (mime === 'image/gif') {
      // Convert GIF to optimized PNG
      finalOutPath = outPath.replace(path.extname(outPath), '.png');
      await sharp(inPath)
        .png({ compressionLevel: 9, quality: 80 })
        .toFile(finalOutPath);
    } else if (mime === 'image/jpeg' || mime === 'image/jpg') {
      // JPEG compression with fixed quality 80
      await sharp(inPath)
        .jpeg({ 
          quality: 80, 
          mozjpeg: true,
          progressive: true
        })
        .toFile(finalOutPath);
    } else {
      // Default: try sharp conversion
      try {
        await sharp(inPath)
          .jpeg({ quality: 80, mozjpeg: true })
          .toFile(finalOutPath);
      } catch (e) {
        // fallback to copy
        fs.copyFileSync(inPath, finalOutPath);
      }
    }

    // Get output file size AFTER compression
    const outputSize = fs.statSync(finalOutPath).size;

    // Return JSON with download URL and sizes
    const downloadUrl = `/output/${path.basename(finalOutPath)}`;
    res.json({ ok: true, download: downloadUrl, filename: path.basename(finalOutPath), originalSize, outputSize });
  } catch (err) {
    console.error('compress error', err);
    res.status(500).json({ error: 'compression failed', details: err.message });
  }
});

// Serve compressed files from output folder
app.use('/output', express.static(OUTPUT_DIR));
// serve uploaded originals too so frontend can preview server-side files
app.use('/input', express.static(UPLOAD_DIR));

// Endpoint to list files in input or output directories (use /api/files to avoid static collisions)
app.get('/api/files', (req, res) => {
  const dir = req.query.dir === 'output' ? OUTPUT_DIR : UPLOAD_DIR;
  try {
    const items = fs.readdirSync(dir).filter(f => !f.startsWith('.')).map(f => {
      const full = path.join(dir, f);
      let stat = { size: 0, mtime: 0 };
      try { const s = fs.statSync(full); stat.size = s.size; stat.mtime = s.mtimeMs; } catch (e) {}
      return { name: f, url: `/${req.query.dir === 'output' ? 'output' : 'input'}/${f}`, size: stat.size, mtime: stat.mtime };
    });
    res.json({ ok: true, files: items });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
});

// fallback to index.html for SPA
// serve frontend static files (mount after API routes to avoid collisions)
app.use(express.static(FRONTEND_DIR));

// fallback to index.html for SPA
app.get('*', (req, res) => {
  res.sendFile(path.join(FRONTEND_DIR, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
