$RGName = "Tgr-Tmp"

New-AzResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile iaac.json 
