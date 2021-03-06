<# 
 .SYNOPSIS 
 Returns a [pscustomobject] NoteProperties as an array along with the property type 

.DESCRIPTION 
 Returns a [pscustomobject] NoteProperties as an array along with the property type.
Used for dynamic interrogation of an object 

.PARAMETER Object 
 string Parameter_Object=string Parameter_Object=string Parameter_Object=string Parameter_Object=Parameter_Object=Object is a mandatory parameter of type System.Object; takes in a [pscustomobject] 

.EXAMPLE 
 Get-PSObjectParamTypes $object returns array of noteproperties objects and types. 

.NOTES 
 Author: Mentaleak 

#> 
function Get-PSObjectParamTypes () {
 
	param(
		[Parameter(mandatory = $true)] [object]$Object
	)

	if ($Object.GetType().BaseType.Name -eq "object") {
		$NoteProperties = $object | Get-Member -MemberType NoteProperty
		foreach ($property in $NoteProperties)
		{
			$Pdefinition = $property.Definition.split(" ")
			$PType = $Pdefinition[0]
			if ($PType -eq "RuntimeType") {
				$PType = $Pdefinition[1].split(".",2)[1]
			}

			Add-Member -InputObject $property -MemberType NoteProperty -Name "Type" -Value $PType
		}
		return $NoteProperties
	}
	return $null
}
