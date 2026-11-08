# يولّد أيقونات Adaptive Icon لأندرويد + أيقونة Play 512x512 من اللوجو الأصلي
# يستخدم System.Drawing مع LockBits (سريع) — بدون أي اعتماد خارجي
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$srcPath = 'E:\Dev\Full Project\zad\app\assets\images\app_logo.png'
$resDir  = 'E:\Dev\Full Project\zad\app\android\app\src\main\res'
$outDir  = 'E:\Dev\Full Project\zad\store_assets'
New-Item -ItemType Directory -Force $outDir | Out-Null

$src = [System.Drawing.Bitmap]::FromFile($srcPath)
$W = $src.Width; $H = $src.Height
Write-Host "Source: ${W}x${H}"

# ---- 1) كشف الـ bounding box للكلمة (فرق عن لون الخلفية الكريمي) ----
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$data = $src.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$bytes = New-Object byte[] ($data.Stride * $H)
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
$src.UnlockBits($data)

$bgR = 250; $bgG = 248; $bgB = 245; $tol = 30
$minX = $W; $minY = $H; $maxX = 0; $maxY = 0
for ($y = 0; $y -lt $H; $y++) {
    $row = $y * $data.Stride
    for ($x = 0; $x -lt $W; $x++) {
        $i = $row + $x * 4
        $b = $bytes[$i]; $g = $bytes[$i+1]; $r = $bytes[$i+2]; $a = $bytes[$i+3]
        if ([math]::Abs($r-$bgR) -gt $tol -or [math]::Abs($g-$bgG) -gt $tol -or [math]::Abs($b-$bgB) -gt $tol -or $a -lt 200) {
            if ($x -lt $minX) {$minX=$x}; if ($y -lt $minY) {$minY=$y}
            if ($x -gt $maxX) {$maxX=$x}; if ($y -gt $maxY) {$maxY=$y}
        }
    }
}
$cropW = $maxX - $minX + 1; $cropH = $maxY - $minY + 1
Write-Host "Wordmark bbox: ($minX,$minY) ${cropW}x${cropH}"

$cropRect = New-Object System.Drawing.Rectangle($minX, $minY, $cropW, $cropH)
# نسخة شفافة من القصاصة: البكسلات القريبة من الكريمي تبقى شفافة بدرجـة ناعمة
# (مهم جدًا لمونوكروم أيقونة آندرويد 13: لازم الخلفية شفافة)
$crop = New-Object System.Drawing.Bitmap($cropW, $cropH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$cropData = $crop.LockBits((New-Object System.Drawing.Rectangle(0,0,$cropW,$cropH)), [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$cropBytes = New-Object byte[] ($cropData.Stride * $cropH)
for ($y = 0; $y -lt $cropH; $y++) {
    $srcRow = ($minY + $y) * $data.Stride
    $outRow = $y * $cropData.Stride
    for ($x = 0; $x -lt $cropW; $x++) {
        $si = $srcRow + ($minX + $x) * 4
        $oi = $outRow + $x * 4
        $diff = [math]::Max([math]::Abs($bytes[$si+2]-$bgR), [math]::Max([math]::Abs($bytes[$si+1]-$bgG), [math]::Abs($bytes[$si]-$bgB)))
        $a = [math]::Min(255, [int](($diff / $tol) * 255))
        $cropBytes[$oi]     = $bytes[$si]    # B
        $cropBytes[$oi+1]   = $bytes[$si+1]  # G
        $cropBytes[$oi+2]   = $bytes[$si+2]  # R
        $cropBytes[$oi+3]   = $a
    }
}
[System.Runtime.InteropServices.Marshal]::Copy($cropBytes, 0, $cropData.Scan0, $cropBytes.Length)
$crop.UnlockBits($cropData)

function New-Canvas([int]$size) { New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb) }
function Setup-Gr([System.Drawing.Graphics]$gr) {
    $gr.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gr.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $gr.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gr.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
}

# ---- 2) Foreground لكل كثافة (خلفية شفافة + الكلمة 58% من العرض في النص) ----
$foreDensities = @{ 'mipmap-mdpi' = 108; 'mipmap-hdpi' = 162; 'mipmap-xhdpi' = 216; 'mipmap-xxhdpi' = 324; 'mipmap-xxxhdpi' = 432 }
foreach ($d in $foreDensities.GetEnumerator()) {
    $size = $d.Value
    $bm = New-Canvas $size
    $gr = [System.Drawing.Graphics]::FromImage($bm); Setup-Gr $gr
    $dw = [int]([math]::Round($size * 0.58))
    $dh = [int]([math]::Round($dw * $cropH / $cropW))
    $dx = [int](($size - $dw) / 2); $dy = [int](($size - $dh) / 2)
    $gr.DrawImage($crop, $dx, $dy, $dw, $dh)
    $gr.Dispose()
    $dir = Join-Path $resDir $d.Key
    New-Item -ItemType Directory -Force $dir | Out-Null
    $bm.Save((Join-Path $dir 'ic_launcher_foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
    $bm.Dispose()
    Write-Host "Foreground $($d.Key): $size px"
}

# ---- 3) أيقونة Play 512 (مربعة كاملة بخلفية كريمية، بلا شفافية) ----
$play = New-Canvas 512
$gr = [System.Drawing.Graphics]::FromImage($play); Setup-Gr $gr
$gr.Clear([System.Drawing.Color]::FromArgb(250, 248, 245))
$dw = [int](512 * 0.80)
$dh = [int]($dw * $cropH / $cropW)
$gr.DrawImage($crop, [int]((512-$dw)/2), [int]((512-$dh)/2), $dw, $dh)
$gr.Dispose()
$play.Save((Join-Path $outDir 'play_icon_512.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$play.Dispose()

# ---- 4) Feature Graphic 1024x500 خلفية كريمية + سطور ذهبية + الكلمة في النص ----
$fg = New-Object System.Drawing.Bitmap(1024, 500, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gr = [System.Drawing.Graphics]::FromImage($fg); Setup-Gr $gr
$gr.Clear([System.Drawing.Color]::FromArgb(250, 248, 245))
$burgundy = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(139, 0, 27))
$gold = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(212, 175, 55), 3)
# سطر ذهبي شوفة بماسة في النص أعلى وأسفل
foreach ($yy in @(70, 430)) {
    $gr.DrawLine($gold, 200, $yy, 380, $yy)  # يمين
    $gr.DrawLine($gold, 644, $yy, 824, $yy)  # يسار
    # ماسة dzw
    $pts = @(
        (New-Object System.Drawing.Point(512, ($yy-14))),
        (New-Object System.Drawing.Point(526, $yy)),
        (New-Object System.Drawing.Point(512, ($yy+14))),
        (New-Object System.Drawing.Point(498, $yy))
    )
    $gr.FillPolygon($burgundy, $pts)
}
$dw = [int](1024 * 0.62)
$dh = [int]($dw * $cropH / $cropW)
$gr.DrawImage($crop, [int]((1024-$dw)/2), [int]((500-$dh)/2), $dw, $dh)
$gr.Dispose(); $gold.Dispose(); $burgundy.Dispose()
$fg.Save((Join-Path $outDir 'feature_graphic_1024x500.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$fg.Dispose()

$src.Dispose(); $crop.Dispose()
Write-Host "DONE -> store_assets"
