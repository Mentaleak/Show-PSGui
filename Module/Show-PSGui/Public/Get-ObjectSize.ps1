<# 
 .SYNOPSIS 
 Returns the size of a form control object 

.DESCRIPTION 
 Returns a measurement object (height and width) of a system.Windows.Forms.<SOMETHING> object.
It is used for dynamic placement within a form. 

.PARAMETER control 
 string Parameter_control=control is a parameter of type System.Object, must be a windows.forms.control type object 

.EXAMPLE 
 $lbltest = New-Object system.Windows.Forms.Label $lbltest.text = "TESTING123" $lbltest.AutoSize = $true Get-ObjectSize -control ($lbltest) This will return a measurement object with the width and height needed for $lbltest. 

.NOTES 
 Author: Mentaleak 

#> 
function Get-ObjectSize () {
 
	param(
		$control
	)
	Add-Type -Assembly System.Drawing
	$BlankImage = New-Object System.Drawing.Bitmap (500,500)
	$gr = [System.Drawing.Graphics]::FromImage($BlankImage)
	return $gr.MeasureString("$($control.text)",$($control.Font))
}
