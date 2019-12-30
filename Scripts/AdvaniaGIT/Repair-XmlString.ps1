function Repair-XmlString
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$inXML
  )

  # Match all characters that does NOT belong in an XML document
  $rPattern = "[^\x09\x0A\x0D\x20-\xD7FF\xE000-\xFFFD\x10000\x10FFFF]"  

  # Replace said characters with [String]::Empty and return
  return [System.Text.RegularExpressions.Regex]::Replace($inXML,$rPattern,"")
}