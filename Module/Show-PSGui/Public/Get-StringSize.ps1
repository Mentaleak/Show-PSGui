<# 
 .SYNOPSIS 
 Returns a measurement object with the width and height needed for the string at the with the given font 

.DESCRIPTION 
 Returns a measurement object with the width and height needed for the string at the with the given font
Used for dynamic font sizing 

.PARAMETER Font 
 string Parameter_Font=string Parameter_Font=string Parameter_Font=string Parameter_Font=Parameter_Font=Font is a mandatory parameter of type string, must be a valid font string ex: 'Microsoft Sans Serif,10' 

.PARAMETER String 
 string Parameter_String= string Parameter_String=string Parameter_String=string Parameter_String=Parameter_String=String is a mandatory parameter of type string, any text you would like to measure the size of 

.EXAMPLE 
 $font = 'Microsoft Sans Serif,10' $string="TEST12345" Get-StringSize -Font $font -String $string Returns a size object for $string given the $font 

.NOTES 
 Author: Mentaleak 

#> 
function Get-StringSize () {
 
	param(
		[Parameter(mandatory = $true)] [string]$String,
		[Parameter(mandatory = $true)] [string]$Font
	)
	Add-Type -Assembly System.Drawing
	$BlankImage = New-Object System.Drawing.Bitmap (500,500)
	$gr = [System.Drawing.Graphics]::FromImage($BlankImage)
	return $gr.MeasureString("$($string)",$($font))
}
