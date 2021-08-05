-- stdMat = StandardMaterial()

-- for p in GetPropNames(stdMat) do (
-- 	prop = getProperty stdMat p
-- 	print ((p as string) + ": " + ((classof prop) as string))
-- )

for j = 1 to selection.count do 
(
	obj = selection[j]
	
	-- for multimat materials
	if (classof obj.mat==Multimaterial) then ( 
		materials = obj.mat.materialList
		for i = 1 to materials.count do 
		(
			print materials[i].name
			if (classof materials[i] == Physical_Material) then (

				-- for bump map we remove intermediate node
				bumpMap = materials[i].bump_map
				if (classof bumpMap==VRayBump2Normal) then (
					bumpMap = bumpMap.bump_map
					print "...converted"
				)
				materials[i].bump_map = bumpMap
			)
		)
	)
	
	-- for single vray materials directly
	if (classof obj.mat == Physical_Material) then (

		-- for bump map we remove intermediate node
		bumpMap = obj.mat.bump_map
		if (classof bumpMap==VRayBump2Normal) then (
			bumpMap = bumpMap.bump_map
			print "...converted"
		)
		obj.mat.bump_map = bumpMap
	)
)