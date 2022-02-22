local M = {}

M.fsdiag = nil

M.setLayers = nil
M.getLayers = nil
M.savePath = ""


function M.init(fsdiag, setLayers, getLayers, setCursorPos, getCursorPos)
    M.fsdiag = fsdiag

    M.setLayers = setLayers
    M.getLayers = getLayers

    M.setCursorPos = setCursorPos
    M.getCursorPos = getCursorPos
end

function M.new()
    local layers = {{name = "Black", color = colors.black, pages = {}}}
    M.setLayers(layers)

    local cursorPos = {page = 1, x = 1, y = 1}
    M.setCursorPos(cursorPos)
end

function M.save(saveAs)
    if saveAs == nil then saveAs = false end
end

function M.saveAs()
    M.save(true)
end

function M.open()
    local path = M.fsdiag.open("/")
    print("Path: " .. path)
    sleep(2)
end

return M