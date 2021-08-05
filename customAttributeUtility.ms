/* -------------------------------------------*/
/* Global context
 */
global g_objects = $*

/* -------------------------------------------*/
/* FUNCTIONS
 */

	/*
	 * Check if an object has attribute with name
	 */
	function hasAttribute obj attrName =
	(
		hasAttr = false
		_defs = custAttributes.getDefs(obj)
		if (_defs!=undefined) then (
			for attr in _defs do 
			(
				-- compare using string names
				if ((attr.name as string)==(attrName as string)) then (
					hasAttr = true
				)
			)
		)
		-- effectively a return ....
		hasAttr
	)
	
	/*
	 * Generate custom attribute definition and add to object
	 * - This can modify and add new params to existing attribute
	 * - Or add new attribute with param to object
	 */
	function generateAttributeDef obj attrName p:"" v:"" addParam:true = 
	(
		local attrDefStr = ""
		local objDef = obj.baseobject.custattributes[attrName]
		if (objDef!=undefined) then (
			-- get def
			objDef = custAttributes.getDef objDef
			
			local params = ""
			local rollouts = ""
			local bHasParam = false
			
			--print ("Original source:\n\t" + objDef.source + "\n---\n")

			pbArray = custAttributes.getPBlockDefs objdef 
			for a = 1 to pbArray.count do 
			( 
				local itms = pbArray [a]   

				for y = 5 to itms.Count do 
				( 
					local paramName = (itms[y][1] as string)
					local paramStr = (itms[y][1] as string)
					local rolloutStr = "edittext " + paramName + " \"" + paramName + "\" type:#string"
					
					-- check to see if we want to redefine a parameter
					if (paramName==p) then ( bHasParam=true )

					for z = 1 to itms[y][2].Count by 2 do 
					( 
						
						-- fix the #(#...) issue with certain string values
						local val = (itms[y][2][z+1] as string)
						val = substituteString val "#(#" ""; val = substituteString val ")" ""
						local key = (itms[y][2][z] as string)
						
						-- specially handle certain types
						case of (
							(key=="default"): val = "\"" + val + "\""
							(key=="type"): val = "#" + val
						)

						paramStr = paramStr + " " + key + ":" + val
					) 
					
					-- we dont wanna include the param when we want to remove it (addParam=false)
					if (not (bHasParam==true and addParam==false)) then (
						params = params + "\t\t" + paramStr + "\n"
						rollouts = rollouts + "\t\t" + rolloutStr + "\n"
					)

				) 
			) 
			
			-- add additional parameter
			if (bHasParam==false and addParam==true) then (
				params = params + "\t\t" + p + " type:#string ui:" + p + " default:\"" + v + "\"\n"
				rollouts = rollouts + "\t\t" + "edittext " + p + " \"" + p + "\" type:#string\n"
			)
			
			attrDefStr = "" + 
			"attributes \"" + attrName + "\"\n" + 
			"(\n" +
				"\tparameters main rollout:params (\n" + 
					params +
				"\t)\n" +
				"\trollout params \"" + attrName + "\" (\n" + 
					rollouts +
				"\t)\n" +
			")"
			
			if (attrDefStr!=objDef.source) then (
				custAttributes.redefine objDef attrDefStr
			)
				
		) else (
			attrDefStr = "" + 
			"attributes \"" + attrName + "\"\n" + 
			"(\n" +
				"\tparameters main rollout:params (\n" + 
					"\t\t" + p + " type:#string ui:" + p + " default:\"" + v + "\"\n" +
				"\t)\n" +
				"\trollout params \"" + attrName + "\" (\n" + 
					"\t\t" + "edittext " + p + " \"" + p + "\" type:#string\n" +
				"\t)\n" +
			")"
			
			if (attrName!="" and p!="" and addParam==true) then (
				-- dummy attribute def so we can redefine
				local _newDef = attributes dummyAttribute
				(
					parameters main rollout:params ( )
					rollout params "dummyAttribute" ( )
				)
				-- redefine
				custAttributes.redefine _newDef attrDefStr
				-- add to object
				custAttributes.add obj _newDef
				-- make unique so we can add again and again
				custAttributes.makeUnique obj _newDef
			)
		)
		-- return
		attrDefStr
	) 

/*
/* FUNCTIONS
 * -------------------------------------------*/


