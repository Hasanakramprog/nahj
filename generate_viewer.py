import json

# Read the JSON data
with open('all_explanations.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Create HTML with embedded data
html_content = '''<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>شروح نهج البلاغة - Nahj al-Balagha Explanations</title>
    <link href="https://fonts.googleapis.com/css2?family=Amiri:wght@400;700&family=Cairo:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Amiri', 'Traditional Arabic', 'Arabic Typesetting', 'Scheherazade', serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            min-height: 100vh;
            padding: 20px;
            line-height: 2;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 24px;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.4);
            overflow: hidden;
        }

        header {
            background: linear-gradient(135deg, #0f3460 0%, #16213e 100%);
            color: white;
            padding: 50px 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><circle cx="50" cy="50" r="40" fill="rgba(255,255,255,0.03)"/></svg>');
            opacity: 0.1;
        }

        header h1 {
            font-family: 'Cairo', sans-serif;
            font-size: 3em;
            margin-bottom: 15px;
            text-shadow: 3px 3px 6px rgba(0, 0, 0, 0.4);
            position: relative;
            font-weight: 700;
        }

        header p {
            font-size: 1.4em;
            opacity: 0.95;
            position: relative;
            font-weight: 400;
        }

        .search-container {
            padding: 35px 40px;
            background: linear-gradient(to bottom, #f8f9fa, #ffffff);
            border-bottom: 3px solid #e9ecef;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .search-box {
            display: flex;
            gap: 15px;
            align-items: center;
            max-width: 800px;
            margin: 0 auto;
        }

        #searchInput {
            flex: 1;
            padding: 18px 25px;
            font-size: 1.2em;
            border: 3px solid #e0e0e0;
            border-radius: 15px;
            font-family: inherit;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        #searchInput:focus {
            outline: none;
            border-color: #0f3460;
            box-shadow: 0 4px 20px rgba(15, 52, 96, 0.15);
            transform: translateY(-2px);
        }

        .clear-btn {
            padding: 18px 30px;
            background: #e74c3c;
            color: white;
            border: none;
            border-radius: 15px;
            font-size: 1.1em;
            cursor: pointer;
            transition: all 0.3s;
            font-family: 'Cairo', sans-serif;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(231, 76, 60, 0.3);
        }

        .clear-btn:hover {
            background: #c0392b;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(231, 76, 60, 0.4);
        }

        .stats {
            margin-top: 20px;
            text-align: center;
            display: flex;
            justify-content: center;
            gap: 30px;
            flex-wrap: wrap;
        }

        .stat-item {
            background: white;
            padding: 12px 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            font-family: 'Cairo', sans-serif;
            font-weight: 600;
            color: #0f3460;
        }

        .stat-number {
            font-size: 1.5em;
            color: #e74c3c;
            font-weight: 700;
        }

        .content {
            padding: 40px;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
            gap: 30px;
            max-height: calc(100vh - 450px);
            overflow-y: auto;
        }

        .sermon-card {
            background: linear-gradient(to bottom right, #ffffff, #f8f9fa);
            border: 3px solid #e9ecef;
            border-radius: 20px;
            padding: 35px;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
            position: relative;
            overflow: hidden;
        }

        .sermon-card::before {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, rgba(15, 52, 96, 0.05), transparent);
            border-radius: 0 20px 0 100%;
        }

        .sermon-card:hover {
            border-color: #0f3460;
            box-shadow: 0 15px 40px rgba(15, 52, 96, 0.25);
            transform: translateY(-8px) scale(1.02);
        }

        .sermon-header {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 4px solid #0f3460;
            position: relative;
        }

        .sermon-number {
            background: linear-gradient(135deg, #0f3460 0%, #16213e 100%);
            color: white;
            padding: 15px 25px;
            border-radius: 15px;
            font-size: 1.4em;
            font-weight: bold;
            min-width: 140px;
            text-align: center;
            box-shadow: 0 6px 20px rgba(15, 52, 96, 0.4);
            font-family: 'Cairo', sans-serif;
            position: relative;
            z-index: 1;
        }

        .sermon-title {
            font-size: 1.6em;
            font-weight: bold;
            color: #1a1a2e;
            font-family: 'Cairo', sans-serif;
            flex: 1;
        }

        .sermon-text {
            font-size: 1.2em;
            line-height: 2.4;
            color: #2c3e50;
            text-align: justify;
            position: relative;
            z-index: 1;
        }

        .sermon-text p {
            margin-bottom: 18px;
            text-indent: 30px;
        }

        .sermon-text p:first-child::first-letter {
            font-size: 2em;
            font-weight: bold;
            color: #0f3460;
            float: right;
            margin-left: 10px;
            line-height: 1;
        }

        .toggle-btn {
            background: #3498db;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            margin-top: 15px;
            font-family: 'Cairo', sans-serif;
            font-weight: 600;
            transition: all 0.3s;
            box-shadow: 0 3px 10px rgba(52, 152, 219, 0.3);
        }

        .toggle-btn:hover {
            background: #2980b9;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
        }

        .sermon-text.collapsed {
            max-height: 200px;
            overflow: hidden;
            position: relative;
        }

        .sermon-text.collapsed::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 100px;
            background: linear-gradient(to bottom, transparent, #f8f9fa);
        }

        .no-results {
            grid-column: 1 / -1;
            text-align: center;
            padding: 80px 20px;
            color: #6c757d;
            font-size: 1.5em;
            font-family: 'Cairo', sans-serif;
        }

        .no-results::before {
            content: '🔍';
            display: block;
            font-size: 4em;
            margin-bottom: 20px;
        }

        /* Scrollbar styling */
        .content::-webkit-scrollbar {
            width: 12px;
        }

        .content::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }

        .content::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #0f3460, #16213e);
            border-radius: 10px;
        }

        .content::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(135deg, #16213e, #0f3460);
        }

        /* Highlight search results */
        .highlight {
            background: linear-gradient(120deg, #ffd700 0%, #ffed4e 100%);
            padding: 3px 6px;
            border-radius: 4px;
            font-weight: bold;
            box-shadow: 0 2px 5px rgba(255, 215, 0, 0.3);
        }

        @media (max-width: 1200px) {
            .content {
                grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            }
        }

        @media (max-width: 768px) {
            header h1 {
                font-size: 2em;
            }

            .content {
                grid-template-columns: 1fr;
                padding: 20px;
            }

            .sermon-header {
                flex-direction: column;
                text-align: center;
            }

            .sermon-number {
                min-width: 100%;
            }
        }

        /* Loading animation */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .sermon-card {
            animation: fadeIn 0.5s ease-out;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🕌 شروح نهج البلاغة</h1>
            <p>نفحات الولاية في شرح نهج البلاغة</p>
        </header>

        <div class="search-container">
            <div class="search-box">
                <input 
                    type="text" 
                    id="searchInput" 
                    placeholder="🔍 ابحث في الشروح... (يمكنك البحث برقم الخطبة أو نص الشرح)"
                    autocomplete="off"
                >
                <button class="clear-btn" id="clearBtn">مسح البحث</button>
            </div>
            <div class="stats">
                <div class="stat-item">
                    <span id="statsText">جاري التحميل...</span>
                </div>
            </div>
        </div>

        <div class="content" id="content">
        </div>
    </div>

    <script>
        // Embedded data
        const allData = ''' + json.dumps(data, ensure_ascii=False, indent=2) + ''';
        
        let displayedSermons = [];

        // Display all sermons
        function displayAllSermons() {
            const content = document.getElementById('content');
            content.innerHTML = '';
            
            // Sort sermon numbers numerically
            const sortedKeys = Object.keys(allData).sort((a, b) => {
                const numA = parseInt(a.replace('الخطبة', ''));
                const numB = parseInt(b.replace('الخطبة', ''));
                return numA - numB;
            });

            displayedSermons = sortedKeys;

            sortedKeys.forEach((key, index) => {
                const sermonCard = createSermonCard(key, allData[key], index);
                content.appendChild(sermonCard);
            });
        }

        // Create a sermon card element
        function createSermonCard(key, text, index) {
            const card = document.createElement('div');
            card.className = 'sermon-card';
            card.dataset.sermonKey = key;
            card.style.animationDelay = `${index * 0.05}s`;

            const sermonNumber = key.replace('الخطبة', '');
            
            // Truncate text if too long
            const isLong = text.length > 500;
            const displayText = text;
            
            card.innerHTML = `
                <div class="sermon-header">
                    <div class="sermon-number">${key}</div>
                    <div class="sermon-title">الخطبة رقم ${sermonNumber}</div>
                </div>
                <div class="sermon-text ${isLong ? 'collapsed' : ''}" id="text-${sermonNumber}">${formatText(displayText)}</div>
                ${isLong ? `<button class="toggle-btn" onclick="toggleText('${sermonNumber}')">عرض المزيد ▼</button>` : ''}
            `;

            return card;
        }

        // Toggle text expansion
        function toggleText(sermonNumber) {
            const textElement = document.getElementById('text-' + sermonNumber);
            const btn = event.target;
            
            if (textElement.classList.contains('collapsed')) {
                textElement.classList.remove('collapsed');
                btn.textContent = 'عرض أقل ▲';
            } else {
                textElement.classList.add('collapsed');
                btn.textContent = 'عرض المزيد ▼';
                textElement.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }
        }

        // Format text with paragraphs
        function formatText(text) {
            return text
                .split('\\n\\n')
                .map(para => para.trim())
                .filter(para => para.length > 0)
                .map(para => `<p>${para}</p>`)
                .join('');
        }

        // Search functionality
        function performSearch(query) {
            const content = document.getElementById('content');
            
            if (!query.trim()) {
                displayAllSermons();
                updateStats();
                return;
            }

            content.innerHTML = '';
            let foundCount = 0;
            let index = 0;

            Object.keys(allData).sort((a, b) => {
                const numA = parseInt(a.replace('الخطبة', ''));
                const numB = parseInt(b.replace('الخطبة', ''));
                return numA - numB;
            }).forEach(key => {
                const text = allData[key];
                const lowerQuery = query.toLowerCase();
                const lowerText = text.toLowerCase();
                const lowerKey = key.toLowerCase();

                if (lowerText.includes(lowerQuery) || lowerKey.includes(lowerQuery)) {
                    const highlightedText = highlightText(text, query);
                    const card = createSermonCard(key, highlightedText, index);
                    content.appendChild(card);
                    foundCount++;
                    index++;
                }
            });

            if (foundCount === 0) {
                content.innerHTML = '<div class="no-results">لم يتم العثور على نتائج للبحث: "' + query + '"</div>';
            }

            updateStats(foundCount, query);
        }

        // Highlight search query in text
        function highlightText(text, query) {
            if (!query.trim()) return text;
            
            const regex = new RegExp('(' + escapeRegExp(query) + ')', 'gi');
            return text.replace(regex, '<span class="highlight">$1</span>');
        }

        // Escape special regex characters
        function escapeRegExp(string) {
            return string.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&');
        }

        // Update statistics
        function updateStats(filteredCount = null, query = null) {
            const totalSermons = Object.keys(allData).length;
            const statsText = document.getElementById('statsText');

            if (filteredCount !== null && query) {
                statsText.innerHTML = `<span class="stat-number">${filteredCount}</span> من <span class="stat-number">${totalSermons}</span> خطبة - البحث: "${query}"`;
            } else {
                statsText.innerHTML = `إجمالي الخطب: <span class="stat-number">${totalSermons}</span> خطبة`;
            }
        }

        // Event listeners
        document.getElementById('searchInput').addEventListener('input', (e) => {
            performSearch(e.target.value);
        });

        document.getElementById('clearBtn').addEventListener('click', () => {
            document.getElementById('searchInput').value = '';
            displayAllSermons();
            updateStats();
        });

        // Keyboard shortcut
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey && e.key === 'k') {
                e.preventDefault();
                document.getElementById('searchInput').focus();
            }
        });

        // Initialize on page load
        displayAllSermons();
        updateStats();
    </script>
</body>
</html>
'''

# Write the HTML file
with open('view_explanations.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print("✅ HTML file generated successfully with embedded data!")
print(f"📊 Total sermons: {len(data)}")
