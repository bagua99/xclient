local M = class("UIEvent")

function M:ctor()
 	self.tEvent = {}
end

function M:add(e, LayerName)
    if self.tEvent.LayerName == nil then
        self.tEvent.LayerName = {}
    end
    if self.tEvent.LayerName[e] then
        print("waring UIEvent multiple registration")
        return 
    end
    if e.addClickEventListener then 
		e:addClickEventListener(function()
			self:post(e, LayerName)
		end)
	end
    self.tEvent.LayerName[e] = 
    {
        object = e,
        --time,         -- 同按钮触发时间,默认nil,无触发时间等待
        --layertime,    -- 同层次触发时间,默认nil,无触发时间等待,同为"N"层次,按钮a,b,按钮a响应后,b必须等待layertime才可响应b
    }
end

function M:del(LayerName)
	self.tEvent.LayerName = nil
end

function M:post(e, LayerName)
    if not self.tEvent.LayerName then
        return 
    end
    local t = self.tEvent.LayerName[e]
    if not t then
        return 
    end
    local nTime = os.time()
    if e.time then
        if t.time ~= nil then
            if t.time + e.time > nTime then
                return
            end
        end
    end
    if e.layertime then
        if t.layertime ~= nil then
            if t.layertime + e.layertime > nTime then
                return
            end
        end
    end
	if e.call then
		e.call()
	end
    t.time = nTime
    t.layertime = nTime
end

return M