-- script rollout UI
rollout CustomAttributeUtility "Khoa's Custom Attribute Utility"
(

	edittext attrName "Attribute Name"
	edittext attrParamName "Attribute Parameter Name"
	checkbox useParamValue "Use" checked:false across:1
	edittext attrParamValue "Attribute Parameter Value" align:#left
	
	group "Actions" (
		checkbox fromSelection "From Current Selection" checked:true across:1
		
		Button selectObjects "Select Objects" across:4 align:#center
		Button editParameter "Apply Change" align:#center
		Button addParam "Add" align:#center
		Button remParam "Remove" align:#center

		Button deleteAttributes "Delete Attributes" align:#left offset:[10,30]
		
		groupBox theGroupbox "Deletion:" height:50 offset:[0,-45] width:120
	)

	
	-- BEGIN Select objects
	on selectObjects pressed do
	(
		attrNameStr = (attrName.text as string)
		attrParamNameStr = (attrParamName.text as string)
		attrParamValueStr = (attrParamValue.text as string)
		
		-- scope to selected objects only
		if (fromSelection.checked==true) then (
			-- use function instead of $selection as this can be cleared out with deselect
			g_objects = getCurrentSelection() 
		) else (
			g_objects = $*
		)
		
		--deselect everything
		deselect $*
		
		--select objects meeting criteria
		local toSelect=#()
		for obj in g_objects do 
		(
			-- check for attribute name
			if((hasAttribute obj attrNameStr)==true) then
			(

				-- only filter parameter value if its not empty
				if (attrParamNameStr!="") then (
					-- check if we have parameter with same value
					if (hasProperty obj.baseobject.custattributes[attrNameStr] attrParamNameStr) then (

						local paramValue = getProperty obj.baseobject.custattributes[attrNameStr] attrParamNameStr
						if (useParamValue.checked==true) then (
							if (paramValue==attrParamValueStr) then (
								append toSelect obj
							)
						) else (
							append toSelect obj
						)
					)
				-- select all using only attribute name
				) else (
					append toSelect obj
				)
			)
		)
		select toSelect
		
	)
	-- END Select Objects
	
	
	-- BEGIN Edit Parameter
	on editParameter pressed do
	(
		attrNameStr = (attrName.text as string)
		attrParamNameStr = (attrParamName.text as string)
		attrParamValueStr = (attrParamValue.text as string)
		
		-- scope to selected objects only
		if (fromSelection.checked==true) then (
			-- use function instead of $selection as this can be cleared out with deselect
			g_objects = getCurrentSelection() 
		) else (
			g_objects = $*
		)
		
		--select objects meeting criteria
		for obj in g_objects do 
		(
			-- check for attribute name
			if((hasAttribute obj attrNameStr)==true) then
			(

				-- only filter parameter value if its not empty
				if (attrParamNameStr!="") then (
					-- check if we have parameter with same value
					if (hasProperty obj.baseobject.custattributes[attrNameStr] attrParamNameStr) then (
						-- set parameter value
						setProperty obj.baseobject.custattributes[attrNameStr] attrParamNameStr attrParamValueStr
					)
				)
				
			)
			
		)
	)
	-- BEGIN Edit Parameter
	
	-- BEGIN Delete Attributes
	on deleteAttributes pressed do
	(
		attrNameStr = (attrName.text as string)
		attrParamNameStr = (attrParamName.text as string)
		attrParamValueStr = (attrParamValue.text as string)
		
		-- scope to selected objects only
		if (fromSelection.checked==true) then (
			-- use function instead of $selection as this can be cleared out with deselect
			g_objects = getCurrentSelection() 
		) else (
			g_objects = $*
		)
		
		--select objects meeting criteria
		for obj in g_objects do 
		(
			-- check for attribute name
			if((hasAttribute obj attrNameStr)==true) then
			(

				-- only filter parameter value if its not empty
				if (attrParamNameStr!="") then (
					-- check if we have parameter with same value
					if (hasProperty obj.baseobject.custattributes[attrNameStr] attrParamNameStr) then (
						
						local paramValue = getProperty obj.baseobject.custattributes[attrNameStr] attrParamNameStr
						if (useParamValue.checked==true) then (
							if (paramValue==attrParamValueStr) then (
								-- delete all matching attributes
								for attr in custAttributes.getDefs obj where (attr.name as string)==attrNameStr do (
									custAttributes.delete obj attr
								)
							)
						) else (
							-- delete all matching attributes
							for attr in custAttributes.getDefs obj where (attr.name as string)==attrNameStr do (
								custAttributes.delete obj attr
							)
						)
					)
				) else (
					-- delete all matching attributes
					for attr in custAttributes.getDefs obj where (attr.name as string)==attrNameStr do (
						custAttributes.delete obj attr
					)

				)
				
			)
			
		)
	)
	-- BEGIN Delete Attributes
	
	
	-- BEGIN Add Param
	on addParam pressed do
	(
		-- dummy attribute definition
		local _attrDef = attributes dummyAttribute
		(
			parameters main rollout:params ( )
			rollout params "Exhibition" ( )
		)
		
		-- variables
		local attrNameStr = (attrName.text as string)
		local attrParamNameStr = (attrParamName.text as string)
		local attrParamValueStr = (attrParamValue.text as string)
		
		-- scope to selected objects only
		if (fromSelection.checked==true) then (
			-- use function instead of $selection as this can be cleared out with deselect
			g_objects = getCurrentSelection() 
		) else (
			g_objects = $*
		)
		
		--select objects meeting criteria
		for obj in g_objects do 
		(
			generateAttributeDef obj attrNameStr p:attrParamNameStr v:attrParamValueStr addParam:true
		)
		
	)
	-- END Add Param
	
	-- BEGIN Remove Param
	on remParam pressed do
	(
		-- dummy attribute definition
		local _attrDef = attributes dummyAttribute
		(
			parameters main rollout:params ( )
			rollout params "Exhibition" ( )
		)
		
		-- variables
		local attrNameStr = (attrName.text as string)
		local attrParamNameStr = (attrParamName.text as string)
		local attrParamValueStr = (attrParamValue.text as string)
		
		-- scope to selected objects only
		if (fromSelection.checked==true) then (
			-- use function instead of $selection as this can be cleared out with deselect
			g_objects = getCurrentSelection() 
		) else (
			g_objects = $*
		)
		
		--select objects meeting criteria
		for obj in g_objects do 
		(
			generateAttributeDef obj attrNameStr p:attrParamNameStr v:attrParamValueStr addParam:false
		)
		
	)
	-- END Remove Param
)
floaterWindow = newRolloutFloater "Custom Attribute Utility" 400 260
addRollout CustomAttributeUtility floaterWindow