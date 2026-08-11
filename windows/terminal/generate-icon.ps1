#Requires -Version 5.1
<#
.SYNOPSIS
    Redraws fish.png, the Windows Terminal tab icon.
.DESCRIPTION
    Draws the prompt's own motif with GDI+ primitives rather than box-drawing
    characters, so the result doesn't depend on a font being installed.
#>
[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'fish.png'),
    [int]$Size = 256
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$background = [System.Drawing.ColorTranslator]::FromHtml('#0d1512')
$phosphor = [System.Drawing.ColorTranslator]::FromHtml('#3ef08c')

$bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
try {
    $graphics.SmoothingMode = 'AntiAlias'
    $graphics.Clear([System.Drawing.Color]::Transparent)

    # Rounded panel. GDI+ has no rounded-rect primitive, so build the path from arcs.
    $radius = [int]($Size * 0.18)
    $inset = [int]($Size * 0.02)
    $edge = $Size - (2 * $inset)
    $diameter = $radius * 2

    $panel = New-Object System.Drawing.Drawing2D.GraphicsPath
    $panel.AddArc($inset, $inset, $diameter, $diameter, 180, 90)
    $panel.AddArc($inset + $edge - $diameter, $inset, $diameter, $diameter, 270, 90)
    $panel.AddArc($inset + $edge - $diameter, $inset + $edge - $diameter, $diameter, $diameter, 0, 90)
    $panel.AddArc($inset, $inset + $edge - $diameter, $diameter, $diameter, 90, 90)
    $panel.CloseFigure()

    $panelBrush = New-Object System.Drawing.SolidBrush($background)
    $graphics.FillPath($panelBrush, $panel)

    $stroke = [single]($Size * 0.070)
    $pen = New-Object System.Drawing.Pen($phosphor, $stroke)
    $pen.StartCap = 'Round'
    $pen.EndCap = 'Round'

    $left = [single]($Size * 0.30)
    $top = [single]($Size * 0.28)
    $bottom = [single]($Size * 0.72)

    # Left rail joining the two prompt rows.
    $graphics.DrawLine($pen, $left, $top, $left, $bottom)
    $graphics.DrawLine($pen, $left, $top, [single]($Size * 0.46), $top)
    $graphics.DrawLine($pen, $left, $bottom, [single]($Size * 0.52), $bottom)

    # Arrow head on the input row.
    $tip = [single]($Size * 0.76)
    $arrowBack = [single]($Size * 0.56)
    $spread = [single]($Size * 0.105)
    $arrow = @(
        (New-Object System.Drawing.PointF($arrowBack, ($bottom - $spread)))
        (New-Object System.Drawing.PointF($tip, $bottom))
        (New-Object System.Drawing.PointF($arrowBack, ($bottom + $spread)))
    )
    $arrowBrush = New-Object System.Drawing.SolidBrush($phosphor)
    $graphics.FillPolygon($arrowBrush, $arrow)

    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "wrote $OutputPath ($Size x $Size)"
}
finally {
    foreach ($resource in @($pen, $panelBrush, $arrowBrush, $panel, $graphics, $bitmap)) {
        if ($resource) { $resource.Dispose() }
    }
}
