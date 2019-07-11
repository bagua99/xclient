local BaseLayer = class("BaseLayer", cc.Node)

function BaseLayer:ctor(iColorLayer)
    self:enableNodeEvents()

    if iColorLayer then
        local curColorLayer = display.newLayer(cc.c4b(0,0,0,128))
        self:addChild(curColorLayer)
    end
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    if self.onCreate then self:onCreate(iColorLayer) end
    self:initView()
    self:initTouch()
end

function BaseLayer:initView()

end

function BaseLayer:initTouch()

end

function BaseLayer:createResoueceNode(resourceFilename)
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

function BaseLayer:markNode(p_parent,p_nodeName,curTable,p_saveNode)
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

return BaseLayer
