for i = 1 to 100 do
(
oldName = WM3_MC_GetName$.modifiers[#Morpher] i
if oldName != "- empty -" do
(
print oldName
)
)