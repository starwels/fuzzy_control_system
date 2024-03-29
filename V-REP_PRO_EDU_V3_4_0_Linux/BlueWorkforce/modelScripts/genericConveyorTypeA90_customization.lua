local bwUtils=require('bwUtils')

function removeFromPluginRepresentation()

end

function updatePluginRepresentation()

end

function getDefaultInfoForNonExistingFields(info)
    if not info['version'] then
        info['version']=_MODELVERSION_
    end
    if not info['subtype'] then
        info['subtype']='A90'
    end
    if not info['velocity'] then
        info['velocity']=0.1
    end
    if not info['acceleration'] then
        info['acceleration']=0.01
    end
    if not info['outerRadius'] then
        info['outerRadius']=1
    end
    if not info['width'] then
        info['width']=0.3
    end
    if not info['padHeight'] then
        info['padHeight']=0.04
    end
    if not info['height'] then
        info['height']=0.1
    end
    if not info['padSpacing'] then
        info['padSpacing']=0.2
    end
    if not info['padThickness'] then
        info['padThickness']=0.01
    end
    if not info['bitCoded'] then
        info['bitCoded']=1+2+4+8
    end
    if not info['wallThickness'] then
        info['wallThickness']=0.005
    end
    if not info['stopRequests'] then
        info['stopRequests']={}
    end
end

function readInfo()
    local data=simReadCustomDataBlock(model,'CONVEYOR_CONF')
    if data then
        data=simUnpackTable(data)
    else
        data={}
    end
    getDefaultInfoForNonExistingFields(data)
    return data
end

function writeInfo(data)
    if data then
        simWriteCustomDataBlock(model,'CONVEYOR_CONF',simPackTable(data))
    else
        simWriteCustomDataBlock(model,'CONVEYOR_CONF','')
    end
end

function setColor(red,green,blue,spec)
    simSetShapeColor(pad,nil,sim_colorcomponent_ambient_diffuse,{red,green,blue})
    simSetShapeColor(pad,nil,sim_colorcomponent_specular,{spec,spec,spec})
    simSetShapeColor(endPad1,nil,sim_colorcomponent_ambient_diffuse,{red,green,blue})
    simSetShapeColor(endPad1,nil,sim_colorcomponent_specular,{spec,spec,spec})
    simSetShapeColor(endPad2,nil,sim_colorcomponent_ambient_diffuse,{red,green,blue})
    simSetShapeColor(endPad2,nil,sim_colorcomponent_specular,{spec,spec,spec})

    i=0
    while true do
        local h=simGetObjectChild(path,i)
        if h>=0 then
            local ch=simGetObjectChild(h,0)
            if ch>=0 then
                simSetShapeColor(ch,nil,sim_colorcomponent_ambient_diffuse,{red,green,blue})
                simSetShapeColor(ch,nil,sim_colorcomponent_specular,{spec,spec,spec})
            end
            i=i+1
        else
            break
        end
    end
end

function getColor()
    local r,rgb=simGetShapeColor(pad,nil,sim_colorcomponent_ambient_diffuse)
    local r,spec=simGetShapeColor(pad,nil,sim_colorcomponent_specular)
    return rgb[1],rgb[2],rgb[3],(spec[1]+spec[2]+spec[3])/3
end

function setShapeSize(h,x,y,z)
    local r,mmin=simGetObjectFloatParameter(h,sim_objfloatparam_objbbox_min_x)
    local r,mmax=simGetObjectFloatParameter(h,sim_objfloatparam_objbbox_max_x)
    local sx=mmax-mmin
    local r,mmin=simGetObjectFloatParameter(h,sim_objfloatparam_objbbox_min_y)
    local r,mmax=simGetObjectFloatParameter(h,sim_objfloatparam_objbbox_max_y)
    local sy=mmax-mmin
    local r,mmin=simGetObjectFloatParameter(h,sim_objfloatparam_objbbox_min_z)
    local r,mmax=simGetObjectFloatParameter(h,sim_objfloatparam_objbbox_max_z)
    local sz=mmax-mmin
    simScaleObject(h,x/sx,y/sy,z/sz)
end

