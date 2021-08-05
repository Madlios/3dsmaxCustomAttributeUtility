rollout renameMorph "Rename Morph Channels"
(
label info "First select your object."
edittext orgStrText "Replace:"
radiobuttons radiofix labels:#("Prefix", "Sufix") columns:2
edittext replaceStrText "With:"
label tip "Tips: Leave empty to remove rather then replace."
button run "Do it!"

on run pressed do
(
orgStr = orgStrText.text
replaceStr = trimleft replaceStrText.text
print orgStr
print replaceStr

for i = 1 to 100 do
(
oldName = WM3_MC_GetName$.modifiers[#Morpher] i
if oldName != "- empty -" do
(
str = DotNetObject "System.String" oldName
if orgStr.count < oldName.count do
(
if radiofix.state == 1 then
(
prefix = str.remove orgStr.count
if orgStr == prefix do
(
newName = str.remove 0 orgStr.count
newName = replaceStr + newName
WM3_MC_SetName$.modifiers[#Morpher] i newName
)
)
else if radiofix.state == 2 do
(
start = oldName.count - orgStr.count
sufix = str.remove 0 start
if orgStr == sufix do
(
newName = str.remove start
newName = newName + replaceStr
WM3_MC_SetName$.modifiers[#Morpher] i newName
)
)
)
)
)
)
)
renameMorphFloater = newRolloutFloater "Rename Morph Channels" 300 165
addRollout renameMorph renameMorphFloater