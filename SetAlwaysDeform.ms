rollout updateSkinModifier "Skin Modifier"
(
	checkbox alwaysDeform "Always Deform"
	Button applyChanges "Apply Changes"
	
	-- START applyChanges button
	on applyChanges pressed do
	(
		for i = 1 to selection.count do 
		(
			selection[i].modifiers[#Skin].always_deform=alwaysDeform.checked
		)
	)
	-- END applyChanges button
)
floaterWindow = newRolloutFloater "Update Parameters" 300 165
addRollout updateSkinModifier floaterWindow