<# 
 .SYNOPSIS 
 Shows a gui for a [pscustomobject] that a user can fill out. 

.DESCRIPTION 
 Shows a gui for a [pscustomobject] that a user can fill out. Then returns a copy of the object with values set to the users input..
Using `n in the value for a string field will make a multi-line textbox. 

.PARAMETER font 
 string Parameter_font= string Parameter_font=string Parameter_font=string Parameter_font=Parameter_font=font is a parameter of type string, must be a valid font string ex. 'Microsoft Sans Serif,10' 

.PARAMETER height 
 string Parameter_height=string Parameter_height=string Parameter_height=string Parameter_height=Parameter_height=height is a parameter of type int, this will auto resize so it is not necessary 

.PARAMETER object 
 string Parameter_object=object is a parameter of type [pscustomobject] is the object you would like to generate a gui for 

.PARAMETER showbreak 
 string Parameter_showbreak=string Parameter_showbreak=showbreak is a parameter of type switch, displays a breakall button that returns a value "Cancel All" that can be picked up by parent code. 

.PARAMETER title 
 string Parameter_title=string Parameter_title=string Parameter_title=string Parameter_title=Parameter_title=title is a parameter of type string, name for the form 

.PARAMETER width 
 string Parameter_width=string Parameter_width=string Parameter_width=string Parameter_width=Parameter_width=width is a parameter of type int, this will auto resize so it is not necessary 

.EXAMPLE 
 Show-Psgui -Object $object -Title "INPUT DATA" Will show a gui for  $object  then return the input values 

.NOTES 
 Author: Mentaleak 

#> 
function Show-Psgui () {
 
	param(
		$object,
		[int]$height = 600,
		[int]$width = 600,
		[string]$font = 'Microsoft Sans Serif,10',
		[string]$title = "Input",
		[switch]$showbreak
	)
	$tmpobj = New-Object pscustomobject
	$Form = New-Object system.Windows.Forms.Form
	#TODO automate width and height
	$Form.ClientSize = "$width,$height"
	$Form.text = "Form"
	$Form.TopMost = $false

	$NoteProperties = Get-PSObjectParamTypes $object
	$currentX = 15
	$currentY = 15
	$maxFieldWidths = 0
	$fields = @()
	$fieldCount = 0

	#get biggest label
	$labelwidth = 0
	($NoteProperties | Where-Object { $_.type -ne "bool" }) | ForEach-Object { if ((Get-StringSize -Font $font -String "[$($_.Type)] $($_.Name)").width -gt $labelwidth) { $labelwidth = [math]::Ceiling((Get-StringSize -Font $font -String "[$($_.Type)] $($_.Name)").width) } }
	$labelwidth += 5
    
    $Textboxwidth = 0
	($NoteProperties | Where-Object { $_.type -ne "bool" }) | ForEach-Object { if ((Get-StringSize -Font $font -String "$($object."$($_.Name)")").width -gt $Textboxwidth) { $Textboxwidth = [math]::Ceiling((Get-StringSize -Font $font -String "$($object."$($_.Name)")").width) } }
	$Textboxwidth += 5
    if($Textboxwidth -lt 400){
        $Textboxwidth = 400
    }

	foreach ($NP in $NoteProperties)
	{
		Add-Member -InputObject $tmpobj -MemberType NoteProperty -Name "$($np.Name)" -Value ($object."$($np.Name)")
		switch ($NP.type) {
			{ ($_ -eq "bool") -or ($_ -eq "boolean") } {
				New-Variable -Name "Checkbox_$($np.Name)" -Value (New-Object system.Windows.Forms.CheckBox)
				(Get-Variable -Name "Checkbox_$($np.Name)").Value.text = "$($np.Name)"
				(Get-Variable -Name "Checkbox_$($np.Name)").Value.AutoSize = $false
				(Get-Variable -Name "Checkbox_$($np.Name)").Value.location = New-Object System.Drawing.Point ($currentX,$currentY)
				(Get-Variable -Name "Checkbox_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'
				(Get-Variable -Name "Checkbox_$($np.Name)").Value.checked = $object."$($np.Name)"

				#size field
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "Checkbox_$($np.Name)").Value)
				(Get-Variable -Name "Checkbox_$($np.Name)").Value.width = [math]::Ceiling($FontSize.width) + 25
				(Get-Variable -Name "Checkbox_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height) + 5


				#add field to form
				$fields += $getfixobj = [pscustomobject]@{ type = "CheckBox"; Name = "$($np.Name)"; object = ((Get-Variable -Name "CheckBox_$($np.Name)").Value) }
				$currentY = ((Get-Variable -Name "Checkbox_$($np.Name)").Value.height + (Get-Variable -Name "Checkbox_$($np.Name)").Value.location.y) + 5

				if ($maxFieldWidths -lt ((Get-Variable -Name "Checkbox_$($np.Name)").Value.width + (Get-Variable -Name "Checkbox_$($np.Name)").Value.location.x)) {
					$maxFieldWidths = ((Get-Variable -Name "Checkbox_$($np.Name)").Value.width + (Get-Variable -Name "Checkbox_$($np.Name)").Value.location.x) + 15
				}
			}
			string {
				#Create Label field for the string input
				New-Variable -Name "Label_$($np.Name)" -Value (New-Object system.Windows.Forms.Label)
				(Get-Variable -Name "Label_$($np.Name)").Value.text = "[$($np.Type)] $($np.Name)"
				(Get-Variable -Name "Label_$($np.Name)").Value.AutoSize = $false
				(Get-Variable -Name "Label_$($np.Name)").Value.location = New-Object System.Drawing.Point ($currentX,$currentY)
				(Get-Variable -Name "Label_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'

				#size field
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "Label_$($np.Name)").Value)
				(Get-Variable -Name "Label_$($np.Name)").Value.width = $labelwidth
				(Get-Variable -Name "Label_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height)
				#add field to form
				$fields += $getfixobj = [pscustomobject]@{ type = "Label"; Name = "$($np.Name)"; object = ((Get-Variable -Name "Label_$($np.Name)").Value) }



				#Get Position of textbox after label
				$tmpX = $currentX + (Get-Variable -Name "Label_$($np.Name)").Value.width + 5

				#create Textbox element
				New-Variable -Name "TextBox_$($np.Name)" -Value (New-Object system.Windows.Forms.TextBox)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.location = New-Object System.Drawing.Point ($tmpX,$currentY)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'
                (Get-Variable -Name "TextBox_$($np.Name)").Value.width = $Textboxwidth


				#check if input should be multiline              
				if ($object."$($np.Name)".GetType().Name -eq "string") {
					if ($object."$($np.Name)".Contains("`n")) {
						(Get-Variable -Name "TextBox_$($np.Name)").Value.multiline = $true
						(Get-Variable -Name "TextBox_$($np.Name)").Value.Scrollbars = "Vertical"
						(Get-Variable -Name "TextBox_$($np.Name)").Value.text = $object."$($np.Name)"
						(Get-Variable -Name "TextBox_$($np.Name)").Value.height = 75
					}
					(Get-Variable -Name "TextBox_$($np.Name)").Value.text = $object."$($np.Name)"
				}

				#resize textbox
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "TextBox_$($np.Name)").Value)
				
				if ($FontSize.height -lt 20 -and (Get-Variable -Name "TextBox_$($np.Name)").Value.height -lt 20)
				{
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = 20
				}
				elseif ($FontSize.height -ge 20 -and (Get-Variable -Name "TextBox_$($np.Name)").Value.height -lt 20) {
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height) + 3 + ([math]::Ceiling($FontSize.height / 2))
				}

				#add textbox to form
				$fields += $getfixobj = [pscustomobject]@{ type = "TextBox"; Name = "$($np.Name)"; object = ((Get-Variable -Name "TextBox_$($np.Name)").Value) }


				if ($maxFieldWidths -lt ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x)) {
					$maxFieldWidths = ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x) + 15
				}
				$currentY = ((Get-Variable -Name "TextBox_$($np.Name)").Value.height + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.y) + 5


			}
			char {
				#Create Label field for the string input
				New-Variable -Name "Label_$($np.Name)" -Value (New-Object system.Windows.Forms.Label)
				(Get-Variable -Name "Label_$($np.Name)").Value.text = "[$($np.Type)] $($np.Name)"
				(Get-Variable -Name "Label_$($np.Name)").Value.AutoSize = $false
				(Get-Variable -Name "Label_$($np.Name)").Value.location = New-Object System.Drawing.Point ($currentX,$currentY)
				(Get-Variable -Name "Label_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'

				#size field
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "Label_$($np.Name)").Value)
				(Get-Variable -Name "Label_$($np.Name)").Value.width = $labelwidth
				(Get-Variable -Name "Label_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height)
				#add field to form
				$fields += $getfixobj = [pscustomobject]@{ type = "Label"; Name = "$($np.Name)"; object = ((Get-Variable -Name "Label_$($np.Name)").Value) }



				#Get Position of textbox after label
				$tmpX = $currentX + (Get-Variable -Name "Label_$($np.Name)").Value.width + 5

				#create Textbox element
				New-Variable -Name "TextBox_$($np.Name)" -Value (New-Object system.Windows.Forms.TextBox)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.location = New-Object System.Drawing.Point ($tmpX,$currentY)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'
				(Get-Variable -Name "TextBox_$($np.Name)").Value.text = $object."$($np.Name)"
				(Get-Variable -Name "TextBox_$($np.Name)").Value.width = $Textboxwidth
				(Get-Variable -Name "TextBox_$($np.Name)").Value.maxlength = 1

				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "TextBox_$($np.Name)").Value)
				if ($FontSize.height -lt 20)
				{
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = 20
				}
				else {
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height) + 3 + ([math]::Ceiling($FontSize.height / 2))
				}

				#add textbox to form
				$fields += $getfixobj = [pscustomobject]@{ type = "TextBox"; Name = "$($np.Name)"; object = ((Get-Variable -Name "TextBox_$($np.Name)").Value) }


				if ($maxFieldWidths -lt ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x)) {
					$maxFieldWidths = ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x) + 15
				}
				$currentY = ((Get-Variable -Name "TextBox_$($np.Name)").Value.height + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.y) + 5

			}
			int {
				#Create Label field for the string input
				New-Variable -Name "Label_$($np.Name)" -Value (New-Object system.Windows.Forms.Label)
				(Get-Variable -Name "Label_$($np.Name)").Value.text = "[$($np.Type)] $($np.Name)"
				(Get-Variable -Name "Label_$($np.Name)").Value.AutoSize = $false
				(Get-Variable -Name "Label_$($np.Name)").Value.location = New-Object System.Drawing.Point ($currentX,$currentY)
				(Get-Variable -Name "Label_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'

				#size field
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "Label_$($np.Name)").Value)
				(Get-Variable -Name "Label_$($np.Name)").Value.width = $labelwidth
				(Get-Variable -Name "Label_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height)
				#add field to form
				$fields += $getfixobj = [pscustomobject]@{ type = "Label"; Name = "$($np.Name)"; object = ((Get-Variable -Name "Label_$($np.Name)").Value) }



				#Get Position of textbox after label
				$tmpX = $currentX + (Get-Variable -Name "Label_$($np.Name)").Value.width + 5

				#create Textbox element
				New-Variable -Name "TextBox_$($np.Name)" -Value (New-Object system.Windows.Forms.TextBox)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.location = New-Object System.Drawing.Point ($tmpX,$currentY)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'
				(Get-Variable -Name "TextBox_$($np.Name)").Value.text = $object."$($np.Name)"
				(Get-Variable -Name "TextBox_$($np.Name)").Value.width = $Textboxwidth
				(Get-Variable -Name "TextBox_$($np.Name)").Value.maxlength = 10

				(Get-Variable -Name "TextBox_$($np.Name)").Value.add_TextChanged({
						#Found at https://stackoverflow.com/questions/38404631/limiting-text-box-entry-to-numbers-or-numpad-only-no-special-characters
						# Check if Text contains any non-Digits
						$Global:ta = $this
						if ($this.text -match '\D') {
							# If so, remove them
							$this.text = $this.text -replace '\D'
							# If Text still has a value, move the cursor to the end of the number
							if ($this.text.Length -gt 0) {
								$this.Focus()
								$this.SelectionStart = $this.text.Length
							}
						}

					})

				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "TextBox_$($np.Name)").Value)
				if ($FontSize.height -lt 20)
				{
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = 20
				}
				else {
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height) + 3 + ([math]::Ceiling($FontSize.height / 2))
				}

				#add textbox to form
				$fields += $getfixobj = [pscustomobject]@{ type = "TextBox"; Name = "$($np.Name)"; object = ((Get-Variable -Name "TextBox_$($np.Name)").Value) }


				if ($maxFieldWidths -lt ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x)) {
					$maxFieldWidths = ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x) + 15
				}
				$currentY = ((Get-Variable -Name "TextBox_$($np.Name)").Value.height + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.y) + 5

			}
			long {
				#Create Label field for the string input
				New-Variable -Name "Label_$($np.Name)" -Value (New-Object system.Windows.Forms.Label)
				(Get-Variable -Name "Label_$($np.Name)").Value.text = "[$($np.Type)] $($np.Name)"
				(Get-Variable -Name "Label_$($np.Name)").Value.AutoSize = $false
				(Get-Variable -Name "Label_$($np.Name)").Value.location = New-Object System.Drawing.Point ($currentX,$currentY)
				(Get-Variable -Name "Label_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'

				#size field
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "Label_$($np.Name)").Value)
				(Get-Variable -Name "Label_$($np.Name)").Value.width = $labelwidth
				(Get-Variable -Name "Label_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height)
				#add field to form
				$fields += $getfixobj = [pscustomobject]@{ type = "Label"; Name = "$($np.Name)"; object = ((Get-Variable -Name "Label_$($np.Name)").Value) }



				#Get Position of textbox after label
				$tmpX = $currentX + (Get-Variable -Name "Label_$($np.Name)").Value.width + 5

				#create Textbox element
				New-Variable -Name "TextBox_$($np.Name)" -Value (New-Object system.Windows.Forms.TextBox)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.location = New-Object System.Drawing.Point ($tmpX,$currentY)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'
				(Get-Variable -Name "TextBox_$($np.Name)").Value.text = $object."$($np.Name)"
				(Get-Variable -Name "TextBox_$($np.Name)").Value.width = 200
				(Get-Variable -Name "TextBox_$($np.Name)").Value.maxlength = 19

				(Get-Variable -Name "TextBox_$($np.Name)").Value.add_TextChanged({
						#Found at https://stackoverflow.com/questions/38404631/limiting-text-box-entry-to-numbers-or-numpad-only-no-special-characters
						# Check if Text contains any non-Digits
						$Global:ta = $this
						if ($this.text -match '\D') {
							# If so, remove them
							$this.text = $this.text -replace '\D'
							# If Text still has a value, move the cursor to the end of the number
							if ($this.text.Length -gt 0) {
								$this.Focus()
								$this.SelectionStart = $this.text.Length
							}
						}

					})

				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "TextBox_$($np.Name)").Value)
				if ($FontSize.height -lt 20)
				{
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = 20
				}
				else {
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height) + 3 + ([math]::Ceiling($FontSize.height / 2))
				}

				#add textbox to form
				$fields += $getfixobj = [pscustomobject]@{ type = "TextBox"; Name = "$($np.Name)"; object = ((Get-Variable -Name "TextBox_$($np.Name)").Value) }


				if ($maxFieldWidths -lt ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x)) {
					$maxFieldWidths = ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x) + 15
				}
				$currentY = ((Get-Variable -Name "TextBox_$($np.Name)").Value.height + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.y) + 5

			}
			{ ($_ -eq "double") -or ($_ -eq "decimal") -or ($_ -eq "single") } {
				#Create Label field for the string input
				New-Variable -Name "Label_$($np.Name)" -Value (New-Object system.Windows.Forms.Label)
				(Get-Variable -Name "Label_$($np.Name)").Value.text = "[$($np.Type)] $($np.Name)"
				(Get-Variable -Name "Label_$($np.Name)").Value.AutoSize = $false
				(Get-Variable -Name "Label_$($np.Name)").Value.location = New-Object System.Drawing.Point ($currentX,$currentY)
				(Get-Variable -Name "Label_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'

				#size field
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "Label_$($np.Name)").Value)
				(Get-Variable -Name "Label_$($np.Name)").Value.width = $labelwidth
				(Get-Variable -Name "Label_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height)
				#add field to form
				$fields += $getfixobj = [pscustomobject]@{ type = "Label"; Name = "$($np.Name)"; object = ((Get-Variable -Name "Label_$($np.Name)").Value) }



				#Get Position of textbox after label
				$tmpX = $currentX + (Get-Variable -Name "Label_$($np.Name)").Value.width + 5

				#create Textbox element
				New-Variable -Name "TextBox_$($np.Name)" -Value (New-Object system.Windows.Forms.TextBox)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.location = New-Object System.Drawing.Point ($tmpX,$currentY)
				(Get-Variable -Name "TextBox_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'
				(Get-Variable -Name "TextBox_$($np.Name)").Value.text = $object."$($np.Name)"
                Write-Verbose "TextBox_$($np.Name) :::: $((Get-Variable -Name "TextBox_$($np.Name)")) :::: $($object."$($np.Name)")"
				Add-Member -InputObject (Get-Variable -Name "TextBox_$($np.Name)").Value -MemberType NoteProperty -Name LastValid -Value $object."$($np.Name)"
				(Get-Variable -Name "TextBox_$($np.Name)").Value.width = $Textboxwidth

				(Get-Variable -Name "TextBox_$($np.Name)").Value.add_TextChanged({
						#check if decimal
						try { [decimal]$this.text }
						catch {
							# If so, remove them
							$this.text = $this.lastvalid
							if ($this.text.Length -gt 0) {
								$this.Focus()
								$this.SelectionStart = $this.text.Length
							}

						}
						$this.lastvalid = $this.text

					})

				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "TextBox_$($np.Name)").Value)
				if ($FontSize.height -lt 20)
				{
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = 20
				}
				else {
					(Get-Variable -Name "TextBox_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height) + 3 + ([math]::Ceiling($FontSize.height / 2))
				}

				#add textbox to form
				$fields += $getfixobj = [pscustomobject]@{ type = "TextBox"; Name = "$($np.Name)"; object = ((Get-Variable -Name "TextBox_$($np.Name)").Value) }


				if ($maxFieldWidths -lt ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x)) {
					$maxFieldWidths = ((Get-Variable -Name "TextBox_$($np.Name)").Value.width + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.x) + 15
				}
				$currentY = ((Get-Variable -Name "TextBox_$($np.Name)").Value.height + (Get-Variable -Name "TextBox_$($np.Name)").Value.location.y) + 5

			}
			datetime {
				#Create Label field for the string input
				New-Variable -Name "Label_$($np.Name)" -Value (New-Object system.Windows.Forms.Label)
				(Get-Variable -Name "Label_$($np.Name)").Value.text = "[$($np.Type)] $($np.Name)"
				(Get-Variable -Name "Label_$($np.Name)").Value.AutoSize = $false
				(Get-Variable -Name "Label_$($np.Name)").Value.location = New-Object System.Drawing.Point ($currentX,$currentY)
				(Get-Variable -Name "Label_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'

				#size field
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "Label_$($np.Name)").Value)
				(Get-Variable -Name "Label_$($np.Name)").Value.width = $labelwidth
				(Get-Variable -Name "Label_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height)
				#add field to form

				$fields += $getfixobj = [pscustomobject]@{ type = "Label"; Name = "$($np.Name)"; object = ((Get-Variable -Name "Label_$($np.Name)").Value) }



				#Get Position of textbox after label
				$tmpX = $currentX + (Get-Variable -Name "Label_$($np.Name)").Value.width + 5

				#create Textbox element
				New-Variable -Name "DateTimePicker_$($np.Name)" -Value (New-Object System.Windows.Forms.DateTimePicker)
				(Get-Variable -Name "DateTimePicker_$($np.Name)").Value.location = New-Object System.Drawing.Point ($tmpX,$currentY)
				(Get-Variable -Name "DateTimePicker_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'
				try { $basedatetime = [datetime]"$($object."$($np.Name)")" }
				catch { $basedatetime = Get-Date }
				(Get-Variable -Name "DateTimePicker_$($np.Name)").Value.text = $basedatetime
				(Get-Variable -Name "DateTimePicker_$($np.Name)").Value.width = 200
				(Get-Variable -Name "DateTimePicker_$($np.Name)").Value.Format = "Custom"
				(Get-Variable -Name "DateTimePicker_$($np.Name)").Value.CustomFormat = "MM/dd/yyyy hh:mm:ss";

				if ($FontSize.height -lt 20)
				{
					(Get-Variable -Name "DateTimePicker_$($np.Name)").Value.height = 20
				}
				else {
					(Get-Variable -Name "DateTimePicker_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height) + 3 + ([math]::Ceiling($FontSize.height / 2))
				}

				#add textbox to form
				$fields += $getfixobj = [pscustomobject]@{ type = "DateTimePicker"; Name = "$($np.Name)"; object = ((Get-Variable -Name "DateTimePicker_$($np.Name)").Value) }


				if ($maxFieldWidths -lt ((Get-Variable -Name "DateTimePicker_$($np.Name)").Value.width + (Get-Variable -Name "DateTimePicker_$($np.Name)").Value.location.x)) {
					$maxFieldWidths = ((Get-Variable -Name "DateTimePicker_$($np.Name)").Value.width + (Get-Variable -Name "DateTimePicker_$($np.Name)").Value.location.x) + 15
				}
				$currentY = ((Get-Variable -Name "DateTimePicker_$($np.Name)").Value.height + (Get-Variable -Name "DateTimePicker_$($np.Name)").Value.location.y) + 5


			}
			default {
				#Create Label field for the string input
				New-Variable -Name "Label_$($np.Name)" -Value (New-Object system.Windows.Forms.Label)
				(Get-Variable -Name "Label_$($np.Name)").Value.text = "[$($np.Type)] $($np.Name)      Unhandled Data TYPE"
				(Get-Variable -Name "Label_$($np.Name)").Value.AutoSize = $true
				(Get-Variable -Name "Label_$($np.Name)").Value.location = New-Object System.Drawing.Point ($currentX,$currentY)
				(Get-Variable -Name "Label_$($np.Name)").Value.Font = 'Microsoft Sans Serif,10'

				#size field
				$FontSize = Get-ObjectSize -control ((Get-Variable -Name "Label_$($np.Name)").Value)
				(Get-Variable -Name "Label_$($np.Name)").Value.height = [math]::Ceiling($FontSize.height)
				#add field to form
				$fields += $getfixobj = [pscustomobject]@{ type = "Label"; Name = "$($np.Name)"; object = ((Get-Variable -Name "Label_$($np.Name)").Value) }

				if ($maxFieldWidths -lt ((Get-Variable -Name "Label_$($np.Name)").Value.width + (Get-Variable -Name "Label_$($np.Name)").Value.location.x)) {
					$maxFieldWidths = ((Get-Variable -Name "Label_$($np.Name)").Value.width + (Get-Variable -Name "Label_$($np.Name)").Value.location.x) + 15
				}
				$currentY = ((Get-Variable -Name "Label_$($np.Name)").Value.height + (Get-Variable -Name "Label_$($np.Name)").Value.location.y) + 5
			}


		}

	}
	$ButtonSave = New-Object system.Windows.Forms.Button
	$ButtonSave.text = "Save"
	$ButtonSave.width = 60
	$ButtonSave.height = 30
	$ButtonSave.location = New-Object System.Drawing.Point (15,$currentY)
	$ButtonSave.Font = 'Microsoft Sans Serif,10'
	$form.Controls.Add($ButtonSave)

	$ButtonCancel = New-Object system.Windows.Forms.Button
	$ButtonCancel.text = "Cancel"
	$ButtonCancel.width = 60
	$ButtonCancel.height = 30
	$ButtonCancel.location = New-Object System.Drawing.Point (90,$currentY)
	$ButtonCancel.Font = 'Microsoft Sans Serif,10'
	$form.Controls.Add($ButtonCancel)


	if ($showbreak) {
		$ButtonCancelAll = New-Object system.Windows.Forms.Button
		$ButtonCancelAll.text = "Cancel All"
		$ButtonCancelAll.width = 60
		$ButtonCancelAll.height = 40
		$ButtonCancelAll.location = New-Object System.Drawing.Point (165,$currentY)
		$ButtonCancelAll.Font = 'Microsoft Sans Serif,10'
		$form.Controls.Add($ButtonCancelAll)
		$ButtonCancelAll.Add_Click({ $ButtonSave.text = "Canceled"; $form.close() })
	}

	$form.text = $title
	$Form.width = $maxFieldWidths + 30
	$Form.height = $currentY + 90
	$form.Controls.AddRange($fields.object)
	$ButtonSave.Add_Click({

			$listOFinputs = $fields | Where-Object { $_.type -ne "Label" }
			foreach ($field in $listofInputs) {

				switch ($field.type) {
					CheckBox
					{
						$tmpobj."$($field.Name)" = $field.object.checked
					}
					TextBox
					{
						$tmpobj."$($field.Name)" = $field.object.text
					}
					DateTimePicker
					{
						$tmpobj."$($field.Name)" = $field.object.text
					}
				}
			}
			$ButtonSave.text = "Saved"
			$form.close()
		})
	$ButtonCancel.Add_Click({ $form.close() })


	$newThread = [powershell]::Create()
	$newThread.AddScript($form.showDialog()) | Out-Null
	$handle = $newThread.BeginInvoke()

	#[void]$Form.ShowDialog()
	if (($ButtonSave.text -eq "Canceled")) { return "Cancel All" }
	elseif (($ButtonSave.text -eq "Saved")) { return $tmpobj }


}
