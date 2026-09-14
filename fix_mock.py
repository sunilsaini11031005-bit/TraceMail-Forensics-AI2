import re

with open('src/mockData.ts', 'r') as f:
    content = f.read()

# { url: 'http://update-secure-auth.net/login', safe: false } -> add domain
content = re.sub(r"\{\s*url:\s*'([^']+)',\s*safe:\s*(true|false)\s*\}", 
    lambda m: f"{{ url: '{m.group(1)}', domain: '{m.group(1).split('/')[2]}', safe: {m.group(2)} }}", 
    content)

with open('src/mockData.ts', 'w') as f:
    f.write(content)
