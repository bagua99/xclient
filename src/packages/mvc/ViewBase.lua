
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    if self.onCreate then self:onCreate() end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)

    self.resourceNode_.node = {}
    local curTable = {}
    self:markNode(self.resourceNode_,self.resourceNode_.node,curTable,self.resourceNode_.node)
end

function ViewBase:markNode(p_parent,p_nodeName,curTable,p_saveNode)
    local children = p_parent:getChildren()
    local parentName = p_parent:getName()
    local childrenCount = p_parent:getChildrenCount()
    if childrenCount < 1 then
        printInfo("childrenCount < 0 " )
        return
    end
    if p_nodeName[parentName] then
    else
        p_nodeName[parentName] = p_parent
    end

    if p_nodeName[parentName].node then
    else
        p_nodeName[parentName].node = {}
    end

    for i = 1,childrenCount do
        local curNode = children[i]
        local curName = curNode:getName()
        local subChildCount = curNode:getChildrenCount()

        p_nodeName[parentName].node[curName] = curNode

        if curTable[curName] then
            
        else
            p_saveNode[curName] = curNode
            curTable[curName] = curName
        end
        p_nodeName[parentName].node[curName].node = {}
        if subChildCount > 0 then
            self:markNode(curNode,p_nodeName[parentName].node[curName].node,curTable,p_saveNode)
        end
    end
end


function ViewBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

return ViewBase
