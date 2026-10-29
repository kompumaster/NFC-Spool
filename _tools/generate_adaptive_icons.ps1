Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $root 'logo\gen02.png'
$resRoot = Join-Path $root 'android\app\src\main\res'

# Adaptive icon layers are 108dp; keep the badge inside the 72dp safe zone.
# The source badge occupies about 0.89 of the image height including the shadow,
# so an 84dp square leaves the badge itself just inside 72dp.
$densitySizes = @{
    'mdpi'    = 108
    'hdpi'    = 162
    'xhdpi'   = 216
    'xxhdpi'  = 324
    'xxxhdpi' = 432
}

$source = [System.Drawing.Bitmap]::FromFile($sourcePath)
try {
    foreach ($density in $densitySizes.Keys) {
        $canvas = $densitySizes[$density]
        $drawSize = [int][math]::Round($canvas * 84.0 / 108.0)
        $offset = [int][math]::Round(($canvas - $drawSize) / 2.0)

        $bitmap = New-Object System.Drawing.Bitmap($canvas, $canvas, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([System.Drawing.Color]::White)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.DrawImage($source, $offset, $offset, $drawSize, $drawSize)
        } finally {
            $graphics.Dispose()
        }

        $directory = Join-Path $resRoot ("mipmap-" + $density)
        $target = Join-Path $directory 'ic_launcher_foreground.png'
        $bitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
        Write-Output ("wrote " + $target + " " + $canvas + "x" + $canvas + " logo=" + $drawSize)
    }
} finally {
    $source.Dispose()
}
