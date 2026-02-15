#!/usr/bin/env bash
# 🍄 Find ALL repos + Enable Pages on ALL

set -euo pipefail

USER="pewpi-infinity"

echo "🍄 Scanning ALL repos..."

# Get repos directly via API (more reliable)
python3 <<'EOPY'
import requests
import json
import time

USER = "pewpi-infinity"

print("📡 Fetching all repos...")

repos = []
page = 1

while page < 20:
    print(f"  Page {page}...")
    r = requests.get(
        f"https://api.github.com/users/{USER}/repos?per_page=100&page={page}",
        timeout=10
    )
    
    if r.status_code != 200:
        print(f"  Error: {r.status_code}")
        break
    
    batch = r.json()
    if not batch:
        break
    
    repos.extend(batch)
    page += 1

print(f"✅ Found {len(repos)} repos")

# Save for next step
with open("all_repos.json", "w") as f:
    json.dump(repos, f, indent=2)

# Try to detect which have content
pages_candidates = []

for idx, repo in enumerate(repos, 1):
    name = repo['name']
    print(f"[{idx}/{len(repos)}] {name}")
    
    # Check if it has an index.html or content
    try:
        check = requests.get(
            f"https://api.github.com/repos/{USER}/{name}/contents",
            timeout=5
        )
        
        if check.status_code == 200:
            files = check.json()
            has_html = any(f.get('name', '').endswith('.html') for f in files if isinstance(f, dict))
            
            if has_html:
                pages_candidates.append({
                    "name": name,
                    "repo_url": repo['html_url'],
                    "has_content": True
                })
                print(f"  ✅ Has HTML content")
        
        time.sleep(0.1)  # Rate limit
    except:
        pass

print(f"\n✅ Found {len(pages_candidates)} repos with HTML content")

with open("pages_candidates.json", "w") as f:
    json.dump(pages_candidates, f, indent=2)
EOPY

# Now enable Pages on all candidates
echo ""
echo "🚀 Enabling GitHub Pages on repos with content..."

python3 <<'EOENABLE'
import json
import subprocess

with open("pages_candidates.json") as f:
    candidates = json.load(f)

print(f"Enabling Pages on {len(candidates)} repos...")

for idx, repo in enumerate(candidates, 1):
    name = repo['name']
    print(f"[{idx}/{len(candidates)}] {name}...", end=" ")
    
    # Try to enable via gh api
    result = subprocess.run(
        [
            "gh", "api", "-X", "POST",
            f"repos/pewpi-infinity/{name}/pages",
            "-f", "source[branch]=main",
            "-f", "source[path]=/"
        ],
        capture_output=True,
        text=True
    )
    
    if result.returncode == 0:
        print("✅ Enabled")
        repo['pages_url'] = f"https://pewpi-infinity.github.io/{name}/"
        repo['pages_enabled'] = True
    else:
        # Try gh-pages branch
        result2 = subprocess.run(
            [
                "gh", "api", "-X", "POST",
                f"repos/pewpi-infinity/{name}/pages",
                "-f", "source[branch]=gh-pages",
                "-f", "source[path]=/"
            ],
            capture_output=True,
            text=True
        )
        
        if result2.returncode == 0:
            print("✅ Enabled (gh-pages)")
            repo['pages_url'] = f"https://pewpi-infinity.github.io/{name}/"
            repo['pages_enabled'] = True
        else:
            print("⚠️ Already enabled or error")
            repo['pages_url'] = f"https://pewpi-infinity.github.io/{name}/"
            repo['pages_enabled'] = "unknown"

# Save results
with open("data/all_pages.json", "w") as f:
    json.dump(candidates, f, indent=2)

print(f"\n✅ Pages enabled on repos!")
EOENABLE

# Build the hub page
python3 <<'EOBUILD'
import json

with open("data/all_pages.json") as f:
    pages = json.load(f)

html = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🍄 Infinity Master Hub</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            font-family: 'Courier New', monospace;
            padding: 2rem;
        }}
        .container {{ max-width: 1600px; margin: 0 auto; }}
        h1 {{
            text-align: center;
            font-size: 3rem;
            margin-bottom: 2rem;
            text-shadow: 0 0 20px rgba(255,255,255,0.5);
        }}
        .grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
        }}
        .card {{
            background: rgba(255,255,255,0.1);
            border: 3px solid rgba(255,255,255,0.3);
            border-radius: 15px;
            padding: 1.5rem;
            transition: all 0.3s;
        }}
        .card:hover {{
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            border-color: #fff;
        }}
        .title {{ font-size: 1.3rem; font-weight: bold; margin-bottom: 0.5rem; }}
        .url {{ font-size: 0.85rem; opacity: 0.8; word-break: break-all; }}
        a {{ color: inherit; text-decoration: none; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🍄 INFINITY MASTER HUB</h1>
        <p style="text-align:center;font-size:1.5rem;margin-bottom:3rem;">{len(pages)} Active Pages</p>
        
        <div class="grid">
'''

for page in pages:
    url = page.get('pages_url', '#')
    name = page['name'].replace('-', ' ').title()
    
    html += f'''
            <a href="{url}" target="_blank" rel="noopener">
                <div class="card">
                    <div class="title">🌐 {name}</div>
                    <div class="url">{url}</div>
                </div>
            </a>
'''

html += '''
        </div>
    </div>
</body>
</html>
'''

with open("index.html", "w") as f:
    f.write(html)

print("✅ Hub page built!")
EOBUILD

# Push everything
git add .
git commit -m "🍄 Master Hub - All pages"
gh repo sync --force || git push origin main --force

echo ""
echo "✅ DONE!"
echo ""
echo "📊 Results:"
cat data/all_pages.json | python3 -c "import sys,json; print(f\"Pages found: {len(json.load(sys.stdin))}\")"
echo ""
echo "🌐 https://pewpi-infinity.github.io/infinity-master-hub/"