function getAvailableSensors()
    local l=simGetObjectsInTree(sim_handle_scene,sim_handle_all,0)
    local retL={}
    for i=1,#l,1 do
        local data=simReadCustomDataBlock(l[i],'XYZ_BINARYSENSOR_INFO')
        if data then
            retL[#retL+1]={simGetObjectName(l[i]),l[i]}
        end
    end
    return retL
end

function getAvailableMasterConveyors()
    local l=simGetObjectsInTree(sim_handle_scene,sim_handle_all,0)
    local retL={}
    for i=1,#l,1 do
        if l[i]~=model then
            local data=simReadCustomDataBlock(l[i],'CONVEYOR_CONF')
            if data then
                retL[#retL+1]={simGetObjectName(l[i]),l[i]}
            end
        end
    end
    return retL
end

function getActualPadSpacing()
    local conf=readInfo()
    local l=simGetPathLength(path)
    local cnt=math.floor(l/conf['padSpacing'])+1
    local dx=l/cnt
    return dx
end

function updateConveyor()
    local conf=readInfo()
    local length=conf['outerRadius']
    local outerRadius=length
    local width=conf['width']
    local innerRadius=outerRadius-width
    local wallHeight=conf['padHeight']
    local padHeight=0.01
    local padSpacing=conf['padSpacing']
    local bitCoded=conf['bitCoded']
    local padThickness=0.04--conf[9]
    local baseThickness=conf['height']
    local wt=conf['wallThickness']

    local pr=outerRadius-width*0.5
    local padSep
    local i=0
    while true do
        padSep=padThickness*pr/outerRadius
        if math.pi*0.5*pr/padThickness<10 or i==1 then
            break
        end
        padThickness=padThickness*2
        i=i+1
    end

    local sc=0.004

    setShapeSize(front,outerRadius+sc,outerRadius+sc,baseThickness)
    simSetObjectPosition(front,model,{padThickness*0.5+(outerRadius+sc)*0.5,padThickness*0.5+(outerRadius+sc)*0.5,-baseThickness*0.5})
    setShapeSize(back,outerRadius-width-sc,outerRadius-width-sc,baseThickness)
    simSetObjectPosition(back,model,{padThickness*0.5+(outerRadius-width-sc)*0.5,padThickness*0.5+(outerRadius-width-sc)*0.5,-baseThickness*0.5})
    
    setShapeSize(endPart1,width+sc*2,padThickness,baseThickness)
    simSetObjectPosition(endPart1,model,{padThickness*0.5+pr,padThickness*0.5,-baseThickness*0.5})
    setShapeSize(endPart2,padThickness,width+sc*2,baseThickness)
    simSetObjectPosition(endPart2,model,{padThickness*0.5,padThickness*0.5+pr,-baseThickness*0.5})
    setShapeSize(pad,width,padThickness,padHeight)
    simSetObjectPosition(path,model,{0,0,-baseThickness*0.5})
    simSetObjectPosition(pad,sim_handle_parent,{0,-padHeight*0.5,0})

    while true do
        local h=simGetObjectChild(path,0)
        if h>=0 then
            simRemoveObject(h)
        else
            break
        end
    end


    local hc=0
    for lc=1,2,1 do
        simCutPathCtrlPoints(path,-1,0)
        local pts={}
        local div=30
        for i=0,div-1,1 do
            pts[(i+0)*11+1]=padThickness*0.5+pr*math.cos(i*math.pi*0.5/(div-1))+((i==(div-1)) and 0.001 or 0)
            pts[(i+0)*11+2]=padThickness*0.5+pr*math.sin(i*math.pi*0.5/(div-1))+((i==0) and 0.001 or 0)
            pts[(i+0)*11+3]=baseThickness*0.5
            pts[(i+0)*11+4]=math.pi*0.5
            pts[(i+0)*11+5]=i*math.pi*0.5/(div-1)
            pts[(i+0)*11+6]=0
            pts[(i+0)*11+7]=1
            pts[(i+0)*11+8]=0
            pts[(i+0)*11+9]=((i==0)or(i==(div-1))) and 1 or 15
            pts[(i+0)*11+10]=0.95
            pts[(i+0)*11+11]=0.95
        end
        for i=0,div-1,1 do
            pts[(i+div)*11+1]=padThickness*0.5+pr*math.sin(i*math.pi*0.5/(div-1))+((i==0) and 0.001 or 0)
            pts[(i+div)*11+2]=padThickness*0.5+pr*math.cos(i*math.pi*0.5/(div-1))+((i==(div-1)) and 0.001 or 0)
            pts[(i+div)*11+3]=(baseThickness-padThickness)*0.5+hc
            pts[(i+div)*11+4]=math.pi*0.5
            pts[(i+div)*11+5]=(div-1-i)*math.pi*0.5/(div-1)
            pts[(i+div)*11+6]=0
            pts[(i+div)*11+7]=1
            pts[(i+div)*11+8]=0
            pts[(i+div)*11+9]=((i==0)or(i==(div-1))) and 1 or 15
            pts[(i+div)*11+10]=0.95
            pts[(i+div)*11+11]=0.95
        end
        simInsertPathCtrlPoints(path,1,0,div*2,pts)
        if lc==1 then
            local l=simGetPathLength(path)
            local cnt=math.floor(l/padSep)
            hc=(l-cnt*padSep)*0.5
        end
    end

    local l=simGetPathLength(path)
    local cnt=math.floor(l/padSep)

    local dx=l/cnt
    for i=0,cnt-1,1 do
        local pb=simCopyPasteObjects({padBase},0)[1]
        local p=simCopyPasteObjects({pad},0)[1]
        simSetObjectParent(p,pb,true)
        simSetObjectParent(pb,path,true)
        simSetObjectInt32Parameter(p,sim_objintparam_visibility_layer,1+256)
        simSetObjectInt32Parameter(p,sim_shapeintparam_respondable,1)
        simSetObjectSpecialProperty(p,sim_objectspecialproperty_collidable+sim_objectspecialproperty_measurable+sim_objectspecialproperty_detectable_all+sim_objectspecialproperty_renderable)
        simSetObjectFloatParameter(pb,sim_dummyfloatparam_follow_path_offset,i*dx)

        if simBoolAnd32(bitCoded,32)>0 then
            simSetShapeTexture(p,-1,sim_texturemap_plane,12,{0.04,0.04})
        end

    end
    setShapeSize(endPad1,width,padThickness,padHeight)
    setShapeSize(endPad2,width,padThickness,padHeight)
    simSetObjectPosition(endPad1,model,{padThickness*0.5+pr,padThickness*0.5,-padHeight*0.5})
    simSetObjectPosition(endPad2,model,{padThickness*0.5,padThickness*0.5+pr,-padHeight*0.5})
    if simBoolAnd32(bitCoded,32)==0 then
        local textureID=simGetShapeTextureId(pad)
        simSetShapeTexture(endPad1,textureID,sim_texturemap_plane,12,{0.04,0.04})
        simSetShapeTexture(endPad2,textureID,sim_texturemap_plane,12,{0.04,0.04})
    else
        simSetShapeTexture(endPad1,-1,sim_texturemap_plane,12,{0.04,0.04})
        simSetShapeTexture(endPad2,-1,sim_texturemap_plane,12,{0.04,0.04})
    end


    local err=simGetInt32Parameter(sim_intparam_error_report_mode)
    simSetInt32Parameter(sim_intparam_error_report_mode,0) -- do not report errors
    local obj=simGetObjectHandle('genericCurvedConveyorTypeB_sides')
    simSetInt32Parameter(sim_intparam_error_report_mode,err) -- report errors again
    if obj>=0 then
        simRemoveObject(obj)
    end

    local sideParts={}
    if simBoolAnd32(bitCoded,4)==0 then
        local div=2+math.floor(math.pi*outerRadius*0.5/padThickness)
        for i=0,div-1,1 do
            local p1=simCopyPasteObjects({sidePad},0)[1]
            setShapeSize(p1,wt,padThickness,wallHeight+baseThickness)
            simSetObjectPosition(p1,model,{padThickness*0.5+(outerRadius+wt*0.5)*math.cos(i*math.pi*0.5/(div-1)),padThickness*0.5+(outerRadius+wt*0.5)*math.sin(i*math.pi*0.5/(div-1)),(wallHeight-baseThickness)*0.5})
            simSetObjectOrientation(p1,model,{0,0,i*math.pi*0.5/(div-1)})
            sideParts[#sideParts+1]=p1
        end
    end

    if simBoolAnd32(bitCoded,8)==0 then
        local div=2+math.floor(math.pi*innerRadius*0.5/padThickness)
        for i=0,div-1,1 do
            local p1=simCopyPasteObjects({sidePad},0)[1]
            setShapeSize(p1,wt,padThickness,wallHeight+baseThickness)
            simSetObjectPosition(p1,model,{padThickness*0.5+(innerRadius-wt*0.5)*math.cos(i*math.pi*0.5/(div-1)),padThickness*0.5+(innerRadius-wt*0.5)*math.sin(i*math.pi*0.5/(div-1)),(wallHeight-baseThickness)*0.5})
            simSetObjectOrientation(p1,model,{0,0,i*math.pi*0.5/(div-1)})
            sideParts[#sideParts+1]=p1
        end
    end
    if #sideParts>0 then
        local h=simGroupShapes(sideParts)
        simSetObjectInt32Parameter(h,sim_objintparam_visibility_layer,1+256)
        simSetObjectInt32Parameter(h,sim_shapeintparam_respondable,1)
        simSetObjectSpecialProperty(h,sim_objectspecialproperty_collidable+sim_objectspecialproperty_measurable+sim_objectspecialproperty_detectable_all+sim_objectspecialproperty_renderable)
        local suff=simGetNameSuffix(simGetObjectName(model))
        local name='genericCurvedConveyorTypeB_sides'
        if suff>=0 then
            name=name..'#'..suff
        end
        simSetObjectName(h,name)
        simSetObjectParent(h,model,true)
    end
--]]
    
end

function outerRadiusChange(ui,id,newVal)
    local conf=readInfo()
    local l=tonumber(newVal)
    if l then
        l=l*0.001
        if l<conf['width']+0.05 then l=conf['width']+0.05 end
        if l>2 then l=2 end
        if l~=conf['outerRadius'] then
            modified=true
            conf['outerRadius']=l
            writeInfo(conf)
            updateConveyor()
        end
    end
    simExtCustomUI_setEditValue(ui,2,string.format("%.0f",conf['outerRadius']/0.001),true)
end

function widthChange(ui,id,newVal)
    local conf=readInfo()
    local w=tonumber(newVal)
    if w then
        w=w*0.001
        if w<0.05 then w=0.05 end
        if w>conf['outerRadius']-0.05 then w=conf['outerRadius']-0.05 end
        if w~=conf['width'] then
            modified=true
            conf['width']=w
            writeInfo(conf)
            updateConveyor()
        end
    end
    simExtCustomUI_setEditValue(ui,4,string.format("%.0f",conf['width']/0.001),true)
end

function padHeightChange(ui,id,newVal)
    local conf=readInfo()
    local w=tonumber(newVal)
    if w then
        w=w*0.001
        if w<0.001 then w=0.001 end
        if w>0.2 then w=0.2 end
        if w~=conf['padHeight'] then
            modified=true
            conf['padHeight']=w
            writeInfo(conf)
            updateConveyor()
        end
    end
    simExtCustomUI_setEditValue(ui,20,string.format("%.0f",conf['padHeight']/0.001),true)
end

function heightChange(ui,id,newVal)
    local conf=readInfo()
    local w=tonumber(newVal)
    if w then
        w=w*0.001
        if w<0.01 then w=0.01 end
        if w>1 then w=1 end
        if w~=conf['height'] then
            modified=true
            conf['height']=w
            writeInfo(conf)
            updateConveyor()
        end
    end
    simExtCustomUI_setEditValue(ui,28,string.format("%.0f",conf['height']/0.001),true)
end

function wallThicknessChange(ui,id,newVal)
    local conf=readInfo()
    local w=tonumber(newVal)
    if w then
        w=w*0.001
        if w<0.001 then w=0.001 end
        if w>0.02 then w=0.02 end
        if w~=conf['wallThickness'] then
            modified=true
            conf['wallThickness']=w
            writeInfo(conf)
            updateConveyor()
        end
    end
    simExtCustomUI_setEditValue(ui,29,string.format("%.0f",conf['wallThickness']/0.001),true)
end

function frontSideOpenClicked(ui,id,newVal)
    local conf=readInfo()
    conf['bitCoded']=simBoolOr32(conf['bitCoded'],4)
    if newVal==0 then
        conf['bitCoded']=conf['bitCoded']-4
    end
    modified=true
    writeInfo(conf)
    updateConveyor()
end

function backSideOpenClicked(ui,id,newVal)
    local conf=readInfo()
    conf['bitCoded']=simBoolOr32(conf['bitCoded'],8)
    if newVal==0 then
        conf['bitCoded']=conf['bitCoded']-8
    end
    modified=true
    writeInfo(conf)
    updateConveyor()
end

function texturedClicked(ui,id,newVal)
    local conf=readInfo()
    conf['bitCoded']=simBoolOr32(conf['bitCoded'],32)
    if newVal~=0 then
        conf['bitCoded']=conf['bitCoded']-32
    end
    modified=true
    writeInfo(conf)
    updateConveyor()
end


function redChange(ui,id,newVal)
    modified=true
    local r,g,b,s=getColor()
    setColor(newVal/100,g,b,s)
end

function greenChange(ui,id,newVal)
    modified=true
    local r,g,b,s=getColor()
    setColor(r,newVal/100,b,s)
end

function blueChange(ui,id,newVal)
    modified=true
    local r,g,b,s=getColor()
    setColor(r,g,newVal/100,s)
end

function specularChange(ui,id,newVal)
    modified=true
    local r,g,b,s=getColor()
    setColor(r,g,b,newVal/100)
end

function speedChange(ui,id,newVal)
    local c=readInfo()
    local v=tonumber(newVal)
    if v then
        v=v*0.001
        if v<-0.5 then v=-0.5 end
        if v>0.5 then v=0.5 end
        if v~=c['velocity'] then
            modified=true
            c['velocity']=v
            writeInfo(c)
        end
    end
    simExtCustomUI_setEditValue(ui,10,string.format("%.0f",c['velocity']/0.001),true)
end

function accelerationChange(ui,id,newVal)
    local c=readInfo()
    local v=tonumber(newVal)
    if v then
        v=v*0.001
        if v<0.001 then v=0.001 end
        if v>1 then v=1 end
        if v~=c['acceleration'] then
            modified=true
            c['acceleration']=v
            writeInfo(c)
        end
    end
    simExtCustomUI_setEditValue(ui,12,string.format("%.0f",c['acceleration']/0.001),true)
end
function enabledClicked(ui,id,newVal)
    local conf=readInfo()
    conf['bitCoded']=simBoolOr32(conf['bitCoded'],64)
    if newVal==0 then
        conf['bitCoded']=conf['bitCoded']-64
    end
    modified=true
    writeInfo(conf)
end

function triggerStopChange_callback(ui,id,newIndex)
    local sens=comboStopTrigger[newIndex+1][2]
    bwUtils.setReferencedObjectHandle(model,REF_STOP_SIG,sens)
    if bwUtils.getReferencedObjectHandle(model,REF_START_SIG)==sens then
        bwUtils.setReferencedObjectHandle(model,REF_START_SIG,-1)
    end
    modified=true
    updateStartStopTriggerComboboxes()
end

function triggerStartChange_callback(ui,id,newIndex)
    local sens=comboStartTrigger[newIndex+1][2]
    bwUtils.setReferencedObjectHandle(model,REF_START_SIG,sens)
    if bwUtils.getReferencedObjectHandle(model,REF_STOP_SIG)==sens then
        bwUtils.setReferencedObjectHandle(model,REF_STOP_SIG,-1)
    end
    modified=true
    updateStartStopTriggerComboboxes()
end

function masterChange_callback(ui,id,newIndex)
    local sens=comboMaster[newIndex+1][2]
    bwUtils.setReferencedObjectHandle(model,REF_MASTER_CONV,sens) -- master
    modified=true
    updateMasterCombobox()
    updateEnabledDisabledItems()
end

function updateStartStopTriggerComboboxes()
    local c=readInfo()
    local loc=getAvailableSensors()
    comboStopTrigger=customUi_populateCombobox(ui,100,loc,{},bwUtils.getObjectNameOrNone(bwUtils.getReferencedObjectHandle(model,REF_STOP_SIG)),true,{{'<NONE>',-1}})
    comboStartTrigger=customUi_populateCombobox(ui,101,loc,{},bwUtils.getObjectNameOrNone(bwUtils.getReferencedObjectHandle(model,REF_START_SIG)),true,{{'<NONE>',-1}})
end

function updateMasterCombobox()
    local c=readInfo()
    local loc=getAvailableMasterConveyors()
    comboMaster=customUi_populateCombobox(ui,102,loc,{},bwUtils.getObjectNameOrNone(bwUtils.getReferencedObjectHandle(model,REF_MASTER_CONV)),true,{{'<NONE>',-1}})
end

function updateEnabledDisabledItems()
    if ui then
        local c=readInfo()
        local simStopped=simGetSimulationState()==sim_simulation_stopped
        simExtCustomUI_setEnabled(ui,2,simStopped,true)
        simExtCustomUI_setEnabled(ui,4,simStopped,true)

        simExtCustomUI_setEnabled(ui,20,simStopped,true)
        simExtCustomUI_setEnabled(ui,24,simStopped,true)
        simExtCustomUI_setEnabled(ui,25,simStopped,true)
        simExtCustomUI_setEnabled(ui,28,simStopped,true)
        simExtCustomUI_setEnabled(ui,29,simStopped,true)
        simExtCustomUI_setEnabled(ui,30,simStopped,true)

        simExtCustomUI_setEnabled(ui,5,simStopped,true)
        simExtCustomUI_setEnabled(ui,6,simStopped,true)
        simExtCustomUI_setEnabled(ui,7,simStopped,true)
        simExtCustomUI_setEnabled(ui,8,simStopped,true)

        simExtCustomUI_setEnabled(ui,1000,bwUtils.getReferencedObjectHandle(model,REF_MASTER_CONV)==-1,true) -- enable
        simExtCustomUI_setEnabled(ui,10,bwUtils.getReferencedObjectHandle(model,REF_MASTER_CONV)==-1,true) -- vel
        simExtCustomUI_setEnabled(ui,12,bwUtils.getReferencedObjectHandle(model,REF_MASTER_CONV)==-1,true) -- accel
        
        simExtCustomUI_setEnabled(ui,100,simStopped,true) -- stop trigger
        simExtCustomUI_setEnabled(ui,101,simStopped,true) -- restart trigger
        simExtCustomUI_setEnabled(ui,102,simStopped,true) -- master
    end
end

function onCloseClicked()
end

function createDlg()
    if (not ui) and bwUtils.canOpenPropertyDialog() then
        local xml = [[
    <tabs id="77">
    <tab title="General" layout="form">
                <label text="Enabled"/>
                <checkbox text="" onchange="enabledClicked" id="1000"/>

                <label text="Speed (mm/s)"/>
                <edit oneditingfinished="speedChange" id="10"/>

                <label text="Acceleration (mm/s^2)"/>
                <edit oneditingfinished="accelerationChange" id="12"/>

                <label text="Master conveyor"/>
                <combobox id="102" onchange="masterChange_callback">
                </combobox>

                <label text="Stop on trigger"/>
                <combobox id="100" onchange="triggerStopChange_callback">
                </combobox>

                <label text="Restart on trigger"/>
                <combobox id="101" onchange="triggerStartChange_callback">
                </combobox>

            <label text="" style="* {margin-left: 150px;}"/>
            <label text="" style="* {margin-left: 150px;}"/>
    </tab>
    <tab title="Dimensions" layout="form">
                <label text="Outer radius (mm)"/>
                <edit oneditingfinished="outerRadiusChange" id="2"/>

                <label text="Width (mm)"/>
                <edit oneditingfinished="widthChange" id="4"/>

                <label text="Height (mm)"/>
                <edit oneditingfinished="heightChange" id="28"/>
    </tab>

    <tab title="Color" layout="form">
                <label text="Red"/>
                <hslider minimum="0" maximum="100" onchange="redChange" id="5"/>
                <label text="Green"/>
                <hslider minimum="0" maximum="100" onchange="greenChange" id="6"/>
                <label text="Blue"/>
                <hslider minimum="0" maximum="100" onchange="blueChange" id="7"/>
                <label text="Specular"/>
                <hslider minimum="0" maximum="100" onchange="specularChange" id="8"/>
    </tab>
    <tab title="More" layout="form">
                <label text="Textured"/>
                <checkbox text="" onchange="texturedClicked" id="30"/>

                <label text="Front side open"/>
                <checkbox text="" onchange="frontSideOpenClicked" id="24"/>

                <label text="Back side open"/>
                <checkbox text="" onchange="backSideOpenClicked" id="25"/>

                <label text="Side height (mm)"/>
                <edit oneditingfinished="padHeightChange" id="20"/>

                <label text="Side thickness (mm)"/>
                <edit oneditingfinished="wallThicknessChange" id="29"/>
    </tab>
    </tabs>
        ]]


        ui=bwUtils.createCustomUi(xml,simGetObjectName(model),previousDlgPos--[[,closeable,onCloseFunction,modal,resizable,activate,additionalUiAttribute--]])

        local red,green,blue,spec=getColor()
        local config=readInfo()

        simExtCustomUI_setEditValue(ui,10,string.format("%.0f",config['velocity']/0.001),true)
        simExtCustomUI_setEditValue(ui,12,string.format("%.0f",config['acceleration']/0.001),true)
        simExtCustomUI_setEditValue(ui,2,string.format("%.0f",config['outerRadius']/0.001),true)
        simExtCustomUI_setEditValue(ui,4,string.format("%.0f",config['width']/0.001),true)
        simExtCustomUI_setEditValue(ui,20,string.format("%.0f",config['padHeight']/0.001),true)
        simExtCustomUI_setEditValue(ui,28,string.format("%.0f",config['height']/0.001),true)
        simExtCustomUI_setEditValue(ui,29,string.format("%.0f",config['wallThickness']/0.001),true)
        simExtCustomUI_setCheckboxValue(ui,24,(simBoolAnd32(config['bitCoded'],4)~=0) and 2 or 0,true)
        simExtCustomUI_setCheckboxValue(ui,25,(simBoolAnd32(config['bitCoded'],8)~=0) and 2 or 0,true)
        simExtCustomUI_setCheckboxValue(ui,30,(simBoolAnd32(config['bitCoded'],32)==0) and 2 or 0,true)
        simExtCustomUI_setCheckboxValue(ui,1000,(simBoolAnd32(config['bitCoded'],64)~=0) and 2 or 0,true)

        simExtCustomUI_setSliderValue(ui,5,red*100,true)
        simExtCustomUI_setSliderValue(ui,6,green*100,true)
        simExtCustomUI_setSliderValue(ui,7,blue*100,true)
        simExtCustomUI_setSliderValue(ui,8,spec*100,true)

        updateStartStopTriggerComboboxes()
        updateMasterCombobox()
        updateEnabledDisabledItems()
        simExtCustomUI_setCurrentTab(ui,77,dlgMainTabIndex,true)
    end
end

function showDlg()
    if not ui then
        createDlg()
    end
end

function removeDlg()
    if ui then
        local x,y=simExtCustomUI_getPosition(ui)
        previousDlgPos={x,y}
        dlgMainTabIndex=simExtCustomUI_getCurrentTab(ui,77)
        simExtCustomUI_destroy(ui)
        ui=nil
    end
end

if (sim_call_type==sim_customizationscriptcall_initialization) then
    REF_STOP_SIG=1 -- index of referenced stop trigger object handle
    REF_START_SIG=2 -- index of referenced start trigger object handle
    REF_MASTER_CONV=3 -- index of referenced master conveyor object handle
    modified=false
    dlgMainTabIndex=0
    lastT=simGetSystemTimeInMs(-1)
    model=simGetObjectAssociatedWithScript(sim_handle_self)
    _MODELVERSION_=0
    _CODEVERSION_=0
    local _info=readInfo()
    bwUtils.checkIfCodeAndModelMatch(model,_CODEVERSION_,_info['version'])
    -- Following for backward compatibility:
    if _info['stopTrigger'] then
        bwUtils.setReferencedObjectHandle(model,REF_STOP_SIG,getObjectHandle_noErrorNoSuffixAdjustment(_info['stopTrigger']))
        _info['stopTrigger']=nil
    end
    if _info['startTrigger'] then
        bwUtils.setReferencedObjectHandle(model,REF_START_SIG,getObjectHandle_noErrorNoSuffixAdjustment(_info['startTrigger']))
        _info['startTrigger']=nil
    end
    if _info['masterConveyor'] then
        bwUtils.setReferencedObjectHandle(model,REF_MASTER_CONV,getObjectHandle_noErrorNoSuffixAdjustment(_info['masterConveyor']))
        _info['masterConveyor']=nil
    end
    ----------------------------------------
    writeInfo(_info)

    padBase=simGetObjectHandle('genericCurvedConveyorTypeA90_padBase')
    pad=simGetObjectHandle('genericCurvedConveyorTypeA90_pad')
    path=simGetObjectHandle('genericCurvedConveyorTypeA90_path')
    endPad1=simGetObjectHandle('genericCurvedConveyorTypeA90_endPad1')
    endPad2=simGetObjectHandle('genericCurvedConveyorTypeA90_endPad2')
    front=simGetObjectHandle('genericCurvedConveyorTypeA90_front')
    back=simGetObjectHandle('genericCurvedConveyorTypeA90_back')
    endPart1=simGetObjectHandle('genericCurvedConveyorTypeA90_endPart1')
    endPart2=simGetObjectHandle('genericCurvedConveyorTypeA90_endPart2')
    sidePad=simGetObjectHandle('genericCurvedConveyorTypeA90_sidePad')
	simSetScriptAttribute(sim_handle_self,sim_customizationscriptattribute_activeduringsimulation,true)
    updatePluginRepresentation()
    previousDlgPos,algoDlgSize,algoDlgPos,distributionDlgSize,distributionDlgPos,previousDlg1Pos=bwUtils.readSessionPersistentObjectData(model,"dlgPosAndSize")
end

showOrHideUiIfNeeded=function()
    local s=simGetObjectSelection()
    if s and #s>=1 and s[#s]==model then
        showDlg()
    else
        removeDlg()
    end
end

if (sim_call_type==sim_customizationscriptcall_nonsimulation) then
    showOrHideUiIfNeeded()
    if simGetSystemTimeInMs(lastT)>3000 then
        lastT=simGetSystemTimeInMs(-1)
        if modified then
            simAnnounceSceneContentChange() -- to have an undo point
            modified=false
        end
    end
end

if (sim_call_type==sim_customizationscriptcall_simulationsensing) then
    if simJustStarted then
        updateEnabledDisabledItems()
    end
    simJustStarted=nil
    showOrHideUiIfNeeded()
end

if (sim_call_type==sim_customizationscriptcall_simulationpause) then
    showOrHideUiIfNeeded()
end

if (sim_call_type==sim_customizationscriptcall_firstaftersimulation) then
    updateEnabledDisabledItems()
    local conf=readInfo()
    conf['encoderDistance']=0
    conf['stopRequests']={}
    writeInfo(conf)
end

if (sim_call_type==sim_customizationscriptcall_lastbeforesimulation) then
    simJustStarted=true
end

if (sim_call_type==sim_customizationscriptcall_lastbeforeinstanceswitch) then
    removeDlg()
    removeFromPluginRepresentation()
end

if (sim_call_type==sim_customizationscriptcall_firstafterinstanceswitch) then
    updatePluginRepresentation()
end

if (sim_call_type==sim_customizationscriptcall_cleanup) then
    removeDlg()
    removeFromPluginRepresentation()
    bwUtils.writeSessionPersistentObjectData(model,"dlgPosAndSize",previousDlgPos,algoDlgSize,algoDlgPos,distributionDlgSize,distributionDlgPos,previousDlg1Pos)
end