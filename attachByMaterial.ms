mtl = #() ; tmp = #() ; final = #()
sel = selection as array

if sel.count != 0 then
(
	for i in sel do
	(
		convertTo i Editable_Poly
		--append all materials of selection to the mtl array:
		if findItem mtl i.material == 0 do (
			append mtl i.material
		)
	)
	for m in mtl do
	(
		tmp = for i in sel where i.material == m collect i -- tmp stores all objects with the same material
		append final tmp -- append tmp array to final array
	)
	for i in final do
	(
		if i.count >= 1 do
		(
			mainobject = i[1] --first index will be the mainobject to attach to
			for j in i do (
				mainobject.EditablePoly.attach j mainobject
			)
		)

	)
)