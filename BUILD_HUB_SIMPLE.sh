#!/usr/bin/env bash
# 🍄 Simple hub - just list your known pages

cat > data/all_pages.json <<'EOPAGES'
[
  {
    "name": "infinity-crown-index",
    "pages_url": "https://pewpi-infinity.github.io/infinity-crown-index/"
  },
  {
    "name": "infinity-mega-labs",
    "pages_url": "https://pewpi-infinity.github.io/infinity-mega-labs/"
  },
  {
    "name": "mario-InfinityTrumpCoin",
    "pages_url": "https://pewpi-infinity.github.io/mario-InfinityTrumpCoin/"
  },
  {
    "name": "infinity-research-engine",
    "pages_url": "https://pewpi-infinity.github.io/infinity-research-engine/"
  },
  {
    "name": "infinity-master-hub",
    "pages_url": "https://pewpi-infinity.github.io/infinity-master-hub/"
  }
]
EOPAGES

python3 <<'EOBUILD'
import json

with open("data/all_pages.json") as f:
    pages = json.load(f)

html = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🍄 Infinity Hub</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            font-family: 'Courier New', monospace;
            padding: 2rem;
            min-height: 100vh;
        }}
        .container {{ max-width: 1200px; margin: 0 auto; }}
        h1 {{
            text-align: center;
            font-size: 3.5rem;
            margin-bottom: 1rem;
            text-shadow: 0 0 30px rgba(255,255,255,0.5);
        }}
        .subtitle {{
            text-align: center;
            font-size: 1.5rem;
            margin-bottom: 3rem;
            opacity: 0.9;
        }}
        .grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
            margin: 3rem 0;
        }}
        .card {{
            background: rgba(255,255,255,0.1);
            border: 3px solid rgba(255,255,255,0.3);
            border-radius: 20px;
            padding: 2rem;
            transition: all 0.3s;
            cursor: pointer;
        }}
        .card:hover {{
            transform: translateY(-10px);
            box-shadow: 0 30px 60px rgba(0,0,0,0.4);
            border-color: #fff;
            background: rgba(255,255,255,0.15);
        }}
        .icon {{ font-size: 3rem; margin-bottom: 1rem; }}
        .title {{
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 1rem;
        }}
        .url {{
            font-size: 0.9rem;
            opacity: 0.7;
            word-break: break-all;
        }}
        a {{ color: inherit; text-decoration: none; }}
        .add-more {{
            text-align: center;
            margin: 3rem 0;
            padding: 2rem;
            background: rgba(255,255,255,0.1);
            border-radius: 20px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🍄 INFINITY HUB</h1>
        <div class="subtitle">All Your Pages, One Place</div>
        
        <div class="grid">
'''

icons = ["👑", "🧪", "🎮", "🔬", "🌐"]

for idx, page in enumerate(pages):
    icon = icons[idx % len(icons)]
    name = page['name'].replace('-', ' ').title()
    url = page['pages_url']
    
    html += f'''
            <a href="{url}" target="_blank" rel="noopener">
                <div class="card">
                    <div class="icon">{icon}</div>
                    <div class="title">{name}</div>
                    <div class="url">{url}</div>
                </div>
            </a>
'''

html += f'''
        </div>
        
        <div class="add-more">
            <h2>🚀 Want to add more pages?</h2>
            <p>Just add them to data/all_pages.json and rebuild!</p>
            <p style="margin-top:1rem;">Currently showing: <strong>{len(pages)} pages</strong></p>
        </div>
    </div>
</body>
</html>
'''

with open("index.html", "w") as f:
    f.write(html)

print("✅ Hub built!")
EOBUILD

git add .
git commit -m "🍄 Hub with known pages"
git push origin main

echo ""
echo "✅ HUB READY!"
echo "🌐 https://pewpi-infinity.github.io/infinity-master-hub/"
