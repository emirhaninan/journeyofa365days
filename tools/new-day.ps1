Param(
  [string]$DayNumber,
  [string]$Title,
  [string]$Date
)

function Read-NonEmpty([string]$prompt){
  while ($true) {
    $v = Read-Host $prompt
    if ($v -and $v.Trim().Length -gt 0) { return $v.Trim() }
  }
}

$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location -Path (Resolve-Path ..)

if (-not $DayNumber) { $DayNumber = Read-Host 'Enter day number (e.g., 2 or 002)' }
try { $n = [int]$DayNumber } catch { Write-Error 'Day number must be numeric'; exit 1 }
$dayId = ('{0:D3}' -f $n)

if (-not $Title) { $Title = Read-NonEmpty "Enter day title (e.g., Greetings and Study)" }
if (-not $Date) { $Date = (Get-Date -Format 'yyyy-MM-dd') }

Write-Host "Creating day-$dayId.html ..." -ForegroundColor Cyan

# Collect words
$words = @()
while ($true) {
  $add = (Read-Host 'Add a word? (y/n)').ToLower()
  if ($add -ne 'y') { break }
  $hanzi   = Read-NonEmpty '  Hanzi (e.g., 学习)'
  $pinyin  = Read-NonEmpty '  Pinyin (e.g., xuéxí)'
  $meaning = Read-NonEmpty '  Meaning (e.g., to study; to learn)'
  $zhEx    = Read-NonEmpty '  Example Chinese'
  $pnyEx   = Read-NonEmpty '  Example Pinyin'
  $enEx    = Read-NonEmpty '  Example English'
  $words += [pscustomobject]@{ Hanzi=$hanzi; Pinyin=$pinyin; Meaning=$meaning; Zh=$zhEx; Pny=$pnyEx; En=$enEx }
}

if ($words.Count -eq 0) { Write-Warning 'No words added. Proceeding to create the page with an empty list.' }

function Build-HanziBigGrid([string]$hanzi){
  $chars = $hanzi.ToCharArray()
  $items = foreach ($c in $chars) { "            <div class=\"hanzi-big\">$c</div>" }
  return @(
    "          <div class=\"hanzi-big-grid\">",
    ($items -join "`n"),
    "          </div>"
  ) -join "`n"
}

function Build-WordCard($w){
  $grid = Build-HanziBigGrid $w.Hanzi
  @(
    "        <section class=\"word-card\">",
    "          <div class=\"word-header\">",
    "            <div class=\"word-title\">$($w.Hanzi)</div>",
    "            <span class=\"badge\">Hanzi</span>",
    "          </div>",
    $grid,
    "          <div class=\"word-info\">",
    "            <div class=\"pinyin\">$($w.Pinyin)</div>",
    "            <div class=\"meaning\">$($w.Meaning)</div>",
    "            <div class=\"actions\">",
    "              <button class=\"btn speak\" data-text=\"$($w.Hanzi)\">Speak</button>",
    "            </div>",
    "          </div>",
    "          <div class=\"examples\">",
    "            <p class=\"zh\">$($w.Zh)</p>",
    "            <p class=\"pny\">$($w.Pny)</p>",
    "            <p class=\"en\">$($w.En)</p>",
    "          </div>",
    "        </section>"
  ) -join "`n"
}

$cards = ($words | ForEach-Object { Build-WordCard $_ }) -join "`n`n"

$prevNum = if ($n -gt 1) { '{0:D3}' -f ($n-1) } else { $null }
$nextNum = '{0:D3}' -f ($n+1)
$prevHref = if ($prevNum) { "day-$prevNum.html" } else { "index.html" }
$nextHref = "day-$nextNum.html"
$nextLink = "<a href=\"$nextHref\" aria-disabled=\"true\">Next Day →</a>"

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Day $dayId — $Title | 365 Days of Chinese</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Noto+Serif+SC:wght@400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="assets/styles/style.css">
  <link rel="icon" href="assets/favicon.svg" type="image/svg+xml" />
  <meta name="description" content="Day $dayId of my Chinese journey — words, pronunciation, examples." />
  <meta name="robots" content="index,follow" />
  <meta property="og:title" content="Day $dayId — $Title | 365 Days of Chinese" />
  <meta property="og:description" content="Daily Chinese learning journal entries." />
  <meta property="og:type" content="article" />
  <meta property="og:url" content="day-$dayId.html" />
</head>
<body>
  <a class="skip-link" href="#content">Skip to content</a>
  <header class="site-header">
    <div class="container">
      <a class="site-title" href="./">🀄 365 Days of Chinese</a>
      <div class="site-actions">
        <button id="themeToggle" class="theme-toggle" aria-label="Toggle color theme">Toggle theme</button>
      </div>
    </div>
  </header>

  <main id="content" class="container" tabindex="-1">
    <article class="post-card">
      <header class="post-header">
        <h1 class="post-title">Day $dayId — $Title</h1>
        <div class="post-meta">$Date</div>
      </header>
      <div class="post-content">
        <h2>Words Learned</h2>
$cards
        <nav class="post-nav">
          <a href="$prevHref">← Back</a>
          $nextLink
        </nav>
      </div>
    </article>
  </main>

  <footer class="site-footer">
    <div class="container">
      <p>© <span id="y"></span> · 365 Days of Chinese</p>
    </div>
  </footer>
  <script>document.getElementById('y').textContent = new Date().getFullYear();</script>
  <script src="assets/scripts/main.js"></script>
  <script src="assets/scripts/day.js"></script>
</body>
</html>
"@

Set-Content -Path ("day-$dayId.html") -Value $html -Encoding UTF8

# Update index.html: prepend link under #dayList
$indexPath = 'index.html'
if (Test-Path $indexPath) {
  $index = Get-Content -Raw -Path $indexPath
  $link = "          <a class=\"post-list-item\" href=\"day-$dayId.html\" data-title=\"Day $dayId: $Title\">`n            <div class=\"post-list-title\">Day $dayId — $Title</div>`n            <div class=\"post-list-date\">$Date</div>`n          </a>"
  $pattern = '(?s)(<div id="dayList" class="post-list">)'
  if ($index -match $pattern) {
    $index = [System.Text.RegularExpressions.Regex]::Replace($index, $pattern, "`$1`n$link", 1)
    Set-Content -Path $indexPath -Value $index -Encoding UTF8
    Write-Host "Updated index.html with Day $dayId" -ForegroundColor Green
  } else {
    Write-Warning 'Could not locate #dayList container in index.html. Please add the link manually.'
  }
} else {
  Write-Warning 'index.html not found. Skipping index update.'
}

# Update previous day Next link if exists
if ($prevNum) {
  $prevPath = "day-$prevNum.html"
  if (Test-Path $prevPath) {
    $prev = Get-Content -Raw -Path $prevPath
    $prev2 = $prev -replace '<a[^>]*>Next Day →</a>', ("<a href=\"day-$dayId.html\">Next Day →</a>")
    if ($prev2 -ne $prev) {
      Set-Content -Path $prevPath -Value $prev2 -Encoding UTF8
      Write-Host "Linked Day $prevNum → Day $dayId" -ForegroundColor Green
    }
  }
}

Write-Host "Done. Open day-$dayId.html to review." -ForegroundColor Cyan



