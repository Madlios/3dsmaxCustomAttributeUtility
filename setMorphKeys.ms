morphs = #("browDownLeft","browDownRight","browInnerUp","browOuterUpLeft","browOuterUpRight","cheekPuff","eyeSquintLeft","eyeSquintRight","eyeBlinkLeft","eyeBlinkRight","eyeLookDownLeft","eyeLookDownRight","eyeLookInLeft","eyeLookInRight","eyeLookOutLeft","eyeLookOutRight","eyeLookUpLeft","eyeLookUpRight","cheekSquintLeft","cheekSquintRight","eyeWideLeft","eyeWideRight","jawForward","jawLeft","jawRight","jawOpen","mouthClose","mouthDimpleLeft","mouthDimpleRight","mouthFrownLeft","mouthFrownRight","mouthFunnel","mouthLeft","mouthLowerDownLeft","mouthLowerDownRight","mouthPressLeft","mouthPressRight","mouthPucker","mouthRight","mouthRollLower","mouthRollUpper","mouthShrugLower","mouthShrugUpper","mouthSmileLeft","mouthSmileRight","mouthStretchLeft","mouthStretchRight","mouthUpperUpLeft","mouthUpperUpRight","noseSneerLeft","noseSneerRight","tongueOut")
keys = #(16,15,14,13,12,11,10,9,20,19,6,5,4,3,2,1,50,27,42,32,51,28,36,37,29,33,30,24,46,47,38,48,31,23,49,39,43)

morphMod = selection[1].modifiers["morpher"]

-- set keys
for i = 1 to 52 do
(
	morphName = WM3_MC_GetName morphMod i
	
	-- add key for each frame
	if morphName!="- empty -" then 
	(
		for x = 1 to 52 do
		(
			addNewKey morphMod[i].controller x
		)
	)
	
	notFound = true
	for j = 1 to morphs.count do 
	(	
		if (morphName==morphs[j]) then
		(
			print ("Setting morph " + morphName)
			notFound = false
			
			-- set key at specific time
			slidertime = j
			with animate on
			(
				WM3_MC_SetValue morphMod i 100.0  --sets the key of the first morph channel to 100%
			)
		)
	)
	if notFound and  morphName!="- empty -" then 
	(
		print ("Cannot find morph " + morphName)
	)
)