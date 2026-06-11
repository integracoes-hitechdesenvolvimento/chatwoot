param(
  [string]$SourcePath,
  [string]$LogoOutput,
  [string]$IconOutput,
  [int]$Threshold = 240
)

Add-Type -AssemblyName System.Drawing

function Remove-WhiteBackground {
  param([string]$InputPath, [string]$OutputPath, [int]$WhiteThreshold)

  $bitmap = [System.Drawing.Bitmap]::FromFile($InputPath)
  $format = [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  $output = New-Object System.Drawing.Bitmap($bitmap.Width, $bitmap.Height, $format)

  $rect = New-Object System.Drawing.Rectangle 0, 0, $bitmap.Width, $bitmap.Height
  $srcData = $bitmap.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, $bitmap.PixelFormat)
  $dstData = $output.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, $format)

  $bytes = [Math]::Abs($srcData.Stride) * $bitmap.Height
  $srcBuffer = New-Object byte[] $bytes
  $dstBuffer = New-Object byte[] $bytes
  [System.Runtime.InteropServices.Marshal]::Copy($srcData.Scan0, $srcBuffer, 0, $bytes)

  for ($i = 0; $i -lt $bytes; $i += 4) {
    $b = $srcBuffer[$i]
    $g = $srcBuffer[$i + 1]
    $r = $srcBuffer[$i + 2]

    if ($r -ge $WhiteThreshold -and $g -ge $WhiteThreshold -and $b -ge $WhiteThreshold) {
      $dstBuffer[$i] = 0
      $dstBuffer[$i + 1] = 0
      $dstBuffer[$i + 2] = 0
      $dstBuffer[$i + 3] = 0
    } else {
      $dstBuffer[$i] = $b
      $dstBuffer[$i + 1] = $g
      $dstBuffer[$i + 2] = $r
      $dstBuffer[$i + 3] = 255
    }
  }

  [System.Runtime.InteropServices.Marshal]::Copy($dstBuffer, 0, $dstData.Scan0, $bytes)
  $bitmap.UnlockBits($srcData)
  $output.UnlockBits($dstData)
  $output.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $bitmap.Dispose()
  $output.Dispose()
}

function Crop-TopRegion {
  param([string]$InputPath, [string]$OutputPath, [double]$HeightRatio = 0.55)

  $bitmap = [System.Drawing.Bitmap]::FromFile($InputPath)
  $cropHeight = [int][Math]::Round($bitmap.Height * $HeightRatio)
  $rect = New-Object System.Drawing.Rectangle 0, 0, $bitmap.Width, $cropHeight
  $pixelFormat = [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  $cropped = $bitmap.Clone($rect, $pixelFormat)
  $cropped.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $bitmap.Dispose()
  $cropped.Dispose()
}

Remove-WhiteBackground -InputPath $SourcePath -OutputPath $LogoOutput -WhiteThreshold $Threshold
Crop-TopRegion -InputPath $LogoOutput -OutputPath $IconOutput -HeightRatio 0.55
Remove-WhiteBackground -InputPath $IconOutput -OutputPath $IconOutput -WhiteThreshold $Threshold

Write-Output "Processed logo assets:"
Write-Output "  $LogoOutput"
Write-Output "  $IconOutput"
