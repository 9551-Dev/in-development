local expect = require("cc.expect").expect
local createCanvas = function(termObj)
    expect(1,termObj,"table")
    local index = {}
    local function toBlit(t)
        if t[6] == 1 then for i = 1, 5 do t[i] = 1-t[i] end end
        local n = 128
        for i = 0, 4 do n = n + t[i+1]*2^i end
        return n, t[6] == 1
    end
    local drawInternal = function(char)
        char.draw = {toBlit(char)}
    end
    function index:print(x,y)
        expect(0,self,"table")
        expect(1,x,"number")
        expect(2,y,"number")
        local term = self.disp
        local bc = term.getBackgroundColor()
        local tc = term.getTextColor()
        local temp = x%2==0
        local charX = 1
        local charY = (y - 1) % 3+1
        local ox = math.ceil(x/2)
        local oy = math.ceil(y/3)
        if temp then charX = 2 end
        if not self.map[ox] then self.map[ox] = {} end
        if not self.map[ox][oy] then
            self.map[ox][oy] = {0,0,0,0,0,0}
            local exchange = self.map[ox][oy]
            local i = ((charY-1) * 2) + charX
            exchange[i] = 1
            drawInternal(exchange)
        else
            local exchange = self.map[ox][oy]
            local i = ((charY-1) * 2) + charX
            exchange[i] = 1
            self.map[ox][oy] = exchange
            drawInternal(self.map[ox][oy])
        end
        if self.map[ox][oy].draw[2] then
            term.setTextColor(bc)
            term.setBackgroundColor(tc)
        end
        term.setCursorPos(ox,oy)
        term.write(string.char(self.map[ox][oy].draw[1]))
        term.setBackgroundColor(bc)
        term.setTextColor(tc)
    end
    function index:create(x,y)
        expect(0,self,"table")
        expect(1,x,"number")
        expect(2,y,"number")
        local temp = x%2==0
        local charX = 1
        local charY = (y - 1) % 3+1
        local ox = math.ceil(x/2)
        local oy = math.ceil(y/3)
        if temp then charX = 2 end
        if not self.map[ox] then self.map[ox] = {} end
        if not self.map[ox][oy] then
            self.map[ox][oy] = {0,0,0,0,0,0}
            local exchange = self.map[ox][oy]
            local i = ((charY-1) * 2) + charX
            exchange[i] = 1
            drawInternal(exchange)
        else
            local exchange = self.map[ox][oy]
            local i = ((charY-1) * 2) + charX
            exchange[i] = 1
            self.map[ox][oy] = exchange
            drawInternal(self.map[ox][oy])
        end
    end
    function index:remove(x,y)
        expect(0,self,"table")
        expect(1,x,"number")
        expect(2,y,"number")
        local temp = x%2==0
        local charX = 1
        local charY = (y - 1) % 3+1
        if temp then charX = 2 end
        local ox = math.ceil(x/2)
        local oy = math.ceil(y/3)
        if not self[ox] then self[ox] = {} end
        if not self.map[ox][oy] then
            self.map[ox] = {}
            self.map[ox][oy] = {0,0,0,0,0,0}
        else
            local exchange = self.map[ox][oy]
            local i = ((charY-1) * 2) + charX
            exchange[i] = 0
            self.map[ox][oy] = exchange
            drawInternal(self.map[ox][oy])
        end
    end
    function index:clear()
        expect(0,self,"table")
        self.map = {}
    end
    function index:getSize()
        expect(0,self,"table")
        local x,y = self.disp.getSize()
        return x*2,y*3
    end
    function index:draw()
        expect(0,self,"table")
        local term = self.disp
        local bc = term.getBackgroundColor()
        local tc = term.getTextColor()
        for k,v in pairs(self.map) do
            for k1,v1 in pairs(v) do
                for k2,v2 in pairs(v1) do
                    if k2 == "draw" then
                        if v2[2] then
                            term.setBackgroundColor(tc)
                            term.setTextColor(bc)
                        end
                        term.setCursorPos(k,k1)
                        term.write(string.char(v2[1]))
                        term.setBackgroundColor(bc)
                        term.setTextColor(tc)
                    end
                end
            end
        end
    end
    local pixelMap = {disp=termObj,map={},funcs=index}
    return setmetatable(pixelMap,{__index=index})
end
return {
    createCanvas = createCanvas,
}
