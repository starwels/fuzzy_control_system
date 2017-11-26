local utils={}

function asserttype(x,t,name)
    assert(type(x)==t,name..' must be a '..t)
end

function assertnumber(x,name)
    asserttype(x,'number',name)
end

function assertstring(x,name)
    asserttype(x,'string',name)
end

function asserttable(x,name,size,subtype)
    asserttype(x,'table',name)
    if size~=nil then assert(#x==size,name..'\'s size must be '..size) end
    if subtype~=nil then for i=1,#x do asserttype(x[i],subtype,name..'\'s element') end end
end

function assertmember(x,X,name)
    asserttable(X,'X',nil,type(x))
    for i=1,#X do if x==X[i] then return end end
    assert(false,name..' must be one of '..table_join(X,', '))
end

function table.val_to_str(v)
    if "string"==type(v) then
        v=string.gsub(v,"\n","\\n")
        if string.match(string.gsub(v,"[^'\"]",""),'^"+$') then
            return "'"..v.."'"
        end
        return '"'..string.gsub(v,'"','\\"')..'"'
    else
        return "table"==type(v) and table.tostring(v) or tostring(v)
    end
end

function table.key_to_str(k)
    if "string"==type(k) and string.match(k,"^[_%a][_%a%d]*$") then
        return k
    else
        return "["..table.val_to_str(k).."]"
    end
end

function table.tostring(tbl)
    local result,done={},{}
    for k,v in ipairs(tbl) do
        table.insert(result,table.val_to_str(v))
        done[k]=true
    end
    for k,v in pairs(tbl) do
        if not done[k] then
            table.insert(result, table.key_to_str(k).."="..table.val_to_str(v))
        end
    end
    return "{"..table.concat(result,",").."}"
end

function math.hypotn(a,b)
    asserttable(a,'a',nil,'number')
    asserttable(b,'b',#a,'number')
    local d=0
    for i=1,#a do d=d+math.pow(a[i]-b[i],2) end
    return math.sqrt(d)
end

function string.formatex(fmt,...)
    local arg1={}
    for i,v in ipairs(arg) do
        arg1[i]=(type(v)=='table' and table.val_to_str(v) or v)
    end
    return string.format(fmt,unpack(arg1))
end

function string.split(s,pat)
    local fields={}
    local function helper(field) table.insert(fields,field) return '' end
    helper((s:gsub(pat,helper)))
    return fields
end

function string.splitlines(s)
    return string.split(s,"(.-)\r?\n")
end

function include(relativePathAndFile,cmd)
    if not __notFirst__ then
        local appPath=simGetStringParameter(sim_stringparam_application_path)
        if simGetInt32Parameter(sim_intparam_platform)==1 then
            appPath=appPath.."/../../.."
        end
        __notFirst__=true
        __scriptCodeToRun__=assert(loadfile(appPath..relativePathAndFile))
        if cmd then
            local tmp=assert(loadstring(cmd))
            if tmp then
                tmp()
            end
        end
    end
    if __scriptCodeToRun__ then
        __scriptCodeToRun__()
    end
end

function getObjectsWithTag(tagName,justModels)
    local retObjs={}
    local objs=simGetObjectsInTree(sim_handle_scene)
    for i=1,#objs,1 do
        if (not justModels) or (simBoolAnd32(simGetModelProperty(objs[i]),sim_modelproperty_not_model)==0) then
        local dat=simReadCustomDataBlock(objs[i],tagName)
            if dat then
                retObjs[#retObjs+1]=objs[i]
            end
        end
    end
    return retObjs
end

createOpenBox=function(size,baseThickness,wallThickness,density,inertiaCorrectionFact,static,respondable,color)
    local parts={}
    local dim={size[1],size[2],baseThickness}
    parts[1]=simCreatePureShape(0,16,dim,density*dim[1]*dim[2]*dim[3])
    simSetObjectPosition(parts[1],-1,{0,0,baseThickness*0.5})
    dim={wallThickness,size[2],size[3]-baseThickness}
    parts[2]=simCreatePureShape(0,16,dim,density*dim[1]*dim[2]*dim[3])
    simSetObjectPosition(parts[2],-1,{(size[1]-wallThickness)*0.5,0,baseThickness+dim[3]*0.5})
    parts[3]=simCreatePureShape(0,16,dim,density*dim[1]*dim[2]*dim[3])
    simSetObjectPosition(parts[3],-1,{(-size[1]+wallThickness)*0.5,0,baseThickness+dim[3]*0.5})
    dim={size[1]-2*wallThickness,wallThickness,size[3]-baseThickness}
    parts[4]=simCreatePureShape(0,16,dim,density*dim[1]*dim[2]*dim[3])
    simSetObjectPosition(parts[4],-1,{0,(size[2]-wallThickness)*0.5,baseThickness+dim[3]*0.5})
    parts[5]=simCreatePureShape(0,16,dim,density*dim[1]*dim[2]*dim[3])
    simSetObjectPosition(parts[5],-1,{0,(-size[2]+wallThickness)*0.5,baseThickness+dim[3]*0.5})
    for i=1,#parts,1 do
        simSetShapeColor(parts[i],'',sim_colorcomponent_ambient_diffuse,color)
    end
    local shape=simGroupShapes(parts)
    if math.abs(1-inertiaCorrectionFact)>0.001 then
        local transf=simGetObjectMatrix(shape,-1)
        local m0,i0,com0=simGetShapeMassAndInertia(shape,transf)
        for i=1,#i0,1 do
            i0[i]=i0[1]*inertiaCorrectionFact
        end
        simSetShapeMassAndInertia(shape,m0,i0,com0,transf)
    end
    if static then
        simSetObjectInt32Parameter(shape,sim_shapeintparam_static,1)
    else
        simSetObjectInt32Parameter(shape,sim_shapeintparam_static,0)
    end
    if respondable then
        simSetObjectInt32Parameter(shape,sim_shapeintparam_respondable,1)
    else
        simSetObjectInt32Parameter(shape,sim_shapeintparam_respondable,0)
    end
    simReorientShapeBoundingBox(shape,-1)
    return shape
end

function customUi_populateCombobox(ui,id,items_array,exceptItems_map,currentItem,sort,additionalItemsToTop_array)
    local _itemsTxt={}
    local _itemsMap={}
    for i=1,#items_array,1 do
        local txt=items_array[i][1]
        if (not exceptItems_map) or (not exceptItems_map[txt]) then
            _itemsTxt[#_itemsTxt+1]=txt
            _itemsMap[txt]=items_array[i][2]
        end
    end
    if sort then
        table.sort(_itemsTxt)
    end
    local tableToReturn={}
    if additionalItemsToTop_array then
        for i=1,#additionalItemsToTop_array,1 do
            tableToReturn[#tableToReturn+1]={additionalItemsToTop_array[i][1],additionalItemsToTop_array[i][2]}
        end
    end
    for i=1,#_itemsTxt,1 do
        tableToReturn[#tableToReturn+1]={_itemsTxt[i],_itemsMap[_itemsTxt[i]]}
    end
    if additionalItemsToTop_array then
        for i=1,#additionalItemsToTop_array,1 do
            table.insert(_itemsTxt,i,additionalItemsToTop_array[i][1])
        end
    end
    local index=0
    for i=1,#_itemsTxt,1 do
        if _itemsTxt[i]==currentItem then
            index=i-1
            break
        end
    end
    simExtCustomUI_setComboboxItems(ui,id,_itemsTxt,index,true)
    return tableToReturn,index
end

function getObjectHandle_noError(name)
    local err=simGetInt32Parameter(sim_intparam_error_report_mode)
    simSetInt32Parameter(sim_intparam_error_report_mode,0)
    local retVal=simGetObjectHandle(name)
    simSetInt32Parameter(sim_intparam_error_report_mode,err)
    return retVal
end

function getObjectHandle_noErrorNoSuffixAdjustment(name)
    local err=simGetInt32Parameter(sim_intparam_error_report_mode)
    simSetInt32Parameter(sim_intparam_error_report_mode,0)
    local suff=simGetNameSuffix(nil)
    simSetNameSuffix(-1)
    local retVal=simGetObjectHandle(name)
    simSetNameSuffix(suff)
    simSetInt32Parameter(sim_intparam_error_report_mode,err)
    return retVal
end

function __loadTheString__()
    local f=loadstring(__theStringToLoad__)
    return f
end

function stringToArray(txt)
    local retVal=nil
    __theStringToLoad__='return {'..txt..'}' -- variable needs to be global here
    local res,f=pcall(__loadTheString__)
    if f then
        local res,arr=xpcall(f,function(err) return debug.traceback(err) end)
        if res then
            retVal=arr
        end
    end
    return retVal
end

function executeCode(theCode)
    __theStringToLoad__=theCode -- variable needs to be global here
    local bla,f=pcall(__loadTheString__)
    if f then
        local res,theReturn=xpcall(f,function(err) return debug.traceback(err) end)
        if res then
            return theReturn
        end
    end
end

function canScaleObjectNonIsometrically(objHandle,scaleAxisX,scaleAxisY,scaleAxisZ)
    local xIsY=(math.abs(1-math.abs(scaleAxisX/scaleAxisY))<0.001)
    local xIsZ=(math.abs(1-math.abs(scaleAxisX/scaleAxisZ))<0.001)
    local xIsYIsZ=(xIsY and xIsZ)
    if xIsYIsZ then
        return true -- iso scaling in this case
    end
    local t=simGetObjectType(objHandle)
    if t==sim_object_joint_type then
        return true
    end
    if t==sim_object_dummy_type then
        return true
    end
    if t==sim_object_camera_type then
        return true
    end
    if t==sim_object_mirror_type then
        return true
    end
    if t==sim_object_light_type then
        return true
    end
    if t==sim_object_forcesensor_type then
        return true
    end
    if t==sim_object_path_type then
        return true
    end
    if t==sim_object_pointcloud_type then
        return false
    end
    if t==sim_object_octree_type then
        return false
    end
    if t==sim_object_graph_type then
        return false
    end
    if t==sim_object_proximitysensor_type then
        local r,p=simGetObjectInt32Parameter(objHandle,sim_proxintparam_volume_type)
        if p==sim_volume_cylinder then
            return xIsY
        end
        if p==sim_volume_disc then
            return xIsZ
        end
        if p==sim_volume_cone then
            return false
        end
        if p==sim_volume_randomizedray then
            return false
        end
        return true
    end
    if t==sim_object_mill_type then
        local r,p=simGetObjectInt32Parameter(objHandle,sim_millintparam_volume_type)
        if p==sim_volume_cylinder then
            return xIsY
        end
        if p==sim_volume_disc then
            return xIsZ
        end
        if p==sim_volume_cone then
            return false
        end
        return true
    end
    if t==sim_object_visionsensor_type then
        return xIsY
    end
    if t==sim_object_shape_type then
        local r,pt=simGetShapeGeomInfo(objHandle)
        if simBoolAnd32(r,1)~=0 then
            return false -- compound
        end
        if pt==sim_pure_primitive_spheroid then
            return false
        end
        if pt==sim_pure_primitive_disc then
            return xIsY
        end
        if pt==sim_pure_primitive_cylinder then
            return xIsY
        end
        if pt==sim_pure_primitive_cone then
            return xIsY
        end
        if pt==sim_pure_primitive_heightfield then
            return xIsY
        end
        return true
    end
end

function canScaleModelNonIsometrically(modelHandle,scaleAxisX,scaleAxisY,scaleAxisZ,ignoreNonScalableItems)
    local xIsY=(math.abs(1-math.abs(scaleAxisX/scaleAxisY))<0.001)
    local xIsZ=(math.abs(1-math.abs(scaleAxisX/scaleAxisZ))<0.001)
    local yIsZ=(math.abs(1-math.abs(scaleAxisY/scaleAxisZ))<0.001)
    local xIsYIsZ=(xIsY and xIsZ)
    if xIsYIsZ then
        return true -- iso scaling in this case
    end
    local allDescendents=simGetObjectsInTree(modelHandle,sim_handle_all,1)
    -- First the model base:
    local t=simGetObjectType(modelHandle)
    if (t==sim_object_pointcloud_type) or (t==sim_object_pointcloud_type) or (t==sim_object_pointcloud_type) then
        if not ignoreNonScalableItems then
            if not canScaleObjectNonIsometrically(modelHandle,scaleAxisX,scaleAxisY,scaleAxisZ) then
                return false
            end
        end
    else
        if not canScaleObjectNonIsometrically(modelHandle,scaleAxisX,scaleAxisY,scaleAxisZ) then
            return false
        end
    end
    -- Ok, we can scale the base, now check the descendents:
    local baseFrameScalingFactors={scaleAxisX,scaleAxisY,scaleAxisZ}
    for i=1,#allDescendents,1 do
        local h=allDescendents[i]
        t=simGetObjectType(h)
        if ( (t~=sim_object_pointcloud_type) and (t~=sim_object_pointcloud_type) and (t~=sim_object_pointcloud_type) ) or (not ignoreNonScalableItems) then
            local m=simGetObjectMatrix(h,modelHandle)
            local axesMapping={-1,-1,-1} -- -1=no mapping
            local matchingAxesCnt=0
            local objFrameScalingFactors={nil,nil,nil}
            local singleMatchingAxisIndex
            for j=1,3,1 do
                local newAxis={m[j],m[j+4],m[j+8]}
                local x={math.abs(newAxis[1]),math.abs(newAxis[2]),math.abs(newAxis[3])}
                local v=math.max(math.max(x[1],x[2]),x[3])
                if v>0.99 then
                    matchingAxesCnt=matchingAxesCnt+1
                    if x[1]>0.9 then
                        axesMapping[j]=1
                        objFrameScalingFactors[j]=baseFrameScalingFactors[axesMapping[j]]
                        singleMatchingAxisIndex=j
                    end
                    if x[2]>0.9 then
                        axesMapping[j]=2
                        objFrameScalingFactors[j]=baseFrameScalingFactors[axesMapping[j]]
                        singleMatchingAxisIndex=j
                    end
                    if x[3]>0.9 then
                        axesMapping[j]=3
                        objFrameScalingFactors[j]=baseFrameScalingFactors[axesMapping[j]]
                        singleMatchingAxisIndex=j
                    end
                end
            end
            if matchingAxesCnt==0 then
                -- the child frame is not aligned at all with the model frame. And scaling is not iso-scaling
                -- Dummies, cameras, lights and force sensors do not mind:
                local t=simGetObjectType(h)
                if (t~=sim_object_dummy_type) and (t~=sim_object_camera_type) and (t~=sim_object_light_type) and (t~=sim_object_forcesensor_type) then
                    return false
                end
            else
                if matchingAxesCnt==3 then
                    if not canScaleObjectNonIsometrically(h,objFrameScalingFactors[1],objFrameScalingFactors[2],objFrameScalingFactors[3]) then
                        return false
                    end
                else
                    -- We have only one axis that matches. We can scale the object only if the two non-matching axes have the same scaling factor:
                    local otherFactors={nil,nil}
                    for j=1,3,1 do
                        if j~=axesMapping[singleMatchingAxisIndex] then
                            if otherFactors[1] then
                                otherFactors[2]=baseFrameScalingFactors[j]
                            else
                                otherFactors[1]=baseFrameScalingFactors[j]
                            end
                        end
                    end
                    if (math.abs(1-math.abs(otherFactors[1]/otherFactors[2]))<0.001) then
                        local fff={otherFactors[1],otherFactors[1],otherFactors[1]}
                        fff[singleMatchingAxisIndex]=objFrameScalingFactors[singleMatchingAxisIndex]
                        if not canScaleObjectNonIsometrically(h,fff[1],fff[2],fff[3]) then
                            return false
                        end
                    else
                        return false
                    end
                end
            end
        end
    end
    return true
end

function scaleModelNonIsometrically(modelHandle,scaleAxisX,scaleAxisY,scaleAxisZ)
    local xIsY=(math.abs(1-math.abs(scaleAxisX/scaleAxisY))<0.001)
    local xIsZ=(math.abs(1-math.abs(scaleAxisX/scaleAxisZ))<0.001)
    local xIsYIsZ=(xIsY and xIsZ)
    if xIsYIsZ then
        simScaleObjects({modelHandle},scaleAxisX,false) -- iso scaling in this case
    else
        local avgScaling=(scaleAxisX+scaleAxisY+scaleAxisZ)/3
        local allDescendents=simGetObjectsInTree(modelHandle,sim_handle_all,1)
        -- First the model base:
        simScaleObject(modelHandle,scaleAxisX,scaleAxisY,scaleAxisZ,0)
        -- Now scale all the descendents:
        local baseFrameScalingFactors={scaleAxisX,scaleAxisY,scaleAxisZ}
        for i=1,#allDescendents,1 do
            local h=allDescendents[i]
            -- First scale the object itself:
            local m=simGetObjectMatrix(h,modelHandle)
            local axesMapping={-1,-1,-1} -- -1=no mapping
            local matchingAxesCnt=0
            local objFrameScalingFactors={nil,nil,nil}
            for j=1,3,1 do
                local newAxis={m[j],m[j+4],m[j+8]}
                local x={math.abs(newAxis[1]),math.abs(newAxis[2]),math.abs(newAxis[3])}
                local v=math.max(math.max(x[1],x[2]),x[3])
                if v>0.99 then
                    matchingAxesCnt=matchingAxesCnt+1
                    if x[1]>0.9 then
                        axesMapping[j]=1
                        objFrameScalingFactors[j]=baseFrameScalingFactors[axesMapping[j]]
                    end
                    if x[2]>0.9 then
                        axesMapping[j]=2
                        objFrameScalingFactors[j]=baseFrameScalingFactors[axesMapping[j]]
                    end
                    if x[3]>0.9 then
                        axesMapping[j]=3
                        objFrameScalingFactors[j]=baseFrameScalingFactors[axesMapping[j]]
                    end
                end
            end
            if matchingAxesCnt==0 then
                -- the child frame is not aligned at all with the model frame.
                simScaleObject(h,avgScaling,avgScaling,avgScaling,0)
            end

            if matchingAxesCnt==3 then
                -- the child frame is orthogonally aligned with the model frame
                simScaleObject(h,objFrameScalingFactors[1],objFrameScalingFactors[2],objFrameScalingFactors[3],0)
            else
                -- We have only one axis that is aligned with the model frame
                local objFactor,objIndex
                for j=1,3,1 do
                    if objFrameScalingFactors[j]~=nil then
                        objFactor=objFrameScalingFactors[j]
                        objIndex=j
                        break
                    end
                end
                local otherFactors={nil,nil}
                for j=1,3,1 do
                    if baseFrameScalingFactors[j]~=objFactor then
                        if otherFactors[1]==nil then
                            otherFactors[1]=baseFrameScalingFactors[j]
                        else
                            otherFactors[2]=baseFrameScalingFactors[j]
                        end
                    end
                end
                if (math.abs(1-math.abs(otherFactors[1]/otherFactors[2]))<0.001) then
                    local fff={otherFactors[1],otherFactors[1],otherFactors[1]}
                    fff[objIndex]=objFactor
                    simScaleObject(h,fff[1],fff[2],fff[3],0)
                else
                    local of=(otherFactors[1]+otherFactors[2])/2
                    local fff={of,of,of}
                    fff[objIndex]=objFactor
                    simScaleObject(h,fff[1],fff[2],fff[3],0)
                end
            end
            -- Now scale also the position of that object:
            local parentObjH=simGetObjectParent(h)
            local m=simGetObjectMatrix(parentObjH,modelHandle)
            m[4]=0
            m[8]=0
            m[12]=0
            local mi={}
            for j=1,12,1 do
                mi[j]=m[j]
            end
            simInvertMatrix(mi)
            local p=simGetObjectPosition(h,parentObjH)
            p=simMultiplyVector(m,p)
            p[1]=p[1]*scaleAxisX
            p[2]=p[2]*scaleAxisY
            p[3]=p[3]*scaleAxisZ
            p=simMultiplyVector(mi,p)
            simSetObjectPosition(h,parentObjH,p)
        end
    end
end

function utils.createCustomUi(nakedXml,title,dlgPos,closeable,onCloseFunction,modal,resizable,activate,additionalAttributes,dlgSize)
    local xml='<ui title="'..title..'" closeable="'
    if closeable then
        if onCloseFunction and onCloseFunction~='' then
            xml=xml..'true" onclose="'..onCloseFunction..'"'
        else
            xml=xml..'true"'
        end
    else
        xml=xml..'false"'
    end
    if modal then
        xml=xml..' modal="true"'
    else
        xml=xml..' modal="false"'
    end
    if resizable then
        xml=xml..' resizable="true"'
    else
        xml=xml..' resizable="false"'
    end
    if activate then
        xml=xml..' activate="true"'
    else
        xml=xml..' activate="false"'
    end
    if additionalAttributes and additionalAttributes~='' then
        xml=xml..' '..additionalAttributes
    end
    if dlgSize then
        xml=xml..' size="'..dlgSize[1]..','..dlgSize[2]..'"'
    end
    if not dlgPos then
        xml=xml..' placement="relative" position="-50,50">'
    else
        if type(dlgPos)=='string' then
            if dlgPos=='center' then
                xml=xml..' placement="center">'
            end
            if dlgPos=='bottomRight' then
                xml=xml..' placement="relative" position="-50,-50">'
            end
            if dlgPos=='bottomLeft' then
                xml=xml..' placement="relative" position="50,-50">'
            end
            if dlgPos=='topLeft' then
                xml=xml..' placement="relative" position="50,50">'
            end
            if dlgPos=='topRight' then
                xml=xml..' placement="relative" position="-50,50">'
            end
        else
            xml=xml..' placement="absolute" position="'..dlgPos[1]..','..dlgPos[2]..'">'
        end
    end
    xml=xml..nakedXml..'</ui>'
    local ui=simExtCustomUI_create(xml)
    --[[
    if dlgSize then
        simExtCustomUI_setSize(ui,dlgSize[1],dlgSize[2])
    end
    --]]
    if not activate then
        if 2==simGetInt32Parameter(sim_intparam_platform) then
            -- To fix a Qt bug on Linux
            simAuxFunc('activateMainWindow')
        end
    end
    return ui
end

function utils.getSelectedEditWidget(ui)
    local ret=-1
    if simGetInt32Parameter(sim_intparam_program_version)>30302 then
        ret=simExtCustomUI_getCurrentEditWidget(ui)
    end
    return ret
end

function utils.setSelectedEditWidget(ui,id)
    if id>=0 then
        simExtCustomUI_setCurrentEditWidget(ui,id)
    end
end

function utils.getRadiobuttonValFromBool(b)
    if b then
        return 1
    end
    return 0
end

function utils.getCheckboxValFromBool(b)
    if b then
        return 2
    end
    return 0
end

function utils.writeSessionPersistentObjectData(objectHandle,dataName,...)
    local data={...}
    local nm="___"..simGetScriptHandle()..simGetObjectName(objectHandle)..simGetInt32Parameter(sim_intparam_scene_unique_id)..simGetObjectStringParameter(objectHandle,sim_objstringparam_dna)..dataName
    data=simPackTable(data)
    simWriteCustomDataBlock(sim_handle_app,nm,data)
end

function utils.readSessionPersistentObjectData(objectHandle,dataName)
    local nm="___"..simGetScriptHandle()..simGetObjectName(objectHandle)..simGetInt32Parameter(sim_intparam_scene_unique_id)..simGetObjectStringParameter(objectHandle,sim_objstringparam_dna)..dataName
    local data=simReadCustomDataBlock(sim_handle_app,nm)
    if data then
        data=simUnpackTable(data)
        return unpack(data)
    else
        return nil
    end
end

function utils.fastIdleLoop(enable)
    local data=simReadCustomDataBlock(sim_handle_app,'__IDLEFPSSTACKSIZE__')
    local stage=0
    local defaultIdleFps
    if data then
        data=simUnpackInts(data)
        stage=data[1]
        defaultIdleFps=data[2]
    else
        defaultIdleFps=simGetInt32Parameter(sim_intparam_idle_fps)
    end
    if enable then
        stage=stage+1
    else
        if stage>0 then
            stage=stage-1
        end
    end
    if stage>0 then
        simSetInt32Parameter(sim_intparam_idle_fps,0)
    else
        simSetInt32Parameter(sim_intparam_idle_fps,defaultIdleFps)
    end
    simWriteCustomDataBlock(sim_handle_app,'__IDLEFPSSTACKSIZE__',simPackInts({stage,defaultIdleFps}))
end

function utils.isPluginLoaded(pluginName)
    local index=0
    local moduleName=''
    while moduleName do
        moduleName=simGetModuleName(index)
        if (moduleName==pluginName) then
            return(true)
        end
        index=index+1
    end
    return(false)
end


return utils