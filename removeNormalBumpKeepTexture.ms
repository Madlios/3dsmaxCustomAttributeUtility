for j = 1 to selection.count do 
(
	obj = selection[j]
	if (classof obj.mat==Multimaterial) then ( 
		materials = obj.mat.materialList
		for i = 1 to materials.count do 
		(
			if (classof materials[i] == PhysicalMaterial) then (
				if (classof materials[i].bump_map==Normal_Bump) then (
					normalTextureMap = materials[i].bump_map.normal_map 
					materials[i].bump_map = normalTextureMap
				)
			)
		)
	)
)